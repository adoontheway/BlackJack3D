package uiimpl 
{
	import game.ui.mui.ButtonGroupUI;
	
	/**
	 * ...
	 * @author jerry.d
	 */
	public class Buttons extends ButtonGroupUI 
	{
		
		public function Buttons() 
		{
			super();
			this.x = 780;
			this.y = 530;
		}
		private static var _instance:Buttons;
		public static function get Instance():Buttons{
			if ( Buttons._instance == null){
				Buttons._instance = new Buttons();
			}
			return Buttons._instance;
		}
	}

}