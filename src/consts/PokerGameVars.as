package consts 
{
	import flash.display.Stage;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	/**
	 * ...
	 * @author jerry.d
	 */
	public class PokerGameVars 
	{
		
		public static const VERSION:String = "V20160808-06-dev";
		
		public static var Model:uint = 0;
		public static var Desk:uint = 0;
		
		public static var resRoot:String = '';
		
		public static var ChipLostPos:Point = new Point(350, 70);
		public static var ChipGainPos:Point = new Point(850, 100);
		public static var DispensePostion:Point = new Point(612, 50);
		public static var DisaprearPoint:Point = new Point(50, 80);
		public static var Glow_Filter:GlowFilter = new GlowFilter(0xcccccc, 0.5);
		public static var YELLOW_Glow_Filter:GlowFilter = new GlowFilter(0xffff00, 1, 8, 8, 1, 2);
		public static var Drop_Shadow_Filter_LONGWAY:DropShadowFilter = new DropShadowFilter(40, 100, 0, 0.4, 40, 40, 3);
		public static var Drop_Shadow_Filter_SHORTWAY:DropShadowFilter = new DropShadowFilter(5, 75, 0, 0.7, 10, 10, 2);
		public static const Reminder_Filter:BlurFilter = new BlurFilter(4, 4, 2);
		public static var Reminder_Perspective:PerspectiveProjection ;
		
		public static var Gray_Filter:ColorMatrixFilter = new ColorMatrixFilter(
		[0.3086, 0.6094, 0.0820, 0, 0,
		0.3086, 0.6094, 0.0820, 0, 0,
		0.3086, 0.6094, 0.0820, 0, 0,
		0,      0,      0,      1, 0]);
		public static const ALL_CHIP_VALUE:Array = [1,2,5,10,50,100,200,300,500,600,1000,2000,3000,5000,6000,8000,10000];
		public static const CHIP_SHOWS:Object = {
			1:'1',
			2:'2',
			5:'5',
			10:'10',
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
		/** 
		 * 每个位置的信息 庄家 0 1-3未分牌的1-3号位置 4-6分牌后的1-3号位置 7-9分牌后的1-3号从位 
		 * x，y 起始点
		 * k 斜率方程 y = k * x + b; 也用来计算牌的rotation = ctg(k)
		 * b 斜率方程相关
		 * **/
		public static const TABLE_POS:Object = {
			'0':{x:300, k:0, b:100},//庄家
			'1':{x:580, k:-0.6, b:610,sx:550,sk:-0.6,sb:650},//未分牌 1
			'2':{x:375, k:0, b:290,sx:400,sk:0,sb:290},// 未分牌 2
			'3':{x:145, k:1, b:95, sx:160, sk:1, sb:85},//未分牌 3
			
			'4':{x:510, k:-0.8, b:690},//分牌 1
			'5':{x:350, k:0, b:290},//分牌 2 3
			'6':{x:130, k:1, b:105}//分牌 3
		};
		
			public static const Circle_Pos:Object = {
				'3':{x:145, y:240},
				'2':{x:375, y:290},
				'1':{x:615,y:240}
			};
		
		public static const DESK_TIMES:Array = [45000,60000,75000];
		public static const Model_Config:Object = {
		0:[1, 2, 5, 10, 50, 100,],
		1:[100, 200, 300, 500, 600, 800],
		2:[1000, 2000, 3000, 5000, 6000, 8000]
		};
		
		public static const Chars:Array = ['A','2','3','4','5','6','7','8','9','10','J','Q','K'];
	
	}

}