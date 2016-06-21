package 
{
	import comman.duke.GameUtils;
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
		private var _money:Number = 0;
		public const BANKER:uint = 0;
		private var splitors:Array;

		private var pokerMap:Object = {};
		private var tables:Object = {};
		
		public var mainView:MainViewImpl;
		private var socketMgr:SocketMgr;
		
		private var currentTables:Vector.<int> = new Vector.<int>();
		private var endTables:Vector.<int> = new Vector.<int>();
		public function GameMgr() 
		{
			this.pokerMap = {};
			socketMgr = SocketMgr.Instance;
		}
		
		private var _currentTable:Table;
		
		public function nextTable():void{
			if ( this.currentTables.length != 0 ){
				_currentTable = this.tables[this.currentTables[0]];
			}else{
				_currentTable = null;
			}
		}
		
		public function get currentTable():Table{
			return this._currentTable;
		}
		
		
		public function dispense(tableId:uint, card:uint):void{
			var table:Table = this.tables[tableId];
			var poker:PokerImpl = PoolMgr.gain(PokerImpl);//new PokerImpl(card);
			poker.value = card;
			table.addCard(poker);
			if ( table.bust || table.fiveDragon || table.blackjack){
				this.putToEnd(tableId);
			}
			mainView.onDispenseBack(poker);
		}
		
		public function onDispenseComplete():void{
			
		}
		/**
		 * 添加赌注到某桌
		 * 仅限开局使用
		 * **/
		public function betToTable(bet:uint,tableId:int,tabIndex:int):void{
			var table:Table = this.tables[tableId];
			if ( table == null ){
				table = this.tables[tableId] = new Table();
				table.setIndex(tabIndex);
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
			this.currentTables.push(table.tableId);
			if ( this.currentTables.length > 1){
				this.currentTables.sort(Array.NUMERIC);
				this._currentTable = this.tables[this.currentTables[0]];
				GameUtils.log('sort tables:', this.currentTables.join('.'));
			}
		}
		public function onSplitBack(data:Object):void{
			var ttables:Object = data.tables;
			var bet:int = data.bet;
			var tabId:int = data.tabId;
			var rtable:Table = this.tables[tabId];
			var table:Table;
			for (var tablId in ttables ){
				table = this.tables[tablId];
				if ( table != null ){
					table.reset();
					table.actived = true;
					table.split = true;
					table.addCard(ttables[tablId]);
				}else{
					betToTable(bet, tablId, rtable.tableIndex+3);
					table = this.tables[tablId];
					table.addCard(ttables[tablId]);
					this.currentTables.push(tablId);
				}
			}
		}
		public function onStandBack(data:Object):void{
			var tabId:int = data.tabId;
			putToEnd(tabId);
			mainView.onStandBack();
		}
		
		private function putToEnd(tabId:int):void{
			var index:int = this.currentTables.indexOf(tabId);
			this.currentTables.splice(index, 1);
			this.endTables.push(tabId);
			this.nextTable();
		}
		
		public function onEnded():void{
			this.started = false;
		}
	
		public function get money():Number{
			return this._money;
		}
		
		public function set money(_val:Number):void{
			if ( this._money == _val) return;
			this._money = _val;
			if( mainView != null)
				mainView.updateBalance(_val);
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