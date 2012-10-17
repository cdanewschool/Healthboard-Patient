package models
{
	import flash.utils.describeType;

	public class Bookmark
	{
		public var index:int;
		public var label:String;
		
		public function Bookmark( label:String = null, index:int = -1 )
		{
			this.label = label;
			this.index = index;
		}
		
		public function clone():Bookmark
		{
			var val:Bookmark = new Bookmark();
			val.label = this.label;
			val.index = this.index;
			
			return val;
		}
	}
}