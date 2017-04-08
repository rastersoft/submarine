using GLib;
using Gee;

namespace Submarine {

	public class CacheData {

		private Gee.HashMap<string,string> key_values;
		private string filepath;
		private int64 c_version;

		public CacheData(string filename,int64 version) {

			this.c_version=version;
			this.key_values = new Gee.HashMap<string,string>();


			FileInputStream file_read;

			this.filepath=GLib.Path.build_filename(GLib.Environment.get_home_dir(),"."+filename);
			var config_file = GLib.File.new_for_path(filepath);

			if (!config_file.query_exists (null)) {
				return;
			}

			try {
				file_read=config_file.read(null);
			} catch {
				return;
			}
			var in_stream = new DataInputStream (file_read);

			string line;

			bool first_line=true;
			while ((line = in_stream.read_line (null, null)) != null) {
				if (line.length==0) {
					continue;
				}
				var values=line.split("=");
				values[0].replace("\\=","=");
				values[1].replace("\\=","=");
				values[0].replace("\\\\","\\");
				values[1].replace("\\\\","\\");
				values[0].replace("\n","");
				values[1].replace("\n","");
				if (first_line) {
					first_line=false;
					// if the desired version number is greater than the version of the disk-stored database, don't load it
					if ((values[0]!="version")||(int64.parse(values[1])<this.c_version)) {
						break;
					}
				} else {
					this.key_values[values[0]]=values[1];
				}
			}
			in_stream.close();
		}

		public string? get_key(string key) {

			if (this.key_values.has_key(key)) {
				return (this.key_values.get(key));
			} else {
				return null;
			}
		}

		public void set_key(string key, string val) {

			if (this.key_values.has_key(key)) {
				this.key_values.unset(key);
			}
			this.key_values.set(key,val);

			var config_file = GLib.File.new_for_path(this.filepath);
			var file_write = config_file.replace(null, false,FileCreateFlags.NONE);

			file_write.write(("version=%lld\n".printf(this.c_version)).data);
			foreach(string vkey in this.key_values.keys) {
				var vval = this.key_values.get(vkey);

				vkey.replace("\\","\\\\");
				vkey.replace("=","\\=");
				vval.replace("\\","\\\\");
				vval.replace("=","\\=");
				file_write.write(("%s=%s\n".printf(vkey,vval)).data);
			}
			file_write.close();
		}
	}
}
