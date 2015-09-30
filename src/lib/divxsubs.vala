using Posix;

namespace Submarine {

	private class DivXsubsServer : SubtitleServer {
		private Soup.SessionSync session;

		private string filepath;
		private const string MAIN_URI = "http://www.divxsubs.com";
		private const string USER_AGENT = "submarine/0.1";

		construct {
			this.info = ServerInfo("DivXsubs",
					"http://www.divxsubs.com",
					"dx");

			filepath="";
		}

		public override bool connect() {

			this.session = new Soup.SessionSync();

			return true;
		}

		public override void disconnect() {

		}


		public override Gee.Set<Subtitle> search(File file, Gee.Collection<string> languages) {

			var subtitles_downloaded = new Gee.HashSet<Subtitle>();

			this.filepath=file.get_path();

			var tmp=file.get_basename();
			var pos = tmp.last_index_of(".");
			var main_filename=tmp.substring(0,pos);

			string lang;

			foreach(string l in languages) {
				if (l.length==3) {
					lang=l;
				} else {
					lang=Submarine.get_alternate(l);
				}

				var message = Soup.Form.request_new("POST",MAIN_URI+"/results.php","keyword",main_filename,"country",lang,"x","106","y","11");
				message.request_headers.append("User-Agent",USER_AGENT);
				message.request_headers.append("Accept-Language","es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3");
				message.request_headers.append("Referer",MAIN_URI);
				message.request_headers.append("Accept","text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"); /**/

				var status_code = this.session.send_message(message);
				if (status_code!=200) {
					continue;
				}

				var rv=(string)(message.response_body.data);

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
					Value v=uri;
					Subtitle subtitle = new Subtitle(this.info, v);
					subtitle.language=l;
					subtitle.rating=5.0; // near maximum, because it is found with a search engine
					subtitles_downloaded.add(subtitle);
				}
			}

			return subtitles_downloaded;
		}

		bool remove_directory (string path) {

			bool flag = false;
			var directory = File.new_for_path (path);
			if (directory.query_exists()==false) {
				return false;
			}
  
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
				bool found=false;
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
					found=true;
					break;
				}
				this.remove_directory("/tmp/submarine");
				if (found) {
					return (subtitle);
				} else {
					return null;
				}
			}
			this.remove_directory("/tmp/submarine");
			return null;
		}
	}
}
