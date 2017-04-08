namespace Submarine {

	public enum DataType {
		UNKNOWN,
		FREETEXT,
		YEAR,
		SEASON_CHAPTER,
		CODEC,
		RESOLUTION,
		SOURCE
	}

	public enum Resolution {
		PAL_NTSC,
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

	public enum Source {
		DVDRIP,
		BDRIP,
		HDTV,
		UNKNOWN
	}

	public class NameParserNode {

		private string text;
		public NameParserNode ?next;
		public unowned NameParserNode ?prev;

		public NameParserNode ?child;

		public NameParserNode ?iterator;

		public Submarine.DataType type;
		public Submarine.Resolution resolution;
		public Submarine.Codec codec;
		public Submarine.Source source;
		public double confidence;
		public int year;
		public int season;
		public int chapter;

		public int level;

		public string get_inner_text() {
			return this.text;
		}

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
			case DataType.SOURCE:
				return "Source";
			default:
				return "Unknown";
			}
		}

		public NameParserNode.empty() {
			this.type=DataType.UNKNOWN;
			this.text="";
			this.child=null;
			this.next=null;
			this.prev=null;
		}

		private void init_all() {
			this.type=DataType.UNKNOWN;
			this.resolution=Resolution.UNKNOWN;
			this.codec=Codec.UNKNOWN;
			this.source=Source.UNKNOWN;
			this.confidence=0.0;
			this.year=-1;
			this.season=-1;
			this.chapter=-1;

		}

		public NameParserNode.new_copy(NameParserNode? p) {

			this.init_all();

			if (p!=null) {

				this.type=p.type;
				this.confidence=p.confidence;
				this.text=p.text;
				this.child=null;
				this.next=null;
				this.prev=null;
				switch(this.type) {
					case Submarine.DataType.YEAR:
						this.year=p.year;
					break;
					case Submarine.DataType.SEASON_CHAPTER:
						this.season=p.season;
						this.chapter=p.chapter;
					break;
					case Submarine.DataType.CODEC:
						this.codec=p.codec;
					break;
					case Submarine.DataType.RESOLUTION:
						this.resolution=p.resolution;
					break;
					case Submarine.DataType.SOURCE:
						this.source=p.source;
					break;
					default:
					break;
				}
			} else {
				stderr.printf("Copiando NULL\n");
			}
		}

		public NameParserNode(string txt, NameParserNode ?thenext=null, int c_level=2) {

			this.init_all();

			this.level=c_level;
			this.type=DataType.UNKNOWN;
			this.text=txt;
			this.next=thenext;
			this.prev=null;
			this.prev=null;
			this.child=null;
			this.split(' ');
			this.split('-');
			this.split('_');
			this.split('.');
			this.split('[');
			this.split(']');
			this.split('{');
			this.split('}');

			if (this.check_pattern("s\\d\\de\\d\\d",6,DataType.SEASON_CHAPTER)) {
				// Check sAAeBB Season/Episode
				this.season=int.parse(this.text.substring(1,2));
				this.chapter=int.parse(this.text.substring(4,2));
			} else if (this.check_pattern("\\d\\dx\\d\\d",5,DataType.SEASON_CHAPTER)) {
				// Check AAxBB Season/Episode
				this.season=int.parse(this.text.substring(0,2));
				this.chapter=int.parse(this.text.substring(3,2));
				this.confidence*=0.9; // a little less confidence to this format
			} else if (this.check_pattern("\\dx\\d\\d",4,DataType.SEASON_CHAPTER)) {
				// Check AxBB Season/Episode
				this.season=int.parse(this.text.substring(0,1));
				this.chapter=int.parse(this.text.substring(2,2));
				this.confidence*=0.9; // a little less confidence to this format
			}

			// Check for year
			if (this.check_pattern("\\(\\d\\d\\d\\d\\)",6,DataType.YEAR)) {
				this.year=int.parse(this.text.substring(1,4));
			} else if (this.check_pattern("\\d\\d\\d\\d",4,DataType.YEAR)) {
				this.year=int.parse(this.text.substring(0,4));
			}

			// Check for resolution
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

			// Check for source

			if (this.check_pattern("bdrip",5,DataType.SOURCE)) {
				this.source=Source.BDRIP;
			} else if (this.check_pattern("dvdrip",6,DataType.SOURCE)) {
				this.source=Source.DVDRIP;
			} else if (this.check_pattern("hdtv",4,DataType.SOURCE)) {
				this.source=Source.HDTV;
			}
		}

		private bool check_pattern(string pattern,int length,Submarine.DataType type) {

			MatchInfo match_info;

			var i_year = new GLib.Regex(pattern,RegexCompileFlags.CASELESS);
			if (i_year.match(this.text, 0, out match_info)) {
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

		private void split(unichar character, unichar? c1=null, unichar? c2=null) {
			var pos=this.text.index_of_char(character);
			if (pos==0) {
				this.text=this.text.substring(1);
			} else if (pos>0) {
				var l = this.text.length-1;
				if (pos==l) {
					this.text=this.text.substring(0,l);
				} else {
					var t1=this.text.substring(0,pos);
					if (c2!=null) {
						t1+=(string)c2;
					}
					var t2=this.text.substring(pos+1);
					if (c1!=null) {
						t2+=(string)c1;
					}
					var newchild = new NameParserNode(t2,this.next,this.level);
					this.text=t1;
					this.next=newchild;
				}
			}
		}

		/*private void dsplit(unichar c1, unichar c2) {
			this.split(c1,null,c1);
			this.split(c2,c2,null);
		}*/

		public void print_content() {
			stderr.printf("%s (%s %f) ",this.text,this.return_type(),this.confidence);
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

		public string title;
		public int year;
		public int season;
		public int chapter;
		public Submarine.Resolution resolution;
		public Submarine.Codec codec;
		public Submarine.Source source;

		private NameParserNode ?node;
		private NameParserNode ?iterator;

		private void reset_iterator() {
			this.iterator=null;
			if (this.node!=null) {
				this.node.reset_iterator();
			}
		}

		private NameParserNode? get_next_iterator() {

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

		/* public void print_data(NameParserNode tree) {

			NameParserNode? element1;

			stderr.printf("\n\n");
			for(element1=tree;element1!=null;element1=element1.next) {
				element1.print_content();
			}
			stderr.printf("\n\n");
		}

		public void print_data2() {
			stderr.printf("Title: %s\nSeason %d, chapter %d\n",this.title,this.season,this.chapter);
		}*/

		public NameParser(File file) {

			// find season/chapter

			var tmp=file.get_basename();
			var pos = tmp.last_index_of(".");
			var filename=tmp.substring(0,pos);
			//var extension=tmp.substring(pos+1);

			// process the filename and create the data tree
			node=new NameParserNode(filename);

			// create a linear tree with the processed elements

			NameParserNode ?element1;
			NameParserNode ?element2;
			NameParserNode ?tree=null;
			unowned NameParserNode ?last=null;

			this.reset_iterator();
			do {
				element1=this.get_next_iterator();
				if (element1==null) {
					break;
				}
				element2=new NameParserNode.new_copy(element1);
				if (tree==null) {
					tree=element2;
				}
				if (last!=null) {
					last.next=element2;
				}
				element2.prev=last;
				last=element2;
			} while(true);

			// Group same elements and increase their confidence

			for(element1=tree;element1!=null;element1=element1.next) {
				for(element2=element1.next;element2!=null;element2=element2.next) {
					if ((element1.type!=DataType.UNKNOWN)&&(element1.type==element2.type)) {
						bool are_equal;

						are_equal=false;

						switch(element1.type) {
						case Submarine.DataType.YEAR:
							if (element1.year==element2.year) {
								are_equal=true;
							}
						break;
						case Submarine.DataType.SEASON_CHAPTER:
							if ((element1.season==element2.season)&&(element1.chapter==element2.chapter)) {
								are_equal=true;
							}
						break;
						case Submarine.DataType.CODEC:
							if (element1.codec==element2.codec) {
								are_equal=true;
							}
						break;
						case Submarine.DataType.RESOLUTION:
							if (element1.resolution==element2.resolution) {
								are_equal=true;
							}
						break;
						case Submarine.DataType.SOURCE:
							if (element1.source==element2.source) {
								are_equal=true;
							}
						break;
						default:
						break;
						}
						if (are_equal==true) {

							// Combine the confidence of both elements
							element1.confidence=element1.confidence+element2.confidence-element1.confidence*element2.confidence;

							// and remove the element2
							if (last==element2) {
								last=element2.prev;
							}
							element2.prev.next=element2.next;
							element2.prev=null;
						}
					}
				}
			}

			// finally, take the element with the biggest confidence

			this.title="";
			this.year=-1;
			this.season=-1;
			this.chapter=-1;
			this.resolution=Resolution.UNKNOWN;
			this.codec=Codec.UNKNOWN;
			this.source=Source.UNKNOWN;

			double year_confidence=0.0;
			double season_confidence=0.0;
			double resolution_confidence=0.0;
			double codec_confidence=0.0;
			double source_confidence=0.0;

			bool doing_title=true;

			for(element1=tree;element1!=null;element1=element1.next) {
				switch(element1.type) {
				case Submarine.DataType.YEAR:
					doing_title=false;
					if (element1.confidence>year_confidence) {
						year_confidence=element1.confidence;
						this.year=element1.year;
					}
				break;
				case Submarine.DataType.SEASON_CHAPTER:
					doing_title=false;
					if (element1.confidence>season_confidence) {
						season_confidence=element1.confidence;
						this.season=element1.season;
						this.chapter=element1.chapter;
					}
				break;
				case Submarine.DataType.CODEC:
					doing_title=false;
					if (element1.confidence>codec_confidence) {
						codec_confidence=element1.confidence;
						this.codec=element1.codec;
					}
				break;
				case Submarine.DataType.RESOLUTION:
					doing_title=false;
					if (element1.confidence>resolution_confidence) {
						resolution_confidence=element1.confidence;
						this.resolution=element1.resolution;
					}
				break;
				case Submarine.DataType.SOURCE:
					doing_title=false;
					if (element1.confidence>source_confidence) {
						source_confidence=element1.confidence;
						this.source=element1.source;
					}
				break;
				case Submarine.DataType.UNKNOWN:
					if (doing_title) {
						if(element1.get_inner_text().length>0) {
							if (this.title!="") {
								this.title+=" ";
							}
							this.title+=element1.get_inner_text().down();
						}
					}
				break;
				default:
				break;
				}
			}
		}
	}
}
