namespace Submarine {
	
	public enum DataType {
		UNKNOWN,
		FREETEXT,
		YEAR,
		SEASON_CHAPTER,
		CODEC,
		RESOLUTION
	}
	
	public enum Resolution {
		PAL_NTSC,
		HDTV,
		HDREADY,
		FULLHD,
		UNKNOWN
	}
	
	public enum Codec {
		X264,
		DIVX,
		XVID,
		MPEG,
		UNKNOWN
	}
	
	public class NameParserNode {
		
		private string text;
		public NameParserNode ?next;
		public NameParserNode ?child;
		
		public NameParserNode ?iterator;
		
		public Submarine.DataType type;
		public Submarine.Resolution resolution;
		public Submarine.Codec codec;
		public double confidence;
		public int year;
		public int season;
		public int chapter;
		
		public int level;
		
		private string return_type() {
			switch(this.type) {
			case DataType.FREETEXT:
				return "Text";
			case DataType.YEAR:
				return "Year";
			case DataType.SEASON_CHAPTER:
				return "Season_Chapter";
			case DataType.CODEC:
				return "Codec";
			case DataType.RESOLUTION:
				return "Resolution";
			default:
				return "Unknown";
			}
		}
		
		public NameParserNode(string txt, NameParserNode ?thenext=null, int c_level=1) {
			
			this.level=c_level;
			this.type=DataType.UNKNOWN;
			this.text=txt;
			this.next=thenext;
			this.child=null;
			this.split(' ');
			this.split('_');
			this.split('.');
			this.split('(');
			this.split(')');
			this.split('[');
			this.split(']');
			this.split('{');
			this.split('}');
			
			// Check sAAeBB Season/Episode
			if (this.check_pattern("s\\d\\de\\d\\d",6,DataType.SEASON_CHAPTER)) {
				this.season=int.parse(this.text.substring(1,2));
				this.chapter=int.parse(this.text.substring(4,2));
			} else {
				// Check AxBB Season/Episode
				if (this.check_pattern("\\dx\\d\\d",4,DataType.SEASON_CHAPTER)) {
					this.season=int.parse(this.text.substring(0,1));
					this.chapter=int.parse(this.text.substring(2,2));
				}
			}
			
			// Check for year
			if (this.check_pattern("\\d\\d\\d\\d",4,DataType.YEAR)) {
				this.year=int.parse(this.text);
			}
			
			// Check for resolution
			if (this.check_pattern("hdtv",4,DataType.RESOLUTION)) {
				this.resolution=Resolution.HDTV;
				this.confidence*=0.75;
			}
			if ((this.check_pattern("720p",4,DataType.RESOLUTION))||(this.check_pattern("1080i",4,DataType.RESOLUTION))) {
				this.resolution=Resolution.HDREADY;
			} else {
				if (this.check_pattern("1080p",4,DataType.RESOLUTION)) {
					this.resolution=Resolution.FULLHD;
				}
			}
			
			// Check for codec
			
			if (this.check_pattern("x264",4,DataType.CODEC)) {
				this.codec=Codec.X264;
			} else if (this.check_pattern("divx",4,DataType.CODEC)) {
				this.codec=Codec.DIVX;
			} else if (this.check_pattern("xvid",4,DataType.CODEC)) {
				this.codec=Codec.XVID;
			} else if (this.check_pattern("mpeg",4,DataType.CODEC)) {
				this.codec=Codec.MPEG;
				this.confidence*=0.75;
			}
		}
		
		private bool check_pattern(string pattern,int length,Submarine.DataType type) {
			
			MatchInfo match_info;
			
			var year = new GLib.Regex(pattern,RegexCompileFlags.CASELESS);
			if (year.match(this.text, 0, out match_info)) {
				int s_pos;
				int e_pos;
				
				match_info.fetch_pos(0,out s_pos, out e_pos);
				if ((s_pos==0)&&(this.text.length==length)) {
					this.confidence=1.0/this.level;
					this.type=type;
					return true;
				} else {
					if(e_pos<(this.text.length-1)) {
						var c1=new NameParserNode(this.text.substring(e_pos),this.child,this.level+1);
						this.child=c1;
					}
					var c2=new NameParserNode(this.text.substring(s_pos,(e_pos-s_pos)),this.child,this.level+1);
					this.child=c2;
					if(s_pos>0) {
						var c3=new NameParserNode(this.text.substring(0,s_pos),this.child,this.level+1);
						this.child=c3;
					}
				}
			}
			return false;
		}
		
		private void split(unichar character) {
			var pos=this.text.index_of_char(character);
			if (pos==0) {
				this.text=this.text.substring(1);
			} else if (pos>0) {
				var l = this.text.length-1;
				if (pos==l) {
					this.text=this.text.substring(0,l);
				} else {
					var t1=this.text.substring(0,pos);
					var t2=this.text.substring(pos+1);
					var newchild = new NameParserNode(t2,this.next,this.level);
					this.text=t1;
					this.next=newchild;
				}
			}
		}
		
		public void print_content() {
			stdout.printf("%s (%s %f) ",this.text,this.return_type(),this.confidence);
		}
		
		public void reset_iterator() {
			this.iterator=null;
			if (this.child!=null) {
				this.child.reset_iterator();
			}
			
			if (this.next!=null) {
				this.next.reset_iterator();
			}
		}
		
		public NameParserNode? get_next_iterator() {
			
			NameParserNode ?tmp;
			
			if (this.child==null) {
				if(this.iterator==null) {
					this.iterator=this;
					return this;
				} else {
					this.iterator=null;
					return null;
				}
			} else {
				if (this.iterator==null) {
					this.iterator=this.child;
				}
				do {
					tmp = this.iterator.get_next_iterator();
					if (tmp!=null) {
						return tmp;
					}
					this.iterator=this.iterator.next;
				} while(this.iterator!=null);
				return null;
			}
		}
	}
	
	public class NameParser{
		
		NameParserNode ?node;
		NameParserNode ?iterator;
		
		public void reset_iterator() {
			this.iterator=null;
			if (this.node!=null) {
				this.node.reset_iterator();
			}
		}
		
		public NameParserNode? get_next_iterator() {
			
			NameParserNode ?tmp;
			
			if (this.node==null) {
				return null;
			} else {
				if (this.iterator==null) {
					this.iterator=this.node;
				}
				do {
					tmp = this.iterator.get_next_iterator();
					if (tmp!=null) {
						return tmp;
					}
					this.iterator=this.iterator.next;
				} while(this.iterator!=null);
				return null;
			}
		}
		
		public NameParser(File file) {
			
			// find season/chapter
			
			var tmp=file.get_basename();
			var pos = tmp.last_index_of(".");
			var filename=tmp.substring(0,pos);
			var extension=tmp.substring(pos+1);
			
			node=new NameParserNode(filename);
			
			NameParserNode ?element;
			
			stdout.printf("\n\n");
			this.reset_iterator();
			do {
				element=this.get_next_iterator();
				if (element==null) {
					break;
				}
				element.print_content();
			} while(true);
			
			stdout.printf("\n\n");
			
			/*
			var season1 = new GLib.Regex("s\\d\\de\\d\\d\\D",RegexCompileFlags.CASELESS);
			var season2 = new GLib.Regex("\\D\\dx\\d\\d\\D",RegexCompileFlags.CASELESS);
			
			MatchInfo match_info;
			
			string? previous=null;
			string? next=null;
			
			if (season1.match(filename, 0, out match_info)) {
				
				var tmp = match_info.fetch(0);
				
				this.season=tmp.substring(1,2).to_int();
				this.chapter=tmp.substring(4,2).to_int();
				
				int p_s;
				int p_e;
				
				match_info.fetch_pos(0, out p_s, out p_e);
				
				previous = filename.substring(0,p_s);
				next = filename.substring(p_e-1,-1);
				
			} else {
				if (season2.match(filename, 0, out match_info)) {

					var tmp = match_info.fetch(0);
					
					this.season=tmp.substring(1,1).to_int();
					this.chapter=tmp.substring(3,2).to_int();
					
					int p_s;
					int p_e;
					
					match_info.fetch_pos(0, out p_s, out p_e);
					
					previous = filename.substring(0,p_s+1);
					next = filename.substring(p_e-1,-1);
					
				}
			}
			stdout.printf("antes: %s\ndespues: %s\ntemporada %d\ncapitulo %d\n",previous,next,this.season,this.chapter);*/
		}
	}
}