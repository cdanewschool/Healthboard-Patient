package edu.newschool.piim.healthboard.model
{
	import mx.collections.ArrayCollection;

	public class UserPreferences extends Preferences
	{
		public function UserPreferences()
		{
			super();
		}
		
		public static function fromObj( data:Object ):UserPreferences
		{
			var val:UserPreferences = new UserPreferences();
			
			for (var prop:String in data)
			{
				if( val.hasOwnProperty( prop ) )
				{
					try
					{
						if( val[prop] is ArrayCollection )
						{
							val[prop] = data[prop] is ArrayCollection ? data[prop] : new ArrayCollection( [ data[prop] ] );
						}
						else
						{
							val[prop] = data[prop];
						}
					}
					catch(e:Error){}
				}
			}
			
			return val;
		}
	}
}