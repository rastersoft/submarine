namespace Submarine {

	private class SubDBServer : SubtitleServer {
		private Soup.SessionSync session;

		private const string XMLRPC_URI = "http://api.thesubdb.com/";
		private const string USER_AGENT = "SubDB/1.0 (submarine/0.1; https://github.com/blazt/submarine)";

		private string filepath;
		private string filehash;

		construct {
			this.info = ServerInfo("SubDB",
					"http://thesubdb.com",
					"db");

			filepath="";
		}

		private uint64 file_size(File file) throws Error {
			var file_info = file.query_info("*", FileQueryInfoFlags.NONE);
			return file_info.get_size();
		}

		private string file_hash(File file) throws Error,IOError {

			string final_hash;
			uint64 size;

			uint8 buffer1[65536];
			uint8 buffer2[65536];

			//get filesize and add it to hash
			size = this.file_size(file);

			if (size<131072) {
				return ""; // the file is too small
			}

			//add first 64kB of file to hash
			var dis = new DataInputStream(file.read());
			dis.read(buffer1);
			//add last 64kB of file to hash
			dis = new DataInputStream(file.read());
			dis.skip((size_t)(size - 65536));
			dis.read(buffer2);

			var ch = new GLib.Checksum(ChecksumType.MD5);

			ch.update((uchar[])buffer1,65536);
			ch.update((uchar[])buffer2,65536);

			final_hash=ch.get_string();
			this.filehash=final_hash;
			return (final_hash);
		}

		public override bool connect() {

			this.session = new Soup.SessionSync();

			return true;
		}

		public override void disconnect() {

		}

		public override Gee.Set<Subtitle> search(File file, Gee.Collection<string> languages) {

			this.filepath=file.get_path();

			var subtitles_downloaded = new Gee.HashSet<Subtitle>();

			var hash = file_hash(file);

			var message = new Soup.Message("GET",XMLRPC_URI+"?action=search&hash=%s".printf(hash));
			message.request_headers.append("User-Agent",USER_AGENT);
			uint status_code = this.session.send_message(message);


			if(status_code==200) {
				var rv=(string)(message.response_body.data);
				var list = rv.split(",");
				Value v = hash;
				foreach(string sub in list) {
					if (languages.contains(sub)) {
						Subtitle subtitle = new Subtitle(this.info, v);
						subtitle.language=sub;
						subtitle.rating=9.9; // maximum, because it is found with hash
						subtitles_downloaded.add(subtitle);
					}
				}
			}

			return subtitles_downloaded;
		}

		public override Subtitle? download(Subtitle subtitle) {

			var message = new Soup.Message("GET",XMLRPC_URI+"?action=download&hash=%s&language_codes_string=%s".printf(this.filehash,subtitle.language));
			message.request_headers.append("User-Agent",USER_AGENT);
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
