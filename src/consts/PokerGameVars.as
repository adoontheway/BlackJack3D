package consts 
{
	import flash.display.Stage;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	/**
	 * ...
	 * @author jerry.d
	 */
	public class PokerGameVars 
	{
		/**
		 * [V] for version
		 * [date]
		 * [serial in this day]
		 * [d] development:development, production:production
		 * **/
		private static const LOCAL_VERSION:String = "V20160926-01";
		public static var VERSION:String;
		
		public static var NEED_CRYPTO:Boolean = true;
		
		public static var TempInsureCost:int = 0;
		
		public static var resRoot:String = '';
		
		public static var ChipLostPos:Point = new Point(350, 70);
		public static var ChipGainPos:Point = new Point(850, 50);
		public static var DispensePostion:Point = new Point(612, 100);
		public static var DispenseMiddlePostion:Point = new Point(600, 180);
		public static var DisaprearPoint:Point = new Point(50, 80);
		
		public static var Glow_Filter:GlowFilter = new GlowFilter(0xcccccc, 0.5);
		public static var YELLOW_Glow_Filter:GlowFilter = new GlowFilter(0xffff00, 1, 8, 8, 1, 2);
		public static var Drop_Shadow_Filter_LONGWAY:DropShadowFilter = new DropShadowFilter(40, 100, 0, 0.4, 40, 40, 3);
		public static var Drop_Shadow_Filter_SHORTWAY:DropShadowFilter = new DropShadowFilter(5, 75, 0, 0.7, 10, 10, 2);
		public static const Reminder_Filter:BlurFilter = new BlurFilter(4, 4, 2);
		
		public static var Gray_Filter:ColorMatrixFilter = new ColorMatrixFilter(
		[0.3086, 0.6094, 0.0820, 0, 0,
		0.3086, 0.6094, 0.0820, 0, 0,
		0.3086, 0.6094, 0.0820, 0, 0,
		0,      0,      0,      1, 0]);
		
		public static const ALL_CHIP_VALUE:Array = [1,2,5,10,20,50,100,500,1000,2000];
		public static const CHIP_SHOWS:Object = {
			1:'1',
			2:'2',
			5:'5',
			10:'10',
			20:'20',
			50:'50',
			100:'100',
			200:'200',
			300:'300',
			500:'500',
			600:'600',
			800:'800',
			1000:'1K',
			2000:'2K',
			3000:'3K',
			5000:'5K',
			6000:'6K',
			8000:'8K',
			10000:'1W'
		};
		/** bet down limit, bet up limit, pairbet down limit, pairbet up limit **/
		public static const LIMITS:Array = [1, 500, 1, 50, 50, 6000, 5, 500, 100, 12000, 10, 1000];
		
		public static const Model_Config:Object = {
		0:[1, 5, 10, 20, 50, 100,],
		1:[5, 10, 50, 100, 500, 1000],
		2:[10, 50, 100, 500, 1000, 2000]
		};
		
		public static const Chars:Array = ['A','2','3','4','5','6','7','8','9','10','J','Q','K'];
		
		public static function setUpVersion(env:String):void{
			VERSION = LOCAL_VERSION +"-"+ env;
		}
	}

}