package ASclasses.immunizations
{
	import mx.charts.AxisRenderer;
	
	public class MyAxisRenderer extends AxisRenderer
	{
		public function MyAxisRenderer()
		{
			super();
		}
		
		/**
		 *  @private
		 */
		private function get labelAlignOffset():Number  
		{
			var result:Number;
			var labelAlign:String = getStyle("labelAlign");
			
			switch (labelAlign)
			{
				case "left":
				case "top":
				{
					result = 1;
					break;
				}
					
				case "right":
				case "bottom":
				{
					result= -2;
					break;
				}
					
				case "center":
				default:
				{
					result = 0.5;
					break;
				}
			}
			
			return result;
		}
	}
}