namespace Submarine {
	
	private class BierdopjeServer : SubtitleServer {
		private Soup.SessionSync session;
		
		private const string XMLRPC_URI = "http://api.bierdopje.com/A2B638AC5D804C2E/";
		private const string USER_AGENT = "submarine/0.1";
		
		private string filepath;
		private string filehash;
		
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
			
			this.filepath=file.get_path();
			
			var parser = new Submarine.NameParser(file);
			
			return null;
/*			
			var message = new Soup.Message("GET",XMLRPC_URI+"?action=search&hash=%s".printf(hash));
			message.request_headers.append("User-Agent","SubDB/1.0 (submarine/0.1; https://github.com/blazt/submarine)");
			uint status_code = this.session.send_message(message);
			

			if(status_code==200) {
				var rv=(string)(message.response_body.data);
				var list = rv.split(",");
				Value v = hash;
				foreach(string sub in list) {
					Subtitle subtitle = new Subtitle(this.info, v);
					subtitle.language=sub;
					subtitles_downloaded.add(subtitle);
				}
			}
			
			return subtitles_downloaded;*/
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
