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
	import consts.PokerGameVars;
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
		public static const FAKE_CARD_VALUE:int = -1;
		
		public var desk:uint = 0;//0 单桌 1 三桌
		public var currentModel:uint = 0;//0,1,2筹码大小
		public var started:Boolean = false;
		public var ME:uint = 1;
		private var _money:Number = 0;
		public const BANKER:uint = 0;
		private var splitors:Array;

		//private var pokerMap:Object = {};
		private var tables:Object = {};
		
		public var mainView:MainViewImpl;
		private var socketMgr:SocketMgr;
		
		private var currentTables:Array = [];
		private var endTables:Array = [];
		
		public var needShowInsure:Boolean;
		
		private var lastActiveTime:uint = 0;
		public var name:String;
		
		public var totalDispensed:uint = 0;
		public function GameMgr() 
		{
			this.name = 'gamemgr';

			HttpComunicator.Instance.mgr = this;
			HttpComunicator.Instance.requesAccount();
			
			lastActiveTime = new Date().time;
			//setInterval(checkOutTime, 60000);
		}
		
		private function checkOutTime():void{
			
			var referTime:uint = new Date().time - lastActiveTime;
			if ( referTime >= PokerGameVars.FIVE_MINUTES && LongTimeMask.Instance.parent == null){
				GameUtils.log('long time no move since : ',lastActiveTime,'-------',referTime);
				showAutoRemind(PokerGameVars.TEN_MINUTES - referTime + PokerGameVars.FIVE_MINUTES);
			}
		}
		
		
		public function refresh():void{
			lastActiveTime = new Date().time;
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
		private var requestedBaneker:Boolean = false;
		/**
		 * 读取下一个操作的桌子
		 * 
		 * **/
		public function nextTable():void{
			if ( this._currentTable != null && this._currentTable.isSplited && this._currentTable.tableId <= 3){
				GameUtils.log('nextTable 0: ',_currentTable.tableId);
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
				var table:TableData = tables[0];
				GameUtils.log('banker table :', table.numCards, requestedBaneker, table.blackjack);
				if ( table.numCards == 1 && !requestedBaneker){
					requestedBaneker = true;
					var obj:Object = {};
					obj.wayId = HttpComunicator.BANKER_TURN;
					obj.stage = [];
					HttpComunicator.Instance.send(HttpComunicator.BANKER_TURN, obj, 0,true);
				}else{
					this.onRoundEnd();
				}
			}
		}
		
		public function get currentTable():TableData{
			return this._currentTable;
		}
	
		private var dispenseTimer:uint = 0;
		//private var lastDipenseTime:Number = 0;
		private var dispenseQueue:Array = [];
		
		public function onHited(data:Object):void{
			var stage:Object = data.stage;
			var tabId:int = data.stageId;
			var table:TableData = tables[tabId];
			table.bust = stage.bust == 1;
			//table.actived = stage.stop == 0;
			//GameUtils.log('stageId:',data.stageId,' bust:',stage.bust == "1");
			if ( stage.stop == 1 ){
				putToEnd(tabId);
				if(stage.bust == 1){
					//setTimeout(function():void{
						onTableEnd(data.stageId,stage);
					//}, 400);
				}
			}
			
			dispense(data.stageId, int(data.newCard));
		}
		
		public function dispense(tableId:uint, card:int):void{
			//GameUtils.log(tableId,card,' ==> ['+dispenseQueue.join(',')+'] ');
			if ( dispensing ){
				dispenseQueue.push(tableId, card);
			}else{
				dispenseTo(tableId, card);
			}
			
			/**
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
			*/
		}
		
		private var dispensing:Boolean = false;
		public function dispenseComplete(tabId:int):void{
			dispensing = false;
			var table:TableData = tables[tabId];
			if (tabId != 0 && ( table.bust || table.blackjack || table.points == 21 || ( table.hasA && table.points == 11) || table.doubled)){
				if( this.endTables.indexOf(tabId) == -1)
					this.putToEnd(tabId);
			}
			
			
			if ( dispenseQueue.length != 0 ){
				tabId = dispenseQueue.shift();
				var cardId:int = dispenseQueue.shift();
				dispenseTo(tabId, cardId);
			}else{
				if ( !needPlayCheck ){
					if ( !started  || tables[0].blackjack){
						GameUtils.log('mgr.dispenseComplete 0');
						onRoundEnd();
						for each(var i:int in this.endTables){
							table = this.tables[i];
							table.display.end();
						}
						Buttons.Instance.enable(true);
					}else if ( checkInsurrable() ){
						GameUtils.log('mgr.dispenseComplete 1');
						Buttons.Instance.switchModel(Buttons.MODEL_INSRRUREABLE);
						Buttons.Instance.enable(true);
					}else if ( _currentTable != null ){
						_currentTable.display.selected = true;
						Buttons.Instance.enable(true);
					}else{
						GameUtils.log('mgr.dispenseComplete 2');
						nextTable();
					}
					
					if ( this.pairResult != null && pairResult.length != 0 ){
						this.onPairBetResult();
					}
				}else{
						playCheck();
						needPlayCheck = false;
				}
			}
		}
		
		public var starting:Boolean = false;
		private function dispenseTo(tableId:uint, card:int):void{
			dispensing = true;
			//lastDipenseTime = TickerMgr.SYSTIME;
			//GameUtils.log('mgr->dispenseTo :', tableId, card);
			
			if ( card != -1 ){
				totalDispensed++;
			}
			
			var table:TableData = this.tables[tableId];
			var poker:Poker;
			
			if ( tableId == 0 && table.numCards == 1 && fakePoker != null ){//pokerMap[FAKE_CARD_VALUE] != null){
				//poker = pokerMap[ FAKE_CARD_VALUE];
				fakePoker.value = card;
				//delete pokerMap[ FAKE_CARD_VALUE];
				table.addCard(fakePoker);
				mainView.traverseTheFakePoker(fakePoker);
			}else{
				poker = PoolMgr.gain(Poker);
				poker.value = card;
				poker.rotation = -75;
				if ( card != FAKE_CARD_VALUE){
					starting = false;
					poker.rotationY = 180 ;
				}
				if ( tableId != 0 ){
					table.display.addCard(poker);
				}else{
					if( card != FAKE_CARD_VALUE )
						table.addCard(poker);
					else
						fakePoker = poker;
					
					mainView.onDispenseBanker(poker);	
				}
			}
		}
		/**
		public function onBankerDispense():void{
			//GameUtils.log('On banker dispense complete', this.started);
			dispenseComplete(0);
			if ( this.dispenseQueue.length == 0 ){
				if ( !this.started ){
					var table:TableData;
					for each(var i:int in this.endTables){
						table = this.tables[i];
						table.display.end();
					}
				}else if ( this.currentTables.length == 0 && this._currentTable == null ){
					nextTable();
				}
			}
		}
		*/
		/**
		 * 检查是否需要显示保险按钮
		 * 
		 * **/
		private function checkInsurrable():Boolean{
			/**
			GameUtils.log('Check Buttons : ', started, starting, this.dispenseQueue.length);
			Buttons.Instance.enable(true);
			if ( !started ){
				Buttons.Instance.switchModel(Buttons.MODEL_END);
				return;
			}
			if ( starting || this.dispenseQueue.length != 0 ){
				return;
			}
			*/
			var need:Boolean = false;
			var table:TableData = tables[0];
			var subTable:SubTable;
			
			if ( table.points == 1 && !table.insured){
				//GameUtils.log('mgr.checkButtons : 0',table.points,table.insured);
				Buttons.Instance.switchModel(Buttons.MODEL_INSRRUREABLE);
				for (var i in subTableDisplays){
					subTable = subTableDisplays[i];
					if ( subTable.visible && subTable.tableData != null && subTable.tableData.actived){
						subTable.btn_insurrance.visible = !subTable.tableData.blackjack;
						need = subTable.btn_insurrance.visible || need;
					}
				}
			}
			
			return need;
			/**
			else{
				GameUtils.log('mgr.checkButtons : 1', currentTable == null);
				if ( currentTable != null){
					_currentTable.display.selected = true;
					if ( auto ){
						autoStep();
					}
				}
			}
			*/
		}
		
		public function x2Bet():void{
			//reset();
			var table:TableData;
			for (var i:String in tables){
				table = tables[i];
				if ( table.currentBet != 0){
					betToTable(int(i), table.currentBet );
					if ( table.pairBet != 0 ){
						betPair(int(i), table.pairBet);
					}
				}
			}
		}
		
		public function repeatBet():void{
			reset();
			if ( lastBetData == null ){
				FloatHint.Instance.show('没有上局下注记录');
				return;
			}
			var chip:Chip;
			var table:TableData;
			for (var i in lastBetData){
				betToTable(i, lastBetData[i]);
			}
			if ( lastPairBetData != null ){
				for ( i in lastPairBetData){
					betPair(i,lastPairBetData[i] );
				}
			}
		}
		/**
		 * 添加赌注到某桌
		 * 仅限开局使用
		 * **/
		public function betToTable(tableId:int, bet:uint = 0):void{
			if ( bet == 0 ) 
				bet = ChipsViewUIImpl.Instance.currentValue;
				
			if ( bet == 0 ) {
				FloatHint.Instance.show('请先选择筹码再下注哦~~');
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
				FloatHint.Instance.show('请先选择筹码再下注哦~~');
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
			//GameUtils.log('mgr.start');
			var obj:Object = {};
			obj.stage = {};
			obj.wayId = HttpComunicator.START;
			
			var betObj:Object = {};
			var pairBet:Object = {};
			var table:TableData;
			var got:Boolean;
			var gotPair:Boolean;
			
			var needMoney:int = 0;
			for (var key in this.tables){
				table = tables[key];
				if ( table.currentBet != 0){
					got = true;
					betObj[table.tableId] = table.currentBet;
					needMoney += table.currentBet;
					obj.stage[table.tableId] = {};
					obj.stage[table.tableId][HttpComunicator.START] = table.currentBet;
				}
				if ( table.pairBet != 0 && table.currentBet != 0 ){
					gotPair = true;
					pairBet[table.tableId] = table.pairBet;
					
					needMoney += table.pairBet;
					
					obj.stage[table.tableId][HttpComunicator.PAIR] = table.pairBet;
				}
			}
			if (got){
				if ( needMoney > this.money){
					FloatHint.Instance.show("对不起，您的账户余额不够本次下注！");
					return false;
				}
				//GameUtils.log('mgr.start :', JSON.stringify(obj));
				HttpComunicator.Instance.send(HttpComunicator.START,obj,0);
				table = this.tables[0];
				if ( table == null ){
					mainView.bankerData = table = this.tables[0] = new TableData(0);
				}else{
					table.reset();
				}
				table.actived = true;
				ChipsViewUIImpl.Instance.cancelSelect();
				starting = true;
				return true;
			}else{
				FloatHint.Instance.show('请先下注筹码再发牌哦~~');
				return false;
			}
		}
		public function onInsured(newCard:*,players:Object):void{
			var table:TableData;
			tables[0].insured = true;
			
			if ( newCard.length != 0 ){
				fakeCard = int(newCard[1]);
				var player:*;
				for ( var i:String in players){
					player = players[i];
					table = tables[i];
					table.prize = player.prize[HttpComunicator.INSURE];
					table.actived = player.stop == 0;
					putToEnd(table.tableId,false);
					table.display.end();
				}
				started = false;
				setTimeout(	onRoundEnd, 1500);
			}
			/**
			else{
				setTimeout(checkInsurrable, 1500);
			}
			*/
			playCheck();
			
			for (i in tables){
				if ( int(i) == 0 || int(i) > 3) continue;
				table = tables[i];
				//GameUtils.log('mgr.onInsured',i,"-->",table.insured);
				if ( table.insured ){
					table.display.onInsureBack(newCard.length == 0 ? -table.currentBet*0.5 : table.currentBet);
				}
				table.display.btn_insurrance.visible = false;
			}
		}
		
		public function endAllTables():void{
			//GameUtils.log('mgr.endAllTables');
			if ( _currentTable != null && _currentTable.display.selected){
				_currentTable.display.selected = false;
			}
			var table:TableData;
			for ( var i:String in tables){
				if ( int(i) == 0 ) continue;
				table = tables[i];
				if ( table.display.visible){
					putToEnd(table.tableId,false);
				}
			}
		}

		public var fakeCard:int = -1;
		private var fakePoker:Poker;
		public var needPlayCheck:Boolean = false;
		private function playCheck():void{
			if ( fakePoker != null ){
				Buttons.Instance.enable(false);
				TweenLite.to(fakePoker, 0.5, {scale:1.2, y:fakePoker.y - 20, onComplete:onCheckPhase1});
			}
		}
		
		public function onCheckPhase1():void{
			//GameUtils.log('mgr.onCheckPhase1:',fakeCard);
			if ( fakeCard != -1 ){
				TweenLite.to(fakePoker, 0.5, {scale:1, y:fakePoker.y+20, onComplete:onCheckPhase2});
			}else{
				TweenLite.to(fakePoker, 0.5, {scale:1, y:fakePoker.y+20, onComplete:onCheckPhase3});
			}
		}
		
		public function onCheckPhase3():void{
			var flag:Boolean = checkInsurrable();
			if (flag ){
				Buttons.Instance.switchModel(Buttons.MODEL_INSRRUREABLE);
			}else{
				if ( _currentTable != null ){
					_currentTable.display.selected = true;
					Buttons.Instance.enable(true);
				}else {
					nextTable();
				}
			}
		}
		
		public function onCheckPhase2():void{
			//GameUtils.log('mgr.onCheckPhase2');
			this.onFakeCard(this.fakeCard);
			this.fakeCard = FAKE_CARD_VALUE;
			Buttons.Instance.switchModel(Buttons.MODEL_END);
			Buttons.Instance.enable(true);
		}
		
		public function onRoundEnd():void{
			GameUtils.log('mgr.onRoundEnd');
			this.started = false;
			if ( _currentTable != null ){
				_currentTable.display.selected = false;
				_currentTable = null;
			}
			
			Buttons.Instance.switchModel(Buttons.MODEL_END);
			if ( totalDispensed < 164 ){
				
			}else{
				
			}
			
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
			this.currentTables = [];
			this.endTables = [];
			mainView.onRoundEnd();
			enableDisplayMouse(true);
			this.fakeCard = FAKE_CARD_VALUE;
			this.fakePoker = null;
			requestedBaneker = false;
			PokerGameVars.TempInsureCost = 0;
		}
		
		public function enableDisplayMouse(value:Boolean):void{
			var tableDisplay:BaseTable;
			for (var key in this.tableDisplays){
				tableDisplay = tableDisplays[key];
				tableDisplay.table.mouseChildren = tableDisplay.pair.mouseChildren = tableDisplay.table.mouseEnabled = tableDisplay.pair.mouseEnabled = value;
			}
		}
		public function onStarted(players:Object, money:int, isStart:Boolean):void{
			this.started = true;
			var table:TableData ;
			if ( mainView.y != 0){
				mainView.tween(true);
			}
			//GameUtils.log('onStarted');
			Buttons.Instance.enable(false);
			if( this.tables[0] == null)
				mainView.bankerData = this.tables[0] = new TableData(0);
			
			var table:TableData;
			var tableId:int;
			var player:Object;
			var pairArr:Array;
			var insured:Boolean = false;
			lastBetData = {};
			lastPairBetData = {};
			var noPairBets:Boolean = true;
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
				if ( !insured ){
					//GameUtils.log('check insured ',i,player.insurances);
					insured = player.amount[HttpComunicator.INSURE];
				}
				table.actived = player.stop == 0;
				table.currentBet = player.amount[HttpComunicator.START];
				
				if ( table.tableId > 3 ){
					table.currentBet = player.amount[HttpComunicator.SPLIT];
				}
				
				table.pairBet = player.amount[HttpComunicator.PAIR];
				if( table.currentBet != 0 && int(i) <= 3)
					lastBetData[i] = table.currentBet;
				if ( table.pairBet != 0){
					noPairBets = false;
					lastPairBetData[i] = table.pairBet;
				}
				
				if( !isStart )
					table.display.showBet();
				if ( table.actived){
					this.currentTables.push(tableId);
				}else{
					this.putToEnd(tableId,false);
				}
				
				if ( isStart && table.pairBet != 0){
					if ( pairArr == null){
						pairArr = [];
					}
					pairArr.push(i,  player.prize[HttpComunicator.PAIR]);
				}
				
				if ( player.prize && player.prize[HttpComunicator.START]){
					table.prize = player.prize[HttpComunicator.START];
				}
			}
			tables[0].insured = insured;
			
			enableDisplayMouse(false);
			
			pairResult = pairArr;
			
			if ( this.currentTables.length >= 1){
				this.currentTables.sort(Array.NUMERIC);
				GameUtils.log('sort tables:', this.currentTables.join('.'));
				this._currentTable = this.tables[this.currentTables[0]];
			}
			
			this.money = money;
			BalanceImpl.Instance.rockAndRoll();
	
		}
		
		private var pairResult:Array;
		public function onPairBetResult():void{//data:Object):void{
			if ( pairResult == null ) return;
			var table:BaseTable;
			var tabId:int;
			var gain:int;
			//this.money = data.money;
			while (pairResult.length != 0 ){
				tabId = pairResult.shift();
				gain = pairResult.shift();
				table = this.tableDisplays[tabId];
				table.onPairResult(gain);
			}
		}
		
		public function onBankerTurn(data:Object):void{
			var cards:Array = data.banker.cards;
			var players:Object = data.player;
			
			var table:TableData;
			var player:*;
			for ( var j:String in players){
				player = players[j];
				table = this.tables[j];
				table.prize = player.prize[HttpComunicator.START];
				if ( player.prize[HttpComunicator.DOUBLE]){
					table.prize += player.prize[HttpComunicator.DOUBLE];
				}
				if ( player.prize[HttpComunicator.SPLIT]){
					table.prize += player.prize[HttpComunicator.SPLIT];
				}
				GameUtils.log('table:', j, '==== prize : ', table.prize);
			}
			
			//table = tables[0];
			var len:int = cards.length;
			var card:int;
			//GameUtils.log('Banker card check :', table.cards.join(','),' vs', cards.join(','));
			if ( len != 1 ){
				for (var i:int = 1 ;  i < len; i++){
					card = int(cards[i]);
					this.dispense(0, card);
				}
			}else{
				onRoundEnd();
				Buttons.Instance.enable(true);
			}
			money = Number(data.account);
			this.started = false;
		}
		
		public function onSplited(father_id:int,son_id:int,father_card:Array,new_stage:Object):void{
			var bet:int = this.tables[father_id].currentBet;
			
			table = this.tables[son_id];
			if ( table != null ){
				table.reset();
				table.actived = true;
				table.isSplited = true;
				betToTable(son_id, bet);
			}else{
				betToTable(son_id, bet);
				table = this.tables[son_id];
			}
			table.display.visible = true;
			if (currentTables.indexOf(son_id) == -1){
				this.currentTables.push(son_id);
			}
			
			poker = tables[father_id].getCard(int(new_stage.cards));//pokerMap[int(new_stage.cards)];
			GameUtils.assert(poker != null,'mgr.onSplited:0'+father_id+' has no ' +new_stage.cards);
			tables[father_id].removeCard(poker);
			
			poker.x = 0 ;
			poker.y = 0;
			poker.rotation = 0;
			
			targetPoint = table.display.poker_con.globalToLocal(poker.parent.localToGlobal(new Point(poker.x,poker.y)));
			table.display.poker_con.addChild(poker);//todo tweent to table2
			table.display.visible = true;
			poker.x = targetPoint.x;
			poker.y = targetPoint.y;
			TweenLite.to(poker, 0.5, {x:0, y:0, onComplete:onSplitComplete, onCompleteParams:[poker, table]});
			
			var table:TableData = this.tables[father_id];
			
			var poker:Poker;
			//必须在这里拿到不然下面的reset就要清空导致报错
			poker = table.getCard(int(father_card[0]));
			GameUtils.assert(poker != null, 'mgr.onSplited:1' + father_id + ' has no ' +new_stage.cards);
			
			table.reset();
			table.currentBet = bet;
			table.actived = true;
			table.isSplited = true;
			
			poker.x = 0 ;
			poker.y = 0;
			poker.rotation = 0;
			var targetPoint:Point = table.display.poker_con.globalToLocal(poker.parent.localToGlobal(new Point(poker.x, poker.y)));
			
			table.display.poker_con.addChild(poker);
			
			table.display.visible = true;
			poker.x = targetPoint.x;
			poker.y = targetPoint.y;
			//TweenLite.to(poker, 0.5, {x:0, y:0, onComplete:onSplitComplete, onCompleteParams:[poker, table]});
			table.addCard(poker);
			dispense(father_id, int(father_card[1]));
		}
		
		public function onSplitComplete(poker:Poker, table:TableData):void{
			table.addCard(poker);
			table.display.updatePoints();
		}
		
		
		
		public function onStandBack(data:Object):void{
			var tabId:int = data.tabId;
			putToEnd(tabId);
			Buttons.Instance.enable(true);
		}
		
		public function onDoubled(newCard:int, tabId:int, tableData:Object):void{
			var table:TableData = this.tables[tabId];
			table.currentBet = tableData.amount[HttpComunicator.START] + tableData.amount[HttpComunicator.DOUBLE];
			table.display.showBet();
			table.doubled = true;
			table.bust = tableData.bust == 1;
			dispense(tabId, newCard);
			//putToEnd(tabId);
		}
		
		public function onFakeCard(card:int):void{
			var table:TableData = tables[0];
			if ( fakePoker != null ){
				fakePoker.value = card;
				table.addCard(fakePoker);
				mainView.traverseTheFakePoker(fakePoker);
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
			
			if ( this.endTables.indexOf(tabId) == -1){
				var table:TableData = tables[tabId];
				table.display.selected = false;
				this.endTables.push(tabId);
				GameUtils.log('after ', this.currentTables.join('.'), ' vs ', this.endTables.join('.'));
			}
			
			if( check )
				this.nextTable();
		}
		
		public function onTableEnd(tabId:int, data:Object):void{
			GameUtils.log('mgr.onTableEnd', tabId);
			var table:TableData = this.tables[tabId];
			if ( data.prize && data.prize[HttpComunicator.START]){
				table.prize = data.prize[HttpComunicator.START];
			}
			
			table.display.end();
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
		private var auto:Boolean = false;
		public function autoGame():void{
			if ( auto ) return;
			auto = true;
			autoStep();
		}
		
		public function autoStep():void{
			return;
			if ( !auto || !started) return;
			if ( _currentTable != null ){
				
				Buttons.Instance.enable(false);
		
				var obj:Object = {};
				obj.wayId = HttpComunicator.STOP;
				obj.stage = {};
				obj.stage[_currentTable.tableId] = [];
				HttpComunicator.Instance.send(HttpComunicator.STOP, obj,_currentTable.tableId);
				
			}
		}
		
		public function showAutoRemind(timeRest:int):void{
			LongTimeMask.Instance.show(timeRest);
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
		/**
		public function get started():Boolean 
		{
			return _started;
		}
		
		public function set started(value:Boolean):void 
		{
			GameUtils.log('started:',value);
			_started = value;
		}
		*/
	}

}