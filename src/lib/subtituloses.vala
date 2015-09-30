using GLib;
using Posix;
using Xml;

namespace Submarine {

	private class SubtitulosESServer : SubtitleServer {
		private Soup.SessionSync session;

		private string filepath;
		private const string MAIN_URI = "http://duckduckgo.com/html";
		private const string SECD_URI = "http://www.subtitulos.es";
		private const string USER_AGENT = "submarine/0.1";

		private Xml.Node *internal_last_node;

		construct {
			this.info = ServerInfo("Subtitulos.es",
					"http://www.subtitulos.es",
					"es");

			filepath="";
		}

		public override bool connect() {

			this.session = new Soup.SessionSync();

			return true;
		}

		public override void disconnect() {

		}

		private bool check_attribute(Xml.Node *c_node,string attr_name,string attr_value) {
			if (attr_name=="") {
				return true;
			}

			var prop=c_node->has_prop(attr_name);
			if (null!=prop) {
				if (attr_value=="") {
					return true;
				}
				if ((prop->children!=null)&&(prop->children->content==attr_value)) {
					return true;
				}
			}
			return false;
		}

		private Xml.Node *find_node(Xml.Node *c_node,string name,string attr_name="",string attr_value="",Xml.Node *last=null,bool is_first=true) {


			if (c_node==null) {
				return null;
			}

			if (is_first) {
				this.internal_last_node=last;
			}

			if ((c_node->name==name)&&(this.internal_last_node==null)) {
				if (this.check_attribute(c_node,attr_name,attr_value)) {
					return c_node;
				}
			}

			if (c_node==this.internal_last_node) {
				this.internal_last_node=null;
			}

			if (c_node->children!=null) {
				var rv=this.find_node(c_node->children,name,attr_name,attr_value,null,false);
				if (rv!=null) {
					return rv;
				}
			}
			if (c_node->next!=null) {
				var rv=this.find_node(c_node->next,name,attr_name,attr_value,null,false);
				if (rv!=null) {
					return rv;
				}
			}
			return null;
		}

		private string? get_inner_text(Xml.Node *c_node) {

			if (c_node==null) {
				return "";
			}

			var content="";
			if (c_node->content!=null) {
				content+=c_node->content;
			}
			content+=this.get_inner_text(c_node->children)+this.get_inner_text(c_node->next);

			return content;
		}

		public override Gee.Set<Subtitle> search(File file, Gee.Collection<string> languages) {

			var subtitles_downloaded = new Gee.HashSet<Subtitle>();

			this.filepath=file.get_path();

			var parser = new Submarine.NameParser(file);
			if (parser.title==null) {
				GLib.stderr.printf("Subtitulos.es: Can't determine the serie/movie title\n");
				return subtitles_downloaded;
			}

			string title;
			string title_full;
			string seasons;

			bool found=false;

			if(parser.year!=-1) {
				title="%s (%d)".printf(parser.title,parser.year);
			} else {
				title="%s".printf(parser.title);
			}

			if ((parser.season!=-1)&&(parser.chapter!=-1)) {
				seasons="%dx%02d".printf(parser.season,parser.chapter);
				title_full="%s %s".printf(title,seasons);
			} else {
				seasons="";
				title_full=title;
			}

			GLib.stderr.printf("Subtitulos.es: searching for %s\n",title_full);

			// since Google encripts and proccesses the searchs with javascript, we must use another one. Duck Duck Go in this case
			var message = Soup.Form.request_new("GET",MAIN_URI,"q",title_full+" site:www.subtitulos.es");
			message.request_headers.append("User-Agent",USER_AGENT);

			var status_code = this.session.send_message(message);
			if (status_code!=200) {
				return subtitles_downloaded;
			}

			var rv=(string)(message.response_body.data);

			var htmlparser = Html.Doc.read_doc(rv,"");
			var c_node=htmlparser->get_root_element();
			var top_tree=find_node(c_node,"div","id","links");

			if (top_tree==null) {
				return subtitles_downloaded;
			}

			Xml.Node *last_node=null;
			Gee.ArrayList <string> uris=new Gee.ArrayList <string>();
			while(true) {
				var current_node=find_node(top_tree,"div","class","links_main links_deep",last_node);
				if (current_node==null) {
					break;
				}
				last_node=current_node;
				var link_node=find_node(current_node,"a","href");
				if (link_node==null) {
					continue;
				}
				var text_node=link_node->children;
				var link_description=this.get_inner_text(text_node);

				var link_uri=link_node->get_prop("href");

				if (0!=link_uri.index_of("http://www.subtitulos.es")) {
					// this is not the page we are looking for
					continue;
				}

				if (-1==link_description.index_of(title)) {
					// the description doesn't contain the title
					continue;
				}

				if ((seasons!="")&&(-1==link_description.index_of(seasons))) {
					// the description doesn't contain the season/chapter piece
					continue;
				}
				// If we reached this point, we have in link_uri what seems a good page
				if (false==uris.contains(link_uri)) {
					uris.add(link_uri);
				}
			}

			foreach(var uri in uris) {

				// get each found URI, to get the subtitles available inside

				if (this.extract_subtitles(uri,languages,subtitles_downloaded,8.0)) {
					found=true;
				}
			}

			if (found==false) {
				/* No subtitles found in DuckDuck Go. It can be because they aren't still indexed,
				   so let's try directly; but give them less rating */

				   var uri=SECD_URI+"/"+title.replace(" ","-")+"/"+seasons;
				   this.extract_subtitles(uri,languages,subtitles_downloaded,7.0);
			}

			return subtitles_downloaded;
		}

		private bool extract_subtitles(string uri, Gee.Collection<string> languages, Gee.Set<Subtitle> subtitles_downloaded, double rating) {

			var message = Soup.Form.request_new("GET",uri);
			message.request_headers.append("User-Agent",USER_AGENT);

			var status_code = this.session.send_message(message);
			if (status_code!=200) {
				return false;
			}

			var rv=(string)(message.response_body.data);

			var htmlparser = Html.Doc.read_doc(rv,"");
			var c_node=htmlparser->get_root_element();
			var top_tree=find_node(c_node,"div","id","content");
			if (top_tree==null) {
				return false;
			}
			top_tree=find_node(c_node,"div","id","version",top_tree);
			if (top_tree==null) {
				return false;
			}

			bool found=false;
			Xml.Node *last_node=null;
			while(true) {
				var current_node=find_node(top_tree,"li","class","li-idioma",last_node);
				if (current_node==null) {
					break;
				}
				last_node=current_node;
				var lengua=this.get_inner_text(current_node->children).replace(" ","").replace("\n","").replace("\r","").replace("\t","");
				string current_language="";
				switch(lengua) {
				case "Español":
				case "Español(España)":
				case "Español(Latinoamérica)":
					current_language="spa";
				break;
				case "English":
					current_language="eng";
				break;
				case "Català":
					current_language="cat";
				break;
				case "Galego":
					current_language="glg";
				break;
				case "Portuguese":
					current_language="por";
				break;
				case "Euskera":
					current_language="baq";
				break;
				}
				if (current_language=="") {
					continue;
				}
				var first_span=find_node(top_tree,"span","","",last_node);
				if (first_span==null) {
					continue;
				}
				var uri_link=find_node(first_span,"a","href");
				if (uri_link==null) {
					continue;
				}
				foreach(string language in languages) {
					if (language.length==2) {
						language=Submarine.get_alternate(language);
					}
					if (language==current_language) {
						Value v=uri_link->get_prop("href");
						Subtitle subtitle = new Subtitle(this.info, v);
						subtitle.language=language;
						subtitle.data=uri;
						subtitle.rating=rating;
						subtitles_downloaded.add(subtitle);
						found=true;
						break;
					}
				}
			}
			return (found);

		}

		public override Subtitle? download(Subtitle subtitle) {

			var message = new Soup.Message("GET","%s".printf(subtitle.server_data.get_string()));
			message.request_headers.append("User-Agent",USER_AGENT);
			if(subtitle.data!="") {
				message.request_headers.append("Referer",subtitle.data);
			}

			uint status_code = this.session.send_message(message);
			if (status_code==200) {
				var rsp=message.response_headers;

				string type="";

				string cadena;
				GLib.HashTable<string,string> params;
				if(rsp.get_content_disposition(out cadena, out params)) {
					var lista=params.get_keys();
					foreach(string entrada in lista) {
						if (entrada=="filename") {
							var valor=params[entrada];
							type = valor.substring(valor.last_index_of(".")+1);
						}
					}
				}
				if ((type.casefold()=="sub".casefold())||(type.casefold()=="srt".casefold())) {
					subtitle.format=type;
					subtitle.data=(string)(message.response_body.data);
					return (subtitle);
				} else {
					return null;
				}
			}
			return null;
		}
	}

}
