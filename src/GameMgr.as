package 
{
	import comman.duke.PoolMgr;
	import model.*;
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
		private var socketMgr:SocketMgr;
		public function GameMgr() 
		{
			this.pokerMap = {};
			socketMgr = SocketMgr.Instance;
		}
		
		private var _currentTable:Table;
		public function get currentTable():Table{
			if ( _currentTable == null ){
				var idx = 1; 
				while (idx < 10){
					_currentTable = this.tables[idx];
					if ( _currentTable.actived){
						return _currentTable;
					}
				}
			}
			return null;
		}
		
		public function nextTable():Table{
			return null;
		}
		
		private var mainView:MainViewImpl;
		public function dispense(tableId:uint, card:uint):void{
			var table:Table = this.tables[tableId];
			var poker:PokerImpl = PoolMgr.gain(PokerImpl);//new PokerImpl(card);
			poker.value = card;
			table.addCard(poker);
			if ( mainView == null){
				mainView = MainViewImpl.Instance;
			}
			mainView.onDispenseBack(poker);
		}
		
		public function onDispenseComplete():void{
			
		}
		/**
		 * 添加赌注到某桌
		 * 仅限开局使用
		 * **/
		public function betToTable(bet:uint,tableIndex:int):void{
			var table:Table = this.tables[tableIndex];
			if ( table == null ){
				table = this.tables[tableIndex] = new Table();
				table.setIndex(tableIndex);
			}else{
				table.reset();
			}
			table.actived = true;
			table.currentBet = bet;
		}
		/**
		 * 清桌
		 * */
		public function cleanTables():void{
			var table:Table;
			for (var key in this.tables){
				table = tables[key];
				table.currentBet = 0;
				table.actived = false;
			}
		}
		/**
		 * 开始游戏
		 * */
		public function start():void{
			var betObj:Object = {};
			var table:Table;
			var got:Boolean;
			for (var key in this.tables){
				table = tables[key];
				if ( table.currentBet != 0){
					got = true;
					table.tableId = table.tableIndex;
					betObj[table.tableId] = table.currentBet;
				}
			}
			if (got){
				table = this.tables[0];
				if ( table == null ){
					table = this.tables[0] = new Table();
					table.setIndex(0);
				}else{
					table.reset();
				}
				table.actived = true;
				socketMgr.send({proto:ProtocolClientEnum.PROTO_START, bet:betObj });
			}
		}
		
		public function onRoundEnd():void{
			for (var key in this.tables){
				tables[key].reset();
			}
		}
		public function onStarted(tabelId:int):void{
			this.started = true;
			var table:Table = this.tables[tabelId];
			table.actived = true;
		}
		
		public function onEnded():void{
			this.started = false;
		}
	
		private static var _instance:GameMgr;
		public static function get Instance():GameMgr{
			if ( GameMgr._instance == null ){
				GameMgr._instance = new GameMgr();
			}
			return GameMgr._instance;
		}
	}

}