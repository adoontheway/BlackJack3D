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
	import uiimpl.ChipsViewUIImpl;
	import uiimpl.MainViewImpl;
	import uiimpl.BaseTable;
	import uiimpl.SubTable;
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
		
		public var tableDisplays:Object = {};
		public function registerTableDisplay(id:int, table:BaseTable):void{
			tableDisplays[id] = table;
		}
		public var subTableDisplays:Object = {};
		public function registerSubTableDisplay(id:int, table:SubTable):void{
			subTableDisplays[id] = table;
		}
		
		private var _currentTable:TableData;
		public function nextTable():void{
			if ( this._currentTable != null && this._currentTable.isSplited ){
				this._currentTable = this.tables[this._currentTable.tableId + 3];
				if ( this._currentTable != null && (this._currentTable.blackjack || this._currentTable.points == 21)){
					putToEnd(this._currentTable.tableId);
				}
			}else if ( this.currentTables.length != 0 ){
				_currentTable = this.tables[this.currentTables[0]];
			}else{
				_currentTable = null;
			}
			Buttons.Instance.bindTable(_currentTable);
			checkButtons();
		}
		
		public function get currentTable():TableData{
			return this._currentTable;
		}
	
		private var dispenseTimer:uint = 0;
		private var lastDipenseTime:Number = 0;
		private var dispenseQueue:Array = [];
		public function dispense(tableId:uint, card:int):void{
			dispenseQueue.push(tableId, card);
			if ( dispenseTimer == 0){
				dispenseTimer = setInterval(function():void{
					var tabId:uint = _instance.dispenseQueue.shift();
					var cardId:int = _instance.dispenseQueue.shift();
					_instance.dispenseTo(tabId, cardId);
					
					if ( _instance.dispenseQueue.length == 0 ){
						clearInterval(_instance.dispenseTimer);
						_instance.dispenseTimer = 0;
					}
				}, 600);
			}
		}
		
		public function checkButtons():void{
			if ( starting || this.dispenseQueue.length != 0 ){
				return;
			}
			var table:TableData = tables[0];
			var subTable:SubTable;
			if ( table.points == 1 && !table.insured){
				Buttons.Instance.switchModel(Buttons.MODEL_INSRRUREABLE);
				for (var i in subTableDisplays){
					subTable = tableDisplays[i];
					subTable.btn_insurrance.visible = !subTable.tableData.blackjack;
				}
			}else{
				if ( currentTable != null){
					var tableId:int = _currentTable.tableId;
					_currentTable.display.selected = true;	
				}
				
			}
		}
		
		public function doubleBet():void{
			
		}
		
		public var starting:Boolean = false;
		private function dispenseTo(tableId:uint, card:int):void{
			lastDipenseTime = TickerMgr.SYSTIME;
			GameUtils.log('mgr->dispenseTo :', tableId, card);
			
			var table:TableData = this.tables[tableId];
			
			var poker:Poker = PoolMgr.gain(Poker);
			poker.value = card;
			if ( card != -1){
				starting = false;
				poker.rotationY = 180 ;
			}
			if ( tableId != 0 ){
				table.display.addCard(poker);
			}else{
				if( card != -1 )
					table.addCard(poker);//fake poker
				
				mainView.onDispenseBanker(poker);						
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
		public function betToTable(tableId:int, bet:uint = 0):void{
			if ( bet == 0 ) bet = ChipsViewUIImpl.Instance.currentValue;
			var table:TableData = this.tables[tableId];
			if ( table == null ){
				table = this.tables[tableId] = new TableData(tableId);
				table.display = this.subTableDisplays[tableId];
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
		public function betPair(tableId:int, bet:uint=0):void{
			if ( bet == 0 ) bet = ChipsViewUIImpl.Instance.currentValue;
			if ( bet == 0 ) {
				FloatHint.Instance.show('no chips seleted...');
				return;
			}
			var table:TableData = this.tables[tableId];
			if ( table != null && table.currentBet != 0 ){
				var tableDisplay:BaseTable = this.tableDisplays[tableId];
				tableDisplay.addPairBet(bet);
				table.pairBet = bet;
			}
		}
		public var lastBetData:Object;
		public var lastPairBetData:Object;
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
				}else{
					table.reset();
				}
				table.actived = true;
				lastBetData = betObj;
				lastPairBetData = pairBet;
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
		
		public function onInsureBack(data:Object):void{
			//1 播放庄家第二张牌的动画
			//2 播放筹码得失动画
			//3 更新余额
			
			var result:int = data.result;
			var win:Boolean = data.win;
			var tableDisplay:SubTable;
			for (var i:String in subTableDisplays){
				tableDisplay = subTableDisplays[i];
				if ( result[i] != null ){
					tableDisplay.onInsureBack(result[i]);
				}else{
					tableDisplay.btn_insurrance.visible = false;
				}
				
			}
			this.money = data.money;
			mainView.updateBalance(this.money);
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
			mainView.onRoundEnd();
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
			var table:TableData;
			var poker:Poker;

			for (var tablId in ttables ){
				table = this.tables[tablId];
				poker = pokerMap[ttables[tablId]];
				poker.x = 0 ;
				poker.y = 0;
				poker.rotation = 0;
				if ( table != null ){
					table.reset();
					table.actived = true;
					table.isSplited = true;
					table.display.poker_con.addChild(poker);
				}else{
					betToTable(tablId, bet);
					table = this.tables[tablId];
					this.currentTables.push(tablId);
					table.display.poker_con.addChild(poker);
				}
				table.addCard(poker);
			}
		}
		
		public function onStandBack(data:Object):void{
			var tabId:int = data.tabId;
			putToEnd(tabId);
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
			var table:TableData = tables[tabId];
			table.display.selected = false;
			this.endTables.push(tabId);
			
			GameUtils.log('after ', this.currentTables.join('.'), ' vs ', this.endTables.join('.'));
			this.nextTable();
		}
		
		public function onTableEnd(data:Object):void{
			var table:TableData = this.tables[data.tabId];
			var startX:int = 100;
			var startY:int = 50;
			var pos:Point = table.display.localToGlobal(new Point(100,50))
			if ( data.result == -1){
				NumDisplay.show( -data.gain, pos.x,  pos.y);
			}else if ( data.result == 1){
				NumDisplay.show( data.gain, pos.x, pos.y);
			}else{
				FloatHint.Instance.show('DRAW ROUND!',pos.x, pos.y);
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