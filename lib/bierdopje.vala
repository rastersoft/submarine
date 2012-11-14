namespace Submarine {
	
	private class BierdopjeServer : SubtitleServer {
		private Soup.SessionSync session;
		
		private const string XMLRPC_URI = "http://api.bierdopje.com/A2B638AC5D804C2E/";
		private const string USER_AGENT = "subliminal/0.1";
		
		private string filepath;
		
		construct {
			this.info = ServerInfo("Bierdopje",
					"http://www.bierdopje.com",
					"bd");
					
			filepath="";
		}
		
		public override bool connect() {
			
			this.session = new Soup.SessionSync();
			
			return true;
		}
		
		public override void disconnect() {
			
		}
		
		public override Gee.Set<Subtitle> search(File file, Gee.Collection<string> languages) {

			string showid="X";
			string tvdbid="X";

			var subtitles_downloaded = new Gee.HashSet<Subtitle>();

			this.filepath=file.get_path();

			var tmp=file.get_basename();
			var pos = tmp.last_index_of(".");
			var main_filename=tmp.substring(0,pos);			
			
			var parser = new Submarine.NameParser(file);
			if (parser.title==null) {
				stdout.printf("Can't determine the serie/movie title\n");
				return subtitles_downloaded;
			}
			
			stdout.printf("BierDopje: asking for \"%s\", Season %d, Chapter %d\n",parser.title, parser.season, parser.chapter);
			
			var cache = new CacheData("submarine_bierdopje");
			
			var retval=cache.get_key(parser.title);
			bool get_keys=false;
			if (retval==null) {
				get_keys=true;
			} else {
				var res=retval.split(",");
				showid=res[0];
				tvdbid=res[1];
				if (showid=="X") {
					get_keys=true;
				}
			}
	
			if (get_keys) {
				var message = new Soup.Message("GET",XMLRPC_URI+"GetShowByName/%s".printf(parser.title));
				message.request_headers.append("User-Agent",USER_AGENT);

				uint status_code = this.session.send_message(message);
				if (status_code==200) {
					var rv=(string)(message.response_body.data);
					var x = Xml.Parser.parse_memory(rv,rv.length);
					var node=x->get_root_element();
					
					var node2=this.find_xml_content("status",node);
					if ((node2!=null)&&(node2->children!=null)&&(node2->children->content=="true")) {
						
						var node3=this.find_xml_content("showid",node);
						var node4=this.find_xml_content("tvdbid",node);
						
						if ((node3!=null)&&(node3->children!=null)) {
							showid=node3->children->content;
						}
						if ((node4!=null)&&(node4->children!=null)) {
							tvdbid=node4->children->content;
						}
						cache.set_key(parser.title,"%s,%s".printf(showid,tvdbid));
					} else {
						return subtitles_downloaded;
					}
				} else {
					return subtitles_downloaded;
				}
			}
			
			foreach(string l in languages) {
				var message = new Soup.Message("GET",XMLRPC_URI+"GetAllSubsFor/%s/%d/%d/%s".printf(showid,parser.season,parser.chapter,l));
				message.request_headers.append("User-Agent",USER_AGENT);

				uint status_code = this.session.send_message(message);
				if(status_code==200) {
					var rv=(string)(message.response_body.data);
					var x = Xml.Parser.parse_memory(rv,rv.length);
					var node=x->get_root_element();
					var node2=this.find_xml_content("status",node);
					if ((node2!=null)&&(node2->children!=null)&&(node2->children->content=="true")) {
						var node3=this.find_xml_content("results",node);
						if (node3!=null) {
							Xml.Node *node4;
							node4=node3->children;
							while(node4!=null) {
								if (node4->name=="result") {
									Xml.Node *node5=node4->children;
									string c_filename="";
									string c_uri="";
									while (node5!=null) {
										if (node5->name=="filename") {
											c_filename=node5->children->content;
										}
										if (node5->name=="downloadlink") {
											c_uri=node5->children->content;
										}
										node5=node5->next;
									}
									if ((c_filename==main_filename)&&(c_uri!="")) {
										Value v = c_uri;
										Subtitle subtitle = new Subtitle(this.info, v);
										subtitle.language=l;
										subtitles_downloaded.add(subtitle);
									}
								}
								node4=node4->next;
							}
						}
					}
				}
			}		
			return subtitles_downloaded;
		}

		private Xml.Node* find_xml_content(string content, Xml.Node *node) {
			Xml.Node *tmp;
			
			if (node->name==content) {
				return node;
			}
			if (node->children!=null) {
				tmp=this.find_xml_content(content,node->children);
				if (tmp!=null) {
					return tmp;
				}
			}
			if (node->next!=null) {
				tmp=this.find_xml_content(content,node->next);
				if (tmp!=null) {
					return tmp;
				}
			}
			return null;
		}

						
		public override Subtitle? download(Subtitle subtitle) {
			
/*			var message = new Soup.Message("GET",XMLRPC_URI+"?action=download&hash=%s&language_codes_string=%s".printf(this.filehash,subtitle.language));
			message.request_headers.append("User-Agent","SubDB/1.0 (submarine/0.1; https://github.com/blazt/submarine)");
			uint status_code = this.session.send_message(message);
			if (status_code==200) {
				var rsp=message.response_headers;
				
				string type="";
				
				string cadena;
				HashTable<string,string> params;
				if(rsp.get_content_disposition(out cadena, out params)) {
					var lista=params.get_keys();
					foreach(string entrada in lista) {
						if (entrada=="filename") {
							var valor=params[entrada];
							type = valor.substring(valor.last_index_of(".")+1);
						}
					}
				}
				subtitle.format=type;
				subtitle.data=(string)(message.response_body.data);
				return (subtitle);
			}*/
			
			return null;
		}
		
	}
	
}
