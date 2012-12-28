using Posix;
	
namespace Submarine {
	
	private class SubtitulosESServer : SubtitleServer {
		private Soup.SessionSync session;
		
		private string filepath;
		private const string MAIN_URI = "http://duckduckgo.com/html";
		private const string USER_AGENT = "submarine/0.1";

		private Xml.Node *internal_last_node;

		// http://www.subtitulos.es/search.php?cx=partner-pub-9712736367130269%3A92aabu-f398&cof=FORID%3A10&ie=ISO-8859-1&q=doctor+who+%282005%29+3x10&sa=Buscar&siteurl=www.subtitulos.es%2F&ref=&ss=158j24964j4
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
		
		private Xml.Node *find_node(Xml.Node *c_node,string name,string attr_name="",string attr_value="",Xml.Node *last=null,bool first=true) {
			
			if(first) {
				this.internal_last_node=last;
			}
			
			if (c_node==null) {
				return null;
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
	
		public override Gee.Set<Subtitle> search(File file, Gee.Collection<string> languages) {

			string showid="X";
			string tvdbid="X";

			var subtitles_downloaded = new Gee.HashSet<Subtitle>();

			this.filepath=file.get_path();

			var tmp=file.get_basename();
			var pos = tmp.last_index_of(".");
			var main_filename=tmp.substring(0,pos);
			
			Subtitle ? retval;
			
			var parser = new Submarine.NameParser(file);
			if (parser.title==null) {
				GLib.stdout.printf("Can't determine the serie/movie title\n");
				return subtitles_downloaded;
			}

			string title;
			string title_full;
			string seasons;
			
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
			
			GLib.stdout.printf("Subtitulos.es: searching for %s\n",title_full);
			
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
				GLib.stdout.printf("encontrado a href=%s\n",link_node->get_prop("href"));
			}
/*
			while(true) {
				
				// and check each link
				pos1=rv.index_of("<div class=\"links_main links_deep\">",pos1);
				if (pos1<0) {
					link_uri="";
					break;
				}
				pos1+=35;
				pos1=rv.index_of("href=\"",pos1);
				if (pos1<0) {
					continue;
				}
				pos1+=6;
				var pos2=rv.index_of("\"",pos1);
				if ((pos1==pos2)||(pos2<0)) {
					continue;
				}
				link_uri=rv.substring(pos1,pos2-pos1);
				// find the end of the <a href...> tag
				pos1=rv.index_of(">",pos2);
				if (pos1<0) {
					continue;
				}
				pos1++;
				pos2=rv.index_of("</a>",pos1);
				if ((pos2<0)||(pos1==pos2)) {
					continue;
				}
				// text with the page description. We must remove the HTML tags to be able to parse it
				var link_description=rv.substring(pos1,pos2-pos1).replace("<b>","").replace("</b>","");
				
				// now, let's ensure that this link points to what we are looking for
				
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
				break;
			}
			
			GLib.stdout.printf("Pagina: %s\n",link_uri);
			
/*			string lang;
			
			foreach(string l in languages) {
				if (l.length==3) {
					lang=l;
				} else {
					lang=Submarine.get_alternate(l);
				}

				int pos_ini=0;
				while(true) {
					var pos1=rv.index_of("<td>"+main_filename,pos_ini);
					if (pos1==-1) {
						break;
					}
					pos_ini=pos1+4;
					var pos2=rv.index_of("<a href=\"",pos1+4);
					if (pos2==-1) {
						continue;
					}
					var pos3=rv.index_of("\"",pos2+9);
					if (pos3==-1) {
						continue;
					}
					var uri=MAIN_URI+"/"+rv.substring(pos2+9,pos3-pos2-9);
					Subtitle subtitle = new Subtitle(this.info, uri);
					subtitle.language=l;
					subtitles_downloaded.add(subtitle);
				}
			}*/
			
			return subtitles_downloaded;
		}

		bool remove_directory (string path) {
			
			bool flag = false;
			var directory = File.new_for_path (path);
  
			var enumerator = directory.enumerate_children (
				FileAttribute.STANDARD_NAME, 0
			);
  
			FileInfo file_info;
			while ((file_info = enumerator.next_file ()) != null) {
				var newpath=GLib.Path.build_filename(path,file_info.get_name());
				if ((file_info.get_file_type ()) == FileType.DIRECTORY) {
					if (this.remove_directory(newpath)) {
						flag=true;
					}
				}
				var newfile= File.new_for_path(newpath);
				if(false==newfile.delete()) {
					flag=true;
				}
			}
			return flag;
		}

		public override Subtitle? download(Subtitle subtitle) {
			
			var message = new Soup.Message("GET","%s".printf(subtitle.server_data.get_string()));
			message.request_headers.append("User-Agent",USER_AGENT);
			uint status_code = this.session.send_message(message);
			if (status_code==200) {
				this.remove_directory("/tmp/submarine");
				var tmp_path=GLib.File.new_for_path("/tmp/submarine");
				try {
					tmp_path.make_directory_with_parents();
				} catch (Error e) {	
				}
				
				var output_file=GLib.File.new_for_path("/tmp/submarine/data.zip");
				try {
					var output_stream = output_file.create(GLib.FileCreateFlags.NONE);
					var file_data=message.response_body.data;
					output_stream.write(file_data);
					output_stream.close();
				} catch (Error e) {
					this.remove_directory("/tmp/submarine");
					return null;
				}
				
				Posix.system("unzip /tmp/submarine/data.zip -d /tmp/submarine/");
				try {
					output_file.delete();
				} catch (Error e) {
				}
				
				var directory = File.new_for_path ("/tmp/submarine");
				var enumerator = directory.enumerate_children (
					FileAttribute.STANDARD_NAME+","+FileAttribute.STANDARD_SIZE, 0
				);
  
				FileInfo file_info;
				string ext1="srt".casefold();
				string ext2="sub".casefold();
				while ((file_info = enumerator.next_file ()) != null) {
					string tmp=file_info.get_name();
					var pos = tmp.last_index_of(".");
					var ext=tmp.substring(pos+1).casefold();
					if ((ext!=ext1)&&(ext!=ext2)) {
						continue;
					}
					var newpath=GLib.Path.build_filename("/tmp/submarine",tmp);
					
					uint8[] buffer=new uint8[file_info.get_size()];
					
					try {
						var input_stream=GLib.File.new_for_path(newpath).read();
						input_stream.read(buffer);
						input_stream.close();
					} catch (Error e) {
						this.remove_directory("/tmp/submarine");
						return null;
					}
					subtitle.data=(string)(buffer);
					if (ext==ext1) {
						subtitle.format="srt";
					} else {
						subtitle.format="sub";
					}
					break;
				}
				this.remove_directory("/tmp/submarine");
				return (subtitle);
			}
			this.remove_directory("/tmp/submarine");
			return null;
		}
		
	}
	
}
