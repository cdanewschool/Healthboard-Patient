package events
{
	import flash.events.Event;
	
	import models.Bookmark;
	
	public class BookmarkEvent extends Event
	{
		public static const ADD:String = "BookmarkEvent.ADD";
		public static const EDIT:String = "BookmarkEvent.EDIT";
		public static const DELETE:String = "BookmarkEvent.DELETE";
		
		public var bookmark:Bookmark;
		
		public function BookmarkEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, bookmark:* = null )
		{
			super(type, bubbles, cancelable);
			
			this.bookmark = bookmark;
		}
		
		override public function clone():Event
		{
			return new BookmarkEvent(type, bubbles, cancelable, bookmark);
		}
	}
}