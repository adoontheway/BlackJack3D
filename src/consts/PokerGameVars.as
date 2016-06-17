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
		
			public static const TABLE_POS:Object = {
				'0':{x:240,y:100},//banker
				'1':{x:240,y:240},//no split
				'1_0':{x:0, y:0},// split master
				'1_1':{x:0, y:0},//split child
				'2':{x:0,y:0},
				'2_0':{x:0, y:0},
				'2_1':{x:0, y:0},
				'3':{x:0,y:0},
				'4_0':{x:0, y:0},
				'3_1':{x:0,y:0}
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