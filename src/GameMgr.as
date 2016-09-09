package 
{
	import com.greensock.TweenLite;
	import comman.duke.FloatHint;
	import comman.duke.GameUtils;
	import comman.duke.GameVars;
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
	import uiimpl.OverTimeReminder;
	import uiimpl.MainViewImpl;
	import uiimpl.BaseTable;
	import uiimpl.Reminder;
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

		private var tables:Object = {};
		
		public var mainView:MainViewImpl;
		public var buttons:Buttons;
		
		private var currentTables:Array = [];
		private var endTables:Array = [];
		
		public var needShowInsure:Boolean;
		
		private var lastActiveTime:uint = 0;
		public var name:String;
		
		public var totalDispensed:uint = 0;
		
		public var tempTotalBet:int = 0;
		public var soundMgr:SoundMgr;
		public function GameMgr() 
		{
			this.name = 'gamemgr';
			soundMgr = SoundMgr.Instance;
			lastActiveTime = new Date().time;
			setInterval(checkOutTime, 60000);
		}
		
		public static const DEV:String = "develop";
		public static const PRODUCTION:String = "production";
		
		private var currentEnv:String = "develop";
		public function setEnv(env:String):void{
			currentEnv = env;
			if ( currentEnv ==  DEV){
				GameUtils.DEBUG_LEVEL = GameUtils.LOG;
				HttpComunicator.decrKey = '0123456789abcdef';
				HttpComunicator.decrIV = '1234567891234567';
			}else if (currentEnv ==  PRODUCTION){
				GameUtils.DEBUG_LEVEL = GameUtils.FATAL;
				HttpComunicator.decrKey = '9WPH0OLXY498JC0X';
				HttpComunicator.decrIV = 'X4O9HHJR05BFSD4I';
			}
			PokerGameVars.setUpVersion(env);
			HttpComunicator.Instance.mgr = this;
		}
		
		private var minBet:int;
		private var maxBet:int;
		private var minPairBet:int;
		private var maxPairBet:int;
		public function setup(model:int):void{
			if ( model < 1 || model > 3){
				model = 1;
			}
			this.currentModel = model - 1;
			var startIndex:int = currentModel * 4;
			minBet = PokerGameVars.LIMITS[startIndex];
			maxBet = PokerGameVars.LIMITS[startIndex+1];
			minPairBet = PokerGameVars.LIMITS[startIndex+2];
			maxPairBet = PokerGameVars.LIMITS[startIndex + 3];
			//GameUtils.log('Limits:', model, startIndex, minBet, maxBet, minPairBet, maxPairBet);
		}
		
		//定时器检查多久没有进行交互操作
		private function checkOutTime():void{
			if ( !started ) return;
			var referTime:int = new Date().time - lastActiveTime;
			if ( referTime >= GameVars.FIVE_MINUTES && OverTimeReminder.Instance.parent == null){
				showAutoRemind(GameVars.TEN_MINUTES - referTime + GameVars.FIVE_MINUTES);
			}
		}
		
		/** 刷新交互时间 */
		public function refresh():void{
			lastActiveTime = new Date().time;
		}
		
		/** 游戏押注桌子显示对象注册 **/
		public var tableDisplays:Object = {};
		public function registerTableDisplay(id:int, table:BaseTable):void{
			tableDisplays[id] = table;
		}
		/** 游戏桌子显示对象注册 **/
		public var subTableDisplays:Object = {};
		public function registerSubTableDisplay(id:int, table:SubTable):void{
			subTableDisplays[id] = table;
		}
		/** 根据id取得桌子数据 **/
		public function getTableDataById(id:int):TableData{
			return tables[id];
		}
		
		private var _currentTable:TableData;
		//单局只会在结束的时候请求庄家要牌（即结算）
		public var requestedBaneker:Boolean = false;
		/** 下一桌 **/
		private function nextTable():void{
			if ( this._currentTable != null && this._currentTable.isSplited && this._currentTable.tableId <= 3){
				//GameUtils.log('nextTable0: ',_currentTable.tableId);
				this._currentTable = this.tables[this._currentTable.tableId + 3];
				if ( endTables.indexOf( _currentTable.tableId) != -1){
					_currentTable = null;
					nextTable();
				}else if ( this._currentTable != null && (this._currentTable.blackjack || this._currentTable.points == 21)){
					putToEnd(this._currentTable.tableId);
				}
			}else if ( this.currentTables.length != 0 ){
				//GameUtils.log('nextTable 1 ');
				_currentTable = this.tables[this.currentTables[0]];
			}else{
				//GameUtils.log('nextTable 2 ');
				_currentTable = null;
			}
			
			if ( _currentTable != null){
				GameUtils.log('select table:', _currentTable.tableId);
			}else{
				var table:TableData = tables[0];
				GameUtils.log('banker table :', table.cards.length, table.blackjack,fakeCard,started);
				if ( table.cards.length == 1 && !requestedBaneker){
					requestedBaneker = true
					var obj:Object = {};
					obj.wayId = HttpComunicator.BANKER_TURN;
					obj.stage = [];
					HttpComunicator.Instance.send(HttpComunicator.BANKER_TURN,obj,0);
					GameUtils.log('select table: null');
				}else{
					GameUtils.log('nextTable.roundEnd');
					this.onRoundEnd();
					return;
				}
			}
			checkButtons();
		}
		
		public function get currentTable():TableData{
			return this._currentTable;
		}
	
		//private var dispenseTimer:uint = 0;
		public var dispenseQueue:Array = [];
		/** 要牌请求的结果处理 **/
		public function onHited(data:Object):void{
			var stage:Object = data.stage;
			var tabId:int = data.stageId;
			var table:TableData = tables[tabId];
			//GameUtils.log('stageId:',data.stageId,' bust:',stage.bust == "1");
			dispense(data.stageId, int(data.newCard));
			
			/** 这些应该都是到发牌结束里面处理
			if ( stage.stop == 1 ){
				putToEnd(tabId);
				*/
				if(stage.bust == 1){
					//setTimeout(function():void{
						onTableEnd(data.stageId,stage, false);
					//}, 200);
				}
				/*
			}
			*/
		}
		
		/** 发牌 **/
		public function dispense(tableId:uint, card:int):void{
			//GameUtils.log(tableId,card,' ==> ['+dispenseQueue.join(',')+'] ');
			if ( dispensing ){
				dispenseQueue.push(tableId, card);
			}else{
				dispenseTo(tableId, card);
			}
		}
		
		//是否发牌中：Y 发牌数据压入发牌队列 N 发牌
		private var dispensing:Boolean = false;
		
		/** 发牌结束回调至此 **/
		public function dispenseComplete(tabId:int):void{
			dispensing = false;
			var table:TableData = tables[tabId];
			if (tabId != 0 && ( table.bust || table.blackjack || table.points == 21 || ( table.numA > 0 && table.points == 11) || table.doubled)){
				if ( this.endTables.indexOf(tabId) == -1){
					this.putToEnd(tabId);
				}
				
				if ( dispenseQueue.length == 0 ){
					if ( table.bust ){//要牌不会要到21点，所以这里不用处理21点，并且为了不重复播报21点，设置了一个boolean值
						table.display.end();
						//soundMgr.playVoice(Math.random() > 0.5 ? SoundsEnum.BUST_0 : SoundsEnum.BUST_1);
					}else if( table.points == 21 || (table.points == 11 && table.numA > 0)){
						soundMgr.playVoice(Math.random() > 0.5 ? SoundsEnum.POINT_21_0 : SoundsEnum.POINT_21_1);
					}else{
						if ( table.numA > 0 && table.points + 10 < 21){
							soundMgr.playVoice( SoundsEnum['POINT_'+(table.points + 10)]);
						}else{
							soundMgr.playVoice( SoundsEnum['POINT_'+table.points]);
						}
					}
				}
			}
			
			GameUtils.assert(dispenseQueue.length != 0,'mgr.dispenseComplete : '+ tabId);
			if ( dispenseQueue.length != 0 ){
				tabId = _instance.dispenseQueue.shift();
				var cardId:int = _instance.dispenseQueue.shift();
				dispenseTo(tabId, cardId);
			}else{
				if ( !started  || tables[0].blackjack){
					//setTimeout(onRoundEnd, 1000);
					//buttons.enable(true);
				}else{
					if( this.currentTables.length != 0 && !HttpComunicator.lock)
						buttons.enable(true);
						
					if ( playBlackJack ){
						soundMgr.playVoice( SoundsEnum.BLACKJACK );
						playBlackJack = false;
					}
					this.checkButtons();
				}
				//检查是否有对子奖励
				if ( this.pairResult != null && pairResult.length != 0 ){
					this.onPairBetResult();
				}
				if ( auto ){
					autoStep();
				}
			}
		}
		
		public var starting:Boolean = false;
		//发牌
		private function dispenseTo(tableId:uint, card:int):void{
			dispensing = true;
			//GameUtils.log('mgr->dispenseTo :', tableId, card);
			
			if ( card != -1 ){
				totalDispensed++;
			}
			
			var table:TableData = this.tables[tableId];
			var poker:Poker;
			
			if ( tableId == 0 && table.cards.length == 1 && fakePoker != null ){
				fakePoker.value = card;
				table.addCard(fakePoker);
				mainView.traverseTheFakePoker(fakePoker);
			}else{
				poker = PoolMgr.gain(Poker);
				poker.value = card;
				poker.rotation = -75;
				if ( card != FAKE_CARD_VALUE){
					starting = false;
					poker.rotationY = 180 ;
				}else{
					poker.rotationY = 90 ;
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
		/** 庄家发牌之后的回调 **/
		public function onBankerDispense():void{
			GameUtils.log('mgr.onBankerDispense : dipenseQueueLen-', this.dispenseQueue.length," started-",started,"needCheck-",needCheck);
			if ( this.dispenseQueue.length == 0 ){
				if ( !this.started ){
					if ( !needCheck ){
						
						setTimeout(function():void{
							GameUtils.log("endTables.length:", endTables.length);
							var ttable:TableData;
							for each(var i:int in endTables){
								ttable = tables[i];
								GameUtils.log(ttable.tableId, ttable.actived,ttable.display.visible);
								if( ttable.actived && ttable.display.visible)
									ttable.display.end();
							}
						}, 1000);
						var table:TableData;
						table = tables[0];
						var needEnd:Boolean = table.cards.length > 1;
						if ( table.bust ){
							soundMgr.playVoice(Math.random() > 0.5 ? SoundsEnum.BANKER_BUST_0 : SoundsEnum.BANKER_BUST_1, needEnd);
						}else if ( table.blackjack ){
							soundMgr.playVoice( Math.random() > 0.5 ? SoundsEnum.BANKER_BJ_0 : SoundsEnum.BANKER_BJ_1, needEnd);
						}else if( table.points == 21 || (table.points == 11 && table.numA > 0)){
							soundMgr.playVoice(Math.random() > 0.5 ? SoundsEnum.BANKER_21_0 : SoundsEnum.BANKER_21_1, needEnd);
						}else{
							if ( table.numA > 0 && table.points + 10 < 21){
								soundMgr.playVoice( SoundsEnum['POINT_'+(table.points + 10)], needEnd);
							}else{
								soundMgr.playVoice( SoundsEnum['POINT_'+table.points], needEnd);
							}
						}
					}
				}else if ( this.currentTables.length == 0 && this._currentTable == null ){
					nextTable();
				}
				
			}
			
			dispenseComplete(0);
			if ( needCheck ){
				buttons.enable(false);
			}
		}
		/** 在点击确认保险和跳过保险之后隐藏所有保险按钮 **/
		public function unvisAllInsureBtn():void{
			var subTable:SubTable;
			for (var i in subTableDisplays){
				subTable = subTableDisplays[i];
				if( subTable.visible)
					subTable.btn_insurrance.visible = false;
			}
		}
		
		/** 原先只是检查是否需要显示保险的，后面改bug加了大堆不相关的东西，唉 **/
		public function checkButtons():void{
			//GameUtils.log('Check Buttons', start, this.dispenseQueue.length);
			if ( !started || starting || this.dispenseQueue.length != 0 ){
				if ( !started ){
					buttons.switchModel(Buttons.MODEL_END);
				}
				return;
			}
			
			var table:TableData = tables[0];
			var subTable:SubTable;
			
			if ( table.points == 1 && !table.insured && this.currentTables.length != 0){
				var needSoundEffect:Boolean = false;
				GameUtils.log('mgr.checkButtons : 0', this.currentTables.length);
				buttons.switchModel(Buttons.MODEL_INSRRUREABLE);
				for (var i in subTableDisplays){
					subTable = subTableDisplays[i];
					if ( subTable.visible && subTable.tableData != null && subTable.tableData.actived){
						if ( subTable.btn_insurrance.visible ){
							break;
						}
						
						subTable.btn_insurrance.visible = !subTable.tableData.blackjack;
						needSoundEffect = true;
					}
				}
				
				if ( needSoundEffect ){
					soundMgr.playVoice(SoundsEnum.NEED_INSURRANCE);
				}
			}else{
				GameUtils.log('mgr.checkButtons : 1', currentTable != null);
				if ( currentTable != null){
					_currentTable.display.selected = true;
					_currentTable.display.btn_split.visible = _currentTable.display.tableData.canSplit;
					if ( auto ){
						autoStep();
					}
				}
			}
		}
		
		/** 当前桌面的筹码加倍 **/
		public function x2Bet():void{
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
		
		/** 清理桌上筹码并且押上上局同等筹码 **/
		public function repeatBet():void{
			reset();
			if ( lastBetData == null ){
				Reminder.Instance.show('没有上局下注记录');
				return;
			}
			setTimeout(function():void{
				var chip:Chip;
				var table:TableData;
				for (var i in lastBetData){
					betToTable(i, lastBetData[i]);
				}
				if ( lastPairBetData != null ){
					for ( i in lastPairBetData){
						betPair(i, lastPairBetData[i]);
					}
				}
			}, 500);
		}
		
		/**
		 * 添加赌注到某桌
		 * 仅限开局使用
		 * **/
		public function betToTable(tableId:int, bet:uint = 0):void{
			if ( bet == 0 ) 
				bet = ChipsViewUIImpl.Instance.currentValue;
				
			if ( bet == 0 ) {
				Reminder.Instance.show('请先选择筹码再下注哦~~');
				return;
			}
			var table:TableData = this.tables[tableId];
			if ( table == null ){
				table = this.tables[tableId] = new TableData(tableId);
				table.display = this.subTableDisplays[tableId];
				table.display.tableData = table;
			}
			
			if ( table.currentBet == maxBet ){
				Reminder.Instance.show('已达本桌最大下注限额');
				return;
			}
			table.currentBet += bet;
			if ( table.currentBet > maxBet){
				table.currentBet = maxBet;
				Reminder.Instance.show('本桌下注限额'+maxBet);
			}
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
				Reminder.Instance.show('请先选择筹码再下注哦~~');
				return;
			}
			
			var table:TableData = this.tables[tableId];
			if ( table != null && table.currentBet != 0 ){
				
				if ( table.pairBet == maxPairBet ){
					//setTimeout(function():void{
						Reminder.Instance.show('已达本桌最大对子下注限额');
					//}, 300);
					return;
				}
				
				table.pairBet += bet;
				if ( table.pairBet > maxPairBet){
					table.pairBet = maxPairBet;
					//setTimeout(function():void{
						Reminder.Instance.show('本桌对子下注限额' + maxPairBet);
					//}, 300);
				}
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
					if ( table.currentBet < minBet){
						Reminder.Instance.show('本桌最低下注金额' + minBet);
						buttons.enable(true);
						got = false;
						return false;
					}
					got = true;
					betObj[table.tableId] = table.currentBet;
					needMoney += table.currentBet;
					obj.stage[table.tableId] = {};
					obj.stage[table.tableId][HttpComunicator.START] = table.currentBet;
				}
				
				if ( table.pairBet != 0 && table.currentBet != 0 ){
					
					if ( table.pairBet < minPairBet){
						Reminder.Instance.show('本桌最低下注金额' + minBet);
						buttons.enable(true);
						got = false;
						gotPair = false;
						return false;
					}
					
					gotPair = true;
					pairBet[table.tableId] = table.pairBet;
					
					needMoney += table.pairBet;
					
					obj.stage[table.tableId][HttpComunicator.PAIR] = table.pairBet;
				}
			}
			
			if (got){
				if ( needMoney > this.money){
					Reminder.Instance.show("对不起，您的账户余额不够本次下注！");
					buttons.enable(true);
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
				Reminder.Instance.show('请先下注筹码再发牌哦~~');
				buttons.enable(true);
				return false;
			}
		}
		
		/**
		 * 保险回来
		 * **/
		public function onInsured(newCard:*,players:Object):void{
			var table:TableData;
			tables[0].insured = true;
			
			if ( newCard.length != 0 ){
				fakeCard = int(newCard[1]);
				var player:*;
				for ( var i:String in players){
					player = players[i];
					table = tables[i];
					
					if ( player.prize[HttpComunicator.START]){
						table.prize += player.prize[HttpComunicator.START];
					}
					if ( player.prize[HttpComunicator.SPLIT]){
						table.prize = player.prize[HttpComunicator.INSURE];
					}
					putToEnd(table.tableId,false);
					//table.display.end();
				}
				started = false;
			}else{
				setTimeout(checkButtons, 1500);
			}
			
			playCheck();
			
			setTimeout(function():void{
				for (i in tables){
					if ( int(i) == 0 || int(i) > 3) continue;
					table = tables[i];
					//GameUtils.log('mgr.onInsured',i,"-->",table.insured);
					if ( table.insured ){
						table.display.onInsureBack(newCard.length == 0 ? -table.currentBet*0.5 : table.currentBet);
					}
					table.display.btn_insurrance.visible = false;
					table.display.btn_split.visible = false;
					if( newCard.length != 0 )
						table.display.end();
				}
			}, 1500);
			
		}
		
		/**
		 * 结束所有桌子:目前只用在开始游戏庄家blackjack
		 * **/
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

		private var fakeCard:int = -1;
		private var fakePoker:Poker;
		private var needCheck:Boolean;
		/**
		 * 开始查牌
		 * **/
		public function playCheck():void{
			if ( fakePoker != null ){
				buttons.enable(false);
				TweenLite.to(fakePoker, 0.5, {scale:1.2, y:fakePoker.y - 20, onComplete:onCheckPhase1});
			}

			needCheck = false;
		}
		/**
		 * 查牌第一阶段：有第二张牌的话结束，没有第二张牌则继续游戏
		 * **/
		public function onCheckPhase1():void{
			//GameUtils.log('mgr.onCheckPhase1:',fakeCard);
			if ( fakePoker != null ){
				if ( fakeCard != -1 ){
					TweenLite.to(fakePoker, 0.5, {scale:1, y:fakePoker.y+20, onComplete:onCheckPhase2});
				}else{
					TweenLite.to(fakePoker, 0.5, {scale:1, y:fakePoker.y+20, onComplete:checkButtons});
				}
			}
			
			setTimeout(function():void{
				if ( started){
					buttons.enable(true);
					if(_currentTable != null && _currentTable.canSplit){
						_currentTable.display.btn_split.visible = true;
						buttons.enable(true);
					}
				} 
			}, 600);
		}
		/**
		 * 假牌翻转
		 * **/
		public function onCheckPhase2():void{
			//GameUtils.log('mgr.onCheckPhase2');
			this.onFakeCard(this.fakeCard);
			//this.needCheck = false;
			this.fakeCard = FAKE_CARD_VALUE;
		}
		/**
		 * 游戏结束
		 * */
		public function onRoundEnd():void{
			GameUtils.log('mgr.onRoundEnd');
			this.started = false;
			if ( _currentTable != null ){
				_currentTable.display.selected = false;
				_currentTable = null;
			}
			
			buttons.switchModel(Buttons.MODEL_END);
			buttons.enable(true);
			if ( totalDispensed >= 164 ){//要洗牌了
				
			}
			
		}
		private var playBlackJack:Boolean;
		/**
		 * 游戏开始或者读取游戏进度
		 * **/
		public function onStarted(players:Object, money:int, isStart:Boolean, hasInsured:Boolean, fakeCard:int,needCheck:Boolean):void{
			this.fakeCard = fakeCard;
			this.needCheck = needCheck;
			this.started = fakeCard == -1;
			GameUtils.log('mgr.onStarted: fakeCard.',fakeCard,'started',started);
			var table:TableData ;
			if ( mainView.y != 0){
				mainView.tween(true);
			}
			buttons.enable(false);
			
			if( this.tables[0] == null)
				mainView.bankerData = this.tables[0] = new TableData(0);
			
			var tableId:int;
			var player:Object;
			var pairArr:Array;
			
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
				//这些值是否要用这里的
				table.isSplited = player.split_table_id != 0;
				
				if ( !playBlackJack ){
					playBlackJack = player.blackJack == 1;
				}
				
				//table.blackjack = player.blackJack == 1;
				table.bust = player.bust == 1;
				table.insureBet = player.insurance;
				table.actived = player.bust != 1;//只有在读取游戏进度的时候才有可能爆牌,读取游戏进度的游戏不显示结果
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
				if( !isStart )//如果是读取游戏进度，那么要展示筹码
					table.display.showBet();
					
				if ( player.stop == 0 ){
					this.currentTables.push(tableId);
				}else{
					this.putToEnd(tableId, false);
				}
				
				if ( isStart && table.pairBet != 0){
					if ( pairArr == null){
						pairArr = [];
					}
					if ( player.prize){
						pairArr.push(i,  int(player.prize[HttpComunicator.PAIR]));
					}else{
						pairArr.push(i,  0);
					}
				}
				
				if ( player.prize && player.prize[HttpComunicator.START]){
					table.prize = player.prize[HttpComunicator.START];
				}
			}
			tables[0].insured = hasInsured;
			
			enableDisplayMouse(false);
			
			pairResult = pairArr;
			if ( this.currentTables.length >= 1){
				this.currentTables.sort(Array.NUMERIC);
				GameUtils.log('sort tables:', this.currentTables.join('.'));
				this._currentTable = this.tables[this.currentTables[0]];
			}
			
			this.money = money;
			if( pairResult == null || pairResult.length == 0)
				BalanceImpl.Instance.rockAndRoll();
		}
		
		//对子奖励
		private var pairResult:Array;
		//展示对子奖励
		private function onPairBetResult():void{
			if ( pairResult == null ) return;
			var table:BaseTable;
			var tabId:int;
			var gain:int;
			while (pairResult.length != 0 ){
				tabId = pairResult.shift();
				gain = pairResult.shift();
				table = this.tableDisplays[tabId];
				table.onPairResult(gain);
			}
		}
		/** 庄家要牌返回 **/
		public function onBankerTurn(data:Object):void{
			var cards:Array = data.banker.cards;
			var players:Object = data.player;
			
			this.started = false;
			this.needCheck = false;
			var table:TableData;
			var player:*;
			for ( var j:String in players){
				player = players[j];
				table = this.tables[j];
				
				table.prize = 0;
				if ( player.prize[HttpComunicator.START]){
					table.prize += player.prize[HttpComunicator.START];
				}
				
				if ( player.prize[HttpComunicator.DOUBLE]){
					table.prize += player.prize[HttpComunicator.DOUBLE];
				}
				if ( player.prize[HttpComunicator.SPLIT]){
					table.prize += player.prize[HttpComunicator.SPLIT];
				}
				GameUtils.log('table:', j, '==== prize : ', table.prize);
			}
			
			var len:int = cards.length;
			var card:int;
			//GameUtils.log('Banker card check :', table.cards.join(','),' vs', cards.join(','));
			if ( len != 1 ){
				for (var i:int = 1 ;  i < len; i++){
					card = int(cards[i]);
					this.dispense(0, card);
				}
			}else{
				setTimeout(onRoundEnd, 500);//玩家的牌全部爆牌庄家不需要发牌
			}
			money = Number(data.account);
			auto = false;
		}
		
		/** 分牌 **/
		public function onSplited(father_id:int,son_id:int,father_card:Array,new_stage:Object):void{
			/**----  处理子桌  ----**/
			table = this.tables[son_id];
			if ( table != null ){
				table.reset();
				table.actived = true;
				table.isSplited = true;
				betToTable(son_id, new_stage.amount[HttpComunicator.SPLIT]);
			}else{
				betToTable(son_id, new_stage.amount[HttpComunicator.SPLIT]);
				table = this.tables[son_id];
			}
			
			if (currentTables.indexOf(son_id) == -1){
				this.currentTables.push(son_id);
			}
			
			poker = tables[father_id].getCard(int(new_stage.cards));
			GameUtils.assert(poker != null,'mgr.onSplited:0'+father_id+' has no ' +new_stage.cards);
			tables[father_id].removeCard(poker);
			
			poker.x = 0 ;
			poker.y = 0;
			poker.rotation = 0;
			
			var targetPoint:Point = table.display.poker_con.globalToLocal(poker.parent.localToGlobal(new Point(poker.x,poker.y)));
			table.display.poker_con.addChild(poker);
			table.display.visible = true;
			poker.x = targetPoint.x;
			poker.y = targetPoint.y;
			TweenLite.to(poker, 0.5, {x:0, y:0, onComplete:onSplitComplete, onCompleteParams:[poker, table]});
			
			/**---  处理父桌  ---**/
			var table:TableData = this.tables[father_id];
			var poker:Poker;
			//必须在这里拿到不然下面的reset就要清空导致报错
			poker = table.getCard(int(father_card[0]));
			//GameUtils.assert(poker != null,'mgr.onSplited:1'+father_id+' has no ' +new_stage.cards);
			table.reset();
			table.currentBet = new_stage.amount[HttpComunicator.SPLIT];
			table.actived = true;
			table.isSplited = true;
			
			table.display.addCard(poker, false);
			//GameUtils.log('Table:', son_id, 'Points:', table.points,'Bet:',table.currentBet,new_stage.amount[HttpComunicator.SPLIT]);
			dispense(father_id, int(father_card[1]));
		}
		
		public function onSplitComplete(poker:Poker, table:TableData):void{
			//table.display.poker_con.addChild(poker);
			table.addCard(poker);
			table.display.updatePoints();
			//GameUtils.log('onSplitComplete--> Table:', table.tableId, 'Points:', table.points);
		}
		
		public function onStandBack(data:Object):void{
			var tabId:int = data.tabId;
			putToEnd(tabId);
		}
		
		public function onDoubled(newCard:int, tabId:int, tableData:Object):void{
			var table:TableData = this.tables[tabId];
			table.currentBet = int(tableData.amount[HttpComunicator.START]) +  int(tableData.amount[HttpComunicator.SPLIT]) +int(tableData.amount[HttpComunicator.DOUBLE]);
			table.display.showBet();
			table.doubled = true;
			dispense(tabId, newCard);
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
			//GameUtils.log('Before put ', tabId, 'to the end', this.currentTables.join('.'), ' vs ', this.endTables.join('.'));
			var index:int = this.currentTables.indexOf(tabId);
			if ( index != -1){
				this.currentTables.splice(index, 1);
			}
			
			if ( this.endTables.indexOf(tabId) == -1){
				var table:TableData = tables[tabId];
				/*
				if ( table.blackjack ){
					soundMgr.playEffect(SoundsEnum.BLACKJACK);
				}*/
				table.display.selected = false;
				table.display.updatePoints(true);
				this.endTables.push(tabId);
				//GameUtils.log('after ', this.currentTables.join('.'), ' vs ', this.endTables.join('.'));
			}
			
			if( check )
				nextTable();
		}
		
		public function onTableEnd(tabId:int, data:Object, displayEnd:Boolean=true):void{
			//GameUtils.log('mgr.onTableEnd', tabId);
			var table:TableData = this.tables[tabId];
			table.prize = 0;
			if ( data['prize'] != null ){
				if (data.prize[HttpComunicator.START] != null){
					table.prize += data.prize[HttpComunicator.START];
				}
				
				if (data.prize[HttpComunicator.SPLIT] != null){
					table.prize += data.prize[HttpComunicator.SPLIT];
				}
				
				if (data.prize[HttpComunicator.DOUBLE] != null){
					table.prize += data.prize[HttpComunicator.DOUBLE];
				}
			}
			
			if( displayEnd )
				table.display.end();
		}
		
		public function getInsuredTables():void{
			var obj:Object = {};
			obj.wayId = HttpComunicator.INSURE;
			obj.stage = {};
			var need:Number = 0;
			var table:TableData;
			for each (var i:int in this.currentTables){
				table = this.tables[i];
				
				if ( table.insured){
					obj.stage[i] = {};
					obj.stage[i][HttpComunicator.INSURE] = table.currentBet * 0.5;
					need += table.currentBet * 0.5;
				}
			}
			if ( need <= _money){
				HttpComunicator.Instance.send(HttpComunicator.INSURE, obj, 0);
			}else{
				for each (i in this.currentTables){
					table = this.tables[i];
					if(table.display.visible){
						table.insured = false;
						table.display.btn_insurrance.visible = true;
					}
				}
				
				Reminder.Instance.show("余额不足");
				buttons.switchModel(Buttons.MODEL_INSRRUREABLE);
				buttons.enable(true);
			}
		}

		/**
		 * 重置桌子：目前只在关闭筹码值显示的时候调用
		 * **/
		public function resetTable(tabId:int):void{
			if( !started && !starting ){
				var subTable:SubTable = this.subTableDisplays[tabId];
				subTable.reset();
				var baseTable:BaseTable = this.tableDisplays[tabId];
				baseTable.reset(true);
				var tableData:TableData = this.tables[tabId];
				if( tableData != null)
					tableData.reset();
			}
		}
		/**
		 * 重置
		 * **/
		public function reset():void{
			for (var key:String in this.tables){
				tables[key].reset();
			}
			for ( key in this.tableDisplays){
				tableDisplays[key].reset(true);
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
			this.requestedBaneker = false;
			this.needCheck = false;
			this.playBlackJack = false;
			
			PokerGameVars.TempInsureCost = 0;
		}
		/**
		 * 桌子是否可以点击下注
		 * **/
		public function enableDisplayMouse(value:Boolean):void{
			var tableDisplay:BaseTable;
			for (var key in this.tableDisplays){
				tableDisplay = tableDisplays[key];
				tableDisplay.table.mouseChildren = tableDisplay.pair.mouseChildren = tableDisplay.table.mouseEnabled = tableDisplay.pair.mouseEnabled = value;
			}
		}
		
		private var auto:Boolean = false;
		public function autoGame():void{
			GameUtils.log('mgr.autoGame:', auto, started);
			if ( auto || !started ) return;
			auto = true;
			autoStep();
		}
		
		public function autoStep():void{
			if ( !auto || !started || HttpComunicator.lock) return;
			GameUtils.log('Auto Step');
			if ( _currentTable != null ){
				if ( _currentTable.points >= 17 ){
					buttons.enable(false);
					
					var obj:Object = {};
					obj.wayId = HttpComunicator.STOP;
					obj.stage = {};
					obj.stage[_currentTable.tableId] = [];
					HttpComunicator.Instance.send(HttpComunicator.STOP, obj,_currentTable.tableId);
				}else{
					obj = {};
					obj.wayId = HttpComunicator.HIT;
					obj.stage = {};
					obj.stage[_currentTable.tableId] = [];
					HttpComunicator.Instance.send(HttpComunicator.HIT,obj,_currentTable.tableId);
				}
			}
		}
		
		public function showAutoRemind(timeRest:int):void{
			OverTimeReminder.Instance.show(timeRest);
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