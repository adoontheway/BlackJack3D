package 
{
	import model.Table;
	import uiimpl.MainViewImpl;
	import uiimpl.PokerImpl;
	/**
	 * ...
	 * @author jerry.d
	 */
	public class GameMgr 
	{
		public var desk:uint = 0;//0 单桌 1 三桌
		public var model:uint = 1;//0,1,2筹码大小
		public var started:Boolean = false;
		public var ME:uint = 1;
		public var money:uint = 0;
		public const BANKER:uint = 0;
		private var splitors:Array;

		private var pokerMap:Object = {};
		private var tables:Object = {};
		public function GameMgr() 
		{
			this.pokerMap = {};
		}
		
		public function addTable(gameIndex:int):void{
			var table:Table = this.tables[gameIndex];
			if ( table == null ){
				this.tables[gameIndex] = new Table(gameIndex);
			}else{
				table.reset();
			}
		}
		private var mainView:MainViewImpl;
		public function dispense(tableId:uint, card:uint):void{
			var table:Table = this.tables[tableId];
			var poker:PokerImpl = new PokerImpl(card);
			table.addCard(poker);
			mainView.onDispenseBack(poker);
		}
		public function onDispenseComplete():void{
			
		}
		public function addBet(bet:uint):void{
			
		}
		public function onRoundEnd(data:Object):void{
			this.money = data.money;
		}
		public function onStarted(tabelIndex:int):void{
			this.started = true;
			this.tables[tabelIndex] = new Table(tabelIndex);
			if ( mainView == null ){
				mainView = MainViewImpl.Instance;
			}
		}
		
		public function onEnded():void{
			this.started = false;
		}
		/**
		public function caculate(id:int):uint{
			var card:Array = this.playerCard[id];
			var hasA:Boolean = false;//todo multi A
			var index:int = 0;
			var len:int = card.length;
			var points:int = 0;
			var point:int = 0;
			while ( index < len){
				point = (card[index] - 1) % 13 + 1;
				if ( point == 1){
					hasA = true;
				}else if ( point >= 10){
					points += 10;
				}else{
					points += point;
				}
				index++;
			}
			if ( hasA ){
				if ( points + 11 <= 21 ){
					return points + 11;
				}else{
					return points + 1;
				}
			}
			return points;
		}
		*/
	
		private static var _instance:GameMgr;
		public static function get Instance():GameMgr{
			if ( GameMgr._instance == null ){
				GameMgr._instance = new GameMgr();
			}
			return GameMgr._instance;
		}
	}

}