package 
{
	import comman.duke.FloatHint;
	import comman.duke.GameUtils;
	import comman.duke.PoolMgr;
	import model.*;
	import comman.duke.TickerMgr;
	import flash.geom.Point;
	import flash.utils.*;
	import uiimpl.Buttons;
	import uiimpl.MainViewImpl;
	import uiimpl.BaseTable;
	import utils.NumDisplay;
	/**
	 * ...
	 * @author jerry.d
	 */
	public class GameMgr 
	{
		public var desk:uint = 0;//0 单桌 1 三桌
		public var model:uint = 0;//0,1,2筹码大小
		public var started:Boolean = false;
		public var ME:uint = 1;
		private var _money:Number = 0;
		public const BANKER:uint = 0;
		private var splitors:Array;

		private var pokerMap:Object = {};
		private var tables:Object = {};
		
		public var mainView:MainViewImpl;
		private var socketMgr:SocketMgr;
		
		private var currentTables:Array = [];
		private var endTables:Array = [];
		
		public var needShowInsure:Boolean;
		public function GameMgr() 
		{
			this.pokerMap = {};
			socketMgr = SocketMgr.Instance;
		}
		
		private var tableDisplays:Object = {};
		public function registerTableDisplay(id:int, table:BaseTable):void{
			tableDisplays[id] = table;
		}
		
		private var _currentTable:TableData;
		public function nextTable():void{
			if ( this._currentTable != null && this._currentTable.split ){
				this._currentTable = this.tables[this._currentTable.tableId + 3];
				if ( this._currentTable != null && (this._currentTable.blackjack || this._currentTable.points == 21)){
					putToEnd(this._currentTable.tableId);
				}
			}else if ( this.currentTables.length != 0 ){
				_currentTable = this.tables[this.currentTables[0]];
			}else{
				_currentTable = null;
			}
		}
		
		public function get currentTable():TableData{
			return this._currentTable;
		}
	
		private var dispenseTimer:uint = 0;
		private var lastDipenseTime:Number = 0;
		private var dispenseQueue:Array = [];
		public function dispense(tableId:uint, card:int):void{
			if ( lastDipenseTime == 0){
				lastDipenseTime = TickerMgr.SYSTIME;
				dispenseTo(tableId, card);
			}else if ( TickerMgr.SYSTIME - lastDipenseTime > 1000 && dispenseQueue.length == 0){
				lastDipenseTime = TickerMgr.SYSTIME;
				dispenseTo(tableId, card);
			}else{
				dispenseQueue.push(tableId, card);
				if ( dispenseTimer == 0){
					dispenseTimer = setInterval(function():void{
						var tabId:uint = _instance.dispenseQueue.shift();
						var cardId:int = _instance.dispenseQueue.shift();
						_instance.dispenseTo(tabId, cardId);
						
						if ( _instance.dispenseQueue.length == 0 ){
							clearInterval(_instance.dispenseTimer);
						}
					}, 600);
				}
				return;
			}
			
		}
		
		public function checkButtons():void{
			if ( starting || this.dispenseQueue.length != 0 ){
				return;
			}
			var table:TableData = tables[0];
			var tableDisplay:BaseTable;
			if ( table.points == 1 && !table.insured){
				Buttons.Instance.switchModel(Buttons.MODEL_INSRRUREABLE);
				for (var i in tableDisplays){
					tableDisplay = tableDisplays[i];
					tableDisplay.btn_insurrance.visible = true;
				}
			}else{
				if ( currentTable != null){
					var tableId:int = _currentTable.tableId;
					if ( tableId <= 3){
						tableDisplay = tableDisplays[_currentTable.tableId];
						tableDisplay.selectTable(0);
					}else{
						tableDisplay = tableDisplays[_currentTable.tableId - 3];
						tableDisplay.selectTable(1);
					}
					Buttons.Instance.switchModel(Buttons.MODEL_NORMAL);
					Buttons.Instance.bindTable(currentTable);
				}
				
			}
		}
		
		public var starting:Boolean = false;
		private function dispenseTo(tableId:uint, card:int):void{
			GameUtils.log('dispenseTo :', tableId,card);
			var table:TableData = this.tables[tableId];
			var poker:Poker = PoolMgr.gain(Poker);
			poker.value = card;
			if ( card != -1){
				starting = false;
				poker.rotationY = 180 ;
			}
			if ( tableId > 3 ){
				var tableDisplay:BaseTable = this.tableDisplays[tableId - 3];
				tableDisplay.addCardTo(poker,1);
			}else{
				if ( tableId != 0){
					tableDisplay = this.tableDisplays[tableId];
					tableDisplay.addCardTo(poker);
				}else{
					if( card != -1 )
						table.addCard(poker);
					
					if ( table.numCards != 2){
						mainView.onDispenseBanker(poker);						
					}else if ( table.numCards == 2){//翻牌就可以了
						mainView.traverseTheFakePoker(card);
					}
				}
			}
			
			pokerMap[card] = poker;
			if ( table.bust || table.fiveDragon || table.blackjack || table.points == 21 || ( table.hasA && table.points == 11)){
				this.putToEnd(tableId);
			}
			this.checkButtons();
		}
		
		/**
		 * 添加赌注到某桌
		 * 仅限开局使用
		 * **/
		public function betToTable(bet:uint,tableId:int):void{
			var table:TableData = this.tables[tableId];
			if ( table == null ){
				table = this.tables[tableId] = new TableData(tableId);
				if ( tableId <= 3){
					var tableDisplay:BaseTable = this.tableDisplays[tableId];
				}else{
					tableDisplay = this.tableDisplays[tableId-3];
				}
				
				tableDisplay.setTableData(table, tableId <= 3 );
			}else{
				table.reset();
			}
			table.actived = true;
			table.currentBet = bet;
			
		}
		/**
		 * 赌对子
		 * 仅限开局使用
		 * **/
		public function betPair(bet:uint,tableId:int):Boolean{
			var table:TableData = this.tables[tableId];
			if ( table != null && table.currentBet != 0 ){
				//table = this.tables[tableId] = new TableData(tableId);
				var tableDisplay:BaseTable = this.tableDisplays[tableId];
				tableDisplay.setTableData(table, true );
				table.pairBet = bet;
				return true;
			}else{
				return false;
			}
		}
		/**
		 * 清桌
		 * */
		public function cleanTables():void{
			var table:TableData;
			var tableDisplay:BaseTable;
			for (var key in this.tables){
				if ( key == 0) continue;
				table = tables[key];
				table.pairBet = 0;
				table.currentBet = 0;
				table.actived = false;
				tableDisplay = tableDisplays[key];
				tableDisplay.reset();
			}
		}
		/**
		 * 开始游戏
		 * */
		public function start():Boolean{
			var betObj:Object = {};
			var pairBet:Object = {};
			var table:TableData;
			var got:Boolean;
			var gotPair:Boolean;
			for (var key in this.tables){
				table = tables[key];
				if ( table.currentBet != 0){
					got = true;
					betObj[table.tableId] = table.currentBet;
				}
				if ( table.pairBet != 0 && table.currentBet != 0 ){
					gotPair = true;
					pairBet[table.tableId] = table.pairBet;
				}
			}
			if (got){
				table = this.tables[0];
				if ( table == null ){
					table = this.tables[0] = new TableData(0);
					//table.setIndex(0);
				}else{
					table.reset();
				}
				table.actived = true;
				if (!gotPair){
					socketMgr.send({proto:ProtocolClientEnum.PROTO_START, bet:betObj });
				}else{
					socketMgr.send({proto:ProtocolClientEnum.PROTO_START, bet:betObj, pair:pairBet });
				}
				starting = true;
				return true;
			}else{
				FloatHint.Instance.show('no bet');
				return false;
				//mainView.showBtns(MainViewImpl.START);
			}
		}
		
		public function onRoundEnd():void{
			this.started = false;
			Buttons.Instance.switchModel(Buttons.MODEL_END);
		}
		
		public function reset():void{
			for (var key in this.tables){
				tables[key].reset();
			}
			for ( key in this.tableDisplays){
				tableDisplays[key].reset();
			}
			pokerMap = {};
			this.currentTables = [];
			this.endTables = [];
			enableDisplayMouse(true);
		}
		
		public function enableDisplayMouse(value:Boolean):void{
			var tableDisplay:BaseTable;
			for (var key in this.tableDisplays){
				tableDisplay = tableDisplays[key];
				tableDisplay.table.mouseChildren = tableDisplay.pair.mouseChildren = tableDisplay.table.mouseEnabled = tableDisplay.pair.mouseEnabled = value;
			}
		}
		
		public function onStarted(tabelIds:Array):void{
			this.started = true;
			var table:TableData ;
			this.currentTables = tabelIds;
			for each(var tableId:int in tables){
				table = tables[tableId];
				table.actived = true;
			}
			enableDisplayMouse(false);
			if ( this.currentTables.length > 1){
				this.currentTables.sort(Array.NUMERIC);
				GameUtils.log('sort tables:', this.currentTables.join('.'));
			}
			this._currentTable = this.tables[this.currentTables[0]];
		}
		
		public function onSplitBack(data:Object):void{
			var ttables:Object = data.tables;
			var bet:int = data.bet;
			var tabId:int = data.tabId;
			var card0:Poker;
			
			var rtable:TableData = this.tables[tabId];
			var table:TableData;
			var poker:Poker;
			var tableDisplay:BaseTable = tableDisplays[tabId];
			for (var tablId in ttables ){
				table = this.tables[tablId];
				poker = pokerMap[ttables[tablId]];
				poker.x = 0 ;
				poker.y = 0;
				poker.rotation = 0;
				if ( table != null ){
					table.reset();
					table.actived = true;
					table.split = true;
					tableDisplay.poker_con_1.addChild(poker);
				}else{
					betToTable(bet, tablId);
					table = this.tables[tablId];
					this.currentTables.push(tablId);
					tableDisplay.poker_con_2.addChild(poker);
				}
				table.addCard(poker);
				
			}
		}
		
		public function onStandBack(data:Object):void{
			var tabId:int = data.tabId;
			putToEnd(tabId);
			mainView.onStandBack();
		}
		
		public function onDoubleBack(data:Object):void{
			var tabId:int = data.tabId;
			var table:TableData = this.tables[tabId];
			var moreBet:int = data.bet - table.currentBet;
			table.currentBet = data.bet;
			putToEnd(tabId);
			mainView.onDoubleBack(data.tabId, moreBet);
		}
		
		private function putToEnd(tabId:int):void{
			GameUtils.log('Before put ', tabId, 'to the end', this.currentTables.join('.'), ' vs ', this.endTables.join('.'));
			var index:int = this.currentTables.indexOf(tabId);
			if ( index != -1){
				this.currentTables.splice(index, 1);
			}
			this.endTables.push(tabId);
			
			GameUtils.log('after ', this.currentTables.join('.'), ' vs ', this.endTables.join('.'));
			this.nextTable();
		}
		
		public function onTableEnd(data:Object):void{
			var table:TableData = this.tables[data.tabId];
			var startX:int = 100;
			var startY:int = 50;
			if ( data.tabId <= 3){
				var tableDisplay:BaseTable = this.tableDisplays[data.tabId];
			}else {
				tableDisplay = this.tableDisplays[data.tabId - 3];
				startY = 0;
			}
			var pos:Point = tableDisplay.localToGlobal(new Point(100,50))
			if ( data.result == -1){
				NumDisplay.show( -data.gain, pos.x,  pos.y);
			}else if ( data.result == 1){
				NumDisplay.show( data.gain, pos.x, pos.y);
			}else{
				//FloatHint.Instance.show('DRAW ROUND!',table.arrowX, table.arrowY);
			}
			
		}
		
		public function getInsuredTables():Array{
			var result:Array = []
			var table:TableData;
			for each (var i:int in this.currentTables){
				table = this.tables[i];
				if ( table.insured){
					result.push(i);
				}
			}
			return result;
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