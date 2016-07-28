package 
{
	import com.greensock.TweenLite;
	import comman.duke.FloatHint;
	import comman.duke.GameUtils;
	import comman.duke.PoolMgr;
	import model.*;
	import comman.duke.ShakeItem;
	import comman.duke.ShakeMgr;
	import comman.duke.SoundMgr;
	import comman.duke.TickerMgr;
	import consts.SoundsEnum;
	import flash.geom.Point;
	import flash.utils.*;
	import uiimpl.BalanceImpl;
	import uiimpl.Buttons;
	import uiimpl.ChipsViewUIImpl;
	import uiimpl.MainViewImpl;
	import uiimpl.BaseTable;
	import uiimpl.SubTable;
	import comman.duke.NumDisplay;
	/**
	 * ...
	 * @author jerry.d
	 */
	public class GameMgr 
	{
		public var desk:uint = 0;//0 单桌 1 三桌
		public var currentModel:uint = 0;//0,1,2筹码大小
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
			//socketMgr = SocketMgr.Instance;
			HttpComunicator.Instance.mgr = this;
			HttpComunicator.Instance.requesAccount();
		}
		
		public var tableDisplays:Object = {};
		public function registerTableDisplay(id:int, table:BaseTable):void{
			tableDisplays[id] = table;
		}
		public var subTableDisplays:Object = {};
		public function registerSubTableDisplay(id:int, table:SubTable):void{
			subTableDisplays[id] = table;
		}
		
		public function getTableDataById(id:int):TableData{
			return tables[id];
		}
		
		private var _currentTable:TableData;
		public function nextTable():void{
			if ( this._currentTable != null && this._currentTable.isSplited && this._currentTable.tableId <= 3){
				GameUtils.log('nextTable0: ',_currentTable.tableId);
				this._currentTable = this.tables[this._currentTable.tableId + 3];
				if ( endTables.indexOf( _currentTable.tableId) != -1){
					_currentTable = null;
					nextTable();
				}else if ( this._currentTable != null && (this._currentTable.blackjack || this._currentTable.points == 21)){
					putToEnd(this._currentTable.tableId);
				}
			}else if ( this.currentTables.length != 0 ){
				GameUtils.log('nextTable 1 ');
				_currentTable = this.tables[this.currentTables[0]];
			}else{
				GameUtils.log('nextTable 2 ');
				_currentTable = null;
			}
			
			if ( _currentTable != null){
				GameUtils.log('select table:', _currentTable.tableId);
			}else{
				var obj:Object = {};
				obj.wayId = HttpComunicator.BANKER_TURN;
				obj.stage = [];
				HttpComunicator.Instance.send(HttpComunicator.BANKER_TURN,obj,0);
				GameUtils.log('select table: null');
			}
			checkButtons();
		}
		
		public function get currentTable():TableData{
			return this._currentTable;
		}
	
		private var dispenseTimer:uint = 0;
		private var lastDipenseTime:Number = 0;
		private var dispenseQueue:Array = [];
		public function dispense(tableId:uint, card:int):void{
			GameUtils.log(tableId,card,' ==> ['+dispenseQueue.join(',')+'] ');
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
				}, 500);
			}
		}
		
		public function checkButtons():void{
			//GameUtils.log('Check Buttons', start, this.dispenseQueue.length);
			if ( starting || this.dispenseQueue.length != 0 ){
				return;
			}
			var table:TableData = tables[0];
			var subTable:SubTable;
			if ( table.points == 1 && !table.insured){
				Buttons.Instance.switchModel(Buttons.MODEL_INSRRUREABLE);
				for (var i in subTableDisplays){
					subTable = subTableDisplays[i];
					if( subTable.visible && subTable.tableData != null && subTable.tableData.actived)
						subTable.btn_insurrance.visible = !subTable.tableData.blackjack;
				}
			}else{
				if ( currentTable != null){
					_currentTable.display.selected = true;	
				}
			}
		}
		
		public var starting:Boolean = false;
		private function dispenseTo(tableId:uint, card:int):void{
			lastDipenseTime = TickerMgr.SYSTIME;
			GameUtils.log('mgr->dispenseTo :', tableId, card);
			
			var table:TableData = this.tables[tableId];
			
			var poker:Poker = PoolMgr.gain(Poker);
			poker.value = card;
			poker.rotation = -75;
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
			if (tableId != 0 &&( table.bust || table.blackjack || table.points == 21 || ( table.hasA && table.points == 11))){
				this.putToEnd(tableId);
			}
			
			if ( dispenseQueue.length == 0)
			{
				if ( !started ){
					this.onRoundEnd();
				}else{
					this.checkButtons();
				}
				
			}
			if ( this.pairResult != null ){
				this.onPairBetResult(pairResult);
			}
		}
		
		/**
		 * 添加赌注到某桌
		 * 仅限开局使用
		 * **/
		public function betToTable(tableId:int, bet:uint = 0):void{
			if ( bet == 0 ) bet = ChipsViewUIImpl.Instance.currentValue;
			if ( bet == 0 ) {
				FloatHint.Instance.show('no chips seleted...');
				//ChipsViewUIImpl.Instance.shakeIt();
				return;
			}
			var table:TableData = this.tables[tableId];
			if ( table == null ){
				table = this.tables[tableId] = new TableData(tableId);
				table.display = this.subTableDisplays[tableId];
				table.display.tableData = table;
			}
			table.currentBet += bet;
			table.actived = true;
			table.display.showBet();
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
				table.pairBet += bet;
				var tableDisplay:BaseTable = this.tableDisplays[tableId];
				tableDisplay.addPairBet(bet);
			}
		}
		public var lastBetData:Object;
		public var lastPairBetData:Object;
		/**
		 * 开始游戏
		 * */
		public function start():Boolean{
			GameUtils.log('mgr.start');
			var obj:Object = {};
			obj.stage = {};
			obj.wayId = HttpComunicator.START;
			
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
					
					obj.stage[table.tableId] = {};
					obj.stage[table.tableId][HttpComunicator.START] = table.currentBet;
				}
				if ( table.pairBet != 0 && table.currentBet != 0 ){
					gotPair = true;
					pairBet[table.tableId] = table.pairBet;
					obj.stage[table.tableId][HttpComunicator.PAIR] = table.pairBet;
				}
			}
			if (got){
				GameUtils.log('mgr.start :', JSON.stringify(obj));
				HttpComunicator.Instance.send(HttpComunicator.START,obj,0);
				table = this.tables[0];
				if ( table == null ){
					mainView.bankerData = table = this.tables[0] = new TableData(0);
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
			}
		}
		
		public function onInsureBack(data:Object):void{
			//1 播放庄家第二张牌的动画
			//2 播放筹码得失动画
			//3 更新余额
			var table:TableData = tables[0];
			table.insured = true;
			var result:Object = data.result;
			bankerBJ = data.isbj;
			var tableDisplay:SubTable;
			for (var i:String in subTableDisplays){
				tableDisplay = subTableDisplays[i];
				if ( result != null && result[i] != null ){
					tableDisplay.onInsureBack(result[i]);
				}
				tableDisplay.btn_insurrance.visible = false;
			}
			this.money = data.money;
			//todo select table
			playCheck();
			if ( bankerBJ ){
				fakeCard = data.card;
				setTimeout(function():void{
					checkButtons();
				}, 1500);
			}
		}
		private var fakeCard:int = -1;
		private var bankerBJ:Boolean;
		public function playCheck():void{
			var poker:Poker = pokerMap[ -1];
			if ( poker != null ){
				TweenLite.to(poker, 0.5, {scale:1.2, y:poker.y - 20, onComplete:onCheckPhase1, onCompleteParams:[poker]});
			}
		}
		
		public function onCheckPhase1(poker:Poker):void{
			var item:ShakeItem = PoolMgr.gain(ShakeItem);
			item.callBack = onCheckPhase2;
			item.init('check', poker, 3, 3, ShakeMgr.SHAKE_TWIST);
			ShakeMgr.Instance.addShakeItem(item);
		}
		
		public function onCheckPhase2():void{
			var poker:Poker = pokerMap[ -1];
			if ( bankerBJ ){
				TweenLite.to(poker, 0.5, {scale:1, y:poker.y+20, onComplete:onCheckPhase3});
			}else{
				TweenLite.to(poker, 0.5, {scale:1, y:poker.y+20, onComplete:checkButtons});
			}
		}
		
		public function onCheckPhase3():void{
			this.onFakeCard(this.fakeCard);
			this.fakeCard = -1;
		}
		
		public function onRoundEnd():void{
			this.started = false;
			if ( _currentTable != null ){
				_currentTable.display.selected = false;
				_currentTable = null;
			}
			Buttons.Instance.switchModel(Buttons.MODEL_END);
		}
		
		
		public function resetTable(tabId:int):void{
			var subTable:SubTable = this.subTableDisplays[tabId];
			subTable.reset();
			var baseTable:BaseTable = this.tableDisplays[tabId];
			baseTable.reset(true);
			var tableData:TableData = this.tables[tabId];
			if( tableData != null)
				tableData.reset();
		}
		
		public function reset():void{
			for (var key:String in this.tables){
				tables[key].reset();
			}
			for ( key in this.tableDisplays){
				tableDisplays[key].reset();
			}
			for ( key in this.subTableDisplays){
				subTableDisplays[key].reset();
			}
			pokerMap = {};
			this.currentTables = [];
			this.endTables = [];
			mainView.onRoundEnd();
			enableDisplayMouse(true);
			this.fakeCard = -1;
			this.bankerBJ = false;
		}
		
		public function enableDisplayMouse(value:Boolean):void{
			var tableDisplay:BaseTable;
			for (var key in this.tableDisplays){
				tableDisplay = tableDisplays[key];
				tableDisplay.table.mouseChildren = tableDisplay.pair.mouseChildren = tableDisplay.table.mouseEnabled = tableDisplay.pair.mouseEnabled = value;
			}
		}
		
		public function onStarted(players:Object, money:int):void{
			this.started = true;
			var table:TableData ;
			if ( mainView.y != 0){
				mainView.tween(true);
			}
			//GameUtils.log('onStarted');
			Buttons.Instance.disableAll();
			if( this.tables[0] == null)
				mainView.bankerData = this.tables[0] = new TableData(0);
			
			var table:TableData;
			var tableId:int;
			var player:Object;

			for (var i:String in players){
				player = players[i];
				tableId = int(i);
				
				table = this.tables[tableId];
				if ( table == null ){
					table = this.tables[tableId] = new TableData(tableId);
					table.display = this.subTableDisplays[tableId];
					table.display.tableData = table;
					table.display.visible = true;
				}
				table.isSplited = player.split_table_id != 0;
				table.blackjack = player.blackJack == 1;
				table.bust = player.bust == 1;
				table.insureBet = player.insurance;
				table.actived = player.stop == 0;
				table.currentBet = player.amount[HttpComunicator.START];
				table.pairBet = player.amount[HttpComunicator.PAIR];
				//table.actived = true;
				table.display.showBet();
				if ( table.actived){
					this.currentTables.push(tableId);
				}else{
					this.putToEnd(tableId,false);
				}
					
			}
			
			enableDisplayMouse(false);
			
			if ( this.currentTables.length >= 1){
				this.currentTables.sort(Array.NUMERIC);
				GameUtils.log('sort tables:', this.currentTables.join('.'));
				this._currentTable = this.tables[this.currentTables[0]];
			}
			
			//this.money = money;
		}
		
		
		public function onBankerTurn(cards:Array):void{
			var table:TableData = tables[0];
			var len:int = cards.length;
			var card:int;
			//GameUtils.log('Banker card check :', table.cards.join(','),' vs', cards.join(','));
			for (var i:int = 1 ;  i < len; i++){
				card = int(cards[i]);
				
				//if ( table.cards.indexOf(card) == -1){
					this.dispense(0, card);
				//}
			}
			this.started = false;
			//todo 服务端不想结算，我也就不结算，直接结束了
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
				}else{
					betToTable(tablId, bet);
					table = this.tables[tablId];
				}
				if (currentTables.indexOf(tablId) == -1){
					this.currentTables.push(tablId);
				}
				var targetPoint:Point = table.display.poker_con.globalToLocal(poker.parent.localToGlobal(new Point(poker.x,poker.y)));
				table.display.poker_con.addChild(poker);//todo tweent to table2
				table.display.visible = true;
				poker.x = targetPoint.x;
				poker.y = targetPoint.y;
				TweenLite.to(poker, 0.5, {x:0, y:0, onComplete:onSplitComplete, onCompleteParams:[poker, table]});
			}
		}
		
		public function onSplited(father_id:int,father_card:Array,new_stage:Object):void{
			
			var table:TableData = this.tables[father_id];
			var bet:int = table.currentBet;
			table.reset();
			table.actived = true;
			table.isSplited = true;

			var poker:Poker;
			poker = pokerMap[father_card[0]];
			poker.x = 0 ;
			poker.y = 0;
			poker.rotation = 0;
			var targetPoint:Point = table.display.poker_con.globalToLocal(poker.parent.localToGlobal(new Point(poker.x,poker.y)));
			table.display.poker_con.addChild(poker);//todo tweent to table2
			table.display.visible = true;
			poker.x = targetPoint.x;
			poker.y = targetPoint.y;
			TweenLite.to(poker, 0.5, {x:0, y:0, onComplete:onSplitComplete, onCompleteParams:[poker, table]});
				
			dispense(father_id, int(father_card[1]));
			
			
			
			var son_id:int = father_id + 3;
			
			table = this.tables[son_id];
			if ( table != null ){
					table.reset();
					table.actived = true;
					table.isSplited = true;
			}else{
				betToTable(son_id, bet);
				table = this.tables[son_id];
			}
			table.display.visible = true;
			if (currentTables.indexOf(son_id) == -1){
				this.currentTables.push(son_id);
			}
			
			poker = pokerMap[father_card[int(new_stage.cards)]];
			poker.x = 0 ;
			poker.y = 0;
			poker.rotation = 0;
			
			targetPoint = table.display.poker_con.globalToLocal(poker.parent.localToGlobal(new Point(poker.x,poker.y)));
			table.display.poker_con.addChild(poker);//todo tweent to table2
			table.display.visible = true;
			poker.x = targetPoint.x;
			poker.y = targetPoint.y;
			TweenLite.to(poker, 0.5, {x:0, y:0, onComplete:onSplitComplete, onCompleteParams:[poker, table]});
		}
		
		public function onSplitComplete(poker:Poker, table:TableData):void{
			//table.display.poker_con.addChild(poker);
			table.addCard(poker);
		}
		
		private var pairResult:*;
		public function onPairBetResult(data:Object):void{
			if ( this.dispenseQueue.length != 0 ){
				this.pairResult = data;
				return;
			}
			this.pairResult = null;
			var result:Array = data.result;
			var table:BaseTable;
			var tabId:int;
			var gain:int;
			this.money = data.money;
			while (result.length != 0 ){
				tabId = result.shift();
				gain = result.shift();
				table = this.tableDisplays[tabId];
				table.onPairResult(gain);
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
			table.display.updateBetinfo();
			putToEnd(tabId);
		}
		
		public function onFakeCard(card:int):void{
			var table:TableData = tables[0];
			var poker:Poker = this.pokerMap[ -1];
			if ( poker != null ){
				poker.value = card;
				pokerMap[card] = poker;
				delete pokerMap[ -1];
				table.addCard(poker);
				mainView.traverseTheFakePoker(poker);
			}else{
				mainView.showFakeCardAfterTween = true;
				GameUtils.log('no traverse poker');//check the dispose list
			}
		}
		
		private function putToEnd(tabId:int,check:Boolean = true):void{
			GameUtils.log('Before put ', tabId, 'to the end', this.currentTables.join('.'), ' vs ', this.endTables.join('.'));
			var index:int = this.currentTables.indexOf(tabId);
			if ( index != -1){
				this.currentTables.splice(index, 1);
			}
			var table:TableData = tables[tabId];
			table.display.selected = false;
			table.display.updatePoints(true);
			this.endTables.push(tabId);
			
			GameUtils.log('after ', this.currentTables.join('.'), ' vs ', this.endTables.join('.'));
			if( check )
				this.nextTable();
		}
		
		public function onTableEnd(data:Object):void{
			var table:TableData = this.tables[data.tabId];
			table.display.end(data);
		}
		
		public function getInsuredTables():Array{
			var obj:Object = {};
			obj.wayId = HttpComunicator.INSURE;
			obj.stage = {};
			
			var result:Array = [];
			var table:TableData;
			for each (var i:int in this.currentTables){
				table = this.tables[i];
				
				if ( table.insured){
					result.push(i);
					obj.stage[i] = {};
					obj.stage[i][HttpComunicator.INSURE] = table.currentBet * 0.5;
				}
			}
			
			HttpComunicator.Instance.send(HttpComunicator.INSURE, obj, 0);
			
			return result;
		}
		
		public function get money():Number{
			return this._money;
		}
		
		public function set money(_val:Number):void{
			if ( this._money == _val) return;
			this._money = _val;
			if( BalanceImpl.Instance.parent != null)
				BalanceImpl.Instance.balance = _val;
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