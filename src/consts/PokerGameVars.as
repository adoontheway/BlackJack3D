package consts 
{
	import flash.display.Stage;
	/**
	 * ...
	 * @author jerry.d
	 */
	public class PokerGameVars 
	{
		
		public static var Model:uint = 0;
		public static var Desk:uint = 0;
		
		public static const CHIP_SHOWS:Object = {
			1:'1',
			2:'2',
			5:'5',
			10:'10',
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
			'1':{x:615, k:0, b:240},//未分牌 1
			'2':{x:375, k:0, b:290},// 未分牌 2
			'3':{x:145, k:0, b:240},//未分牌 3
			'4':{x:0,y:0, k:0, b:0},//分牌 1
			'5':{x:0, y:0, k:0, b:0},//分牌 2
			'6':{x:0, y:0, k:0, b:0},//分牌 3
			'7':{x:0,y:0, k:0, b:0},//分牌 4
			'8':{x:0, y:0, k:0, b:0},//分牌 5
			'9':{x:0,y:0, k:0, b:0}//分牌 6
		};
		
			public static const Circle_Pos:Object = {
				'3':{x:145, y:240},
				'2':{x:375, y:290},
				'1':{x:615,y:240}
			};
		
		public static const DESK_TIMES:Array = [45000,60000,75000];
		public static const Model_Config:Object = {
		0:[1, 2, 5, 10, 50, 100, 1000],
		1:[100, 200, 300, 500, 600, 800, 1000],
		2:[1000, 2000, 3000, 5000, 6000, 8000, 10000]
		};
		
		public static const Chars:Array = ['A','2','3','4','5','6','7','8','9','10','J','Q','K'];
	
	}

}