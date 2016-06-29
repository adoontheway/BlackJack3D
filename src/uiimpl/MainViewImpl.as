package uiimpl 
{
	import com.greensock.loading.core.DisplayObjectLoader;
	import comman.duke.display.BitmapClip;
	import consts.PokerGameVars;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	import game.ui.mui.MainViewUI;
	import model.ProtocolClientEnum;
	import model.TableData;
	import morn.core.components.Button;
	import morn.core.components.Image;
	import comman.duke.*;
	import com.greensock.*;
	import utils.TableUtil;
	/**
	 * ...
	 * @author jerry.d
	 */
	public class MainViewImpl extends MainViewUI 
	{		
		private var mgr:GameMgr;
		private var frameItem:FrameItem;
		private var socketMgr:SocketMgr;
		
		//-------------ui elments ------------------//

		public function MainViewImpl() 
		{
			super();
			this.init();
		}
		private var arrow:MovieClip;
		private function init():void{
			//this.circles = [];
			socketMgr = SocketMgr.Instance;
			
			mgr = GameMgr.Instance;
			mgr.mainView = this;
			
			var model:uint = mgr.model;
			var chipValues:Array = PokerGameVars.Model_Config[model];
			ChipsViewUIImpl.Instance.setupValues(chipValues);
			addChild(ChipsViewUIImpl.Instance);

			this.addChild(new BaseTable(1));
			this.addChild(new BaseTable(2));
			this.addChild(new BaseTable(3));
			this.addChild(Buttons.Instance);
			
			balance.btn_recharge.addEventListener(MouseEvent.CLICK, onRecharge);
			
			var Arrow:Class = getDefinitionByName('Arrow') as Class;
			if ( Arrow != null){
				this.arrow = new Arrow() as MovieClip;
				this.arrow.addEventListener(Event.ADDED_TO_STAGE, playArrow);
				this.arrow.addEventListener(Event.REMOVED_FROM_STAGE, stopArrow);
			}
			
			frameItem = new FrameItem('mainView', this.update);
			FrameMgr.Instance.add(frameItem);
			/*
			var clip:BitmapClip = new BitmapClip('anims', 'anim_dispense');
			clip.play( -1);
			this.addChild(clip);
			*/
		}
		
		private function onRecharge(evt:MouseEvent):void{
			
		}
		
		private function playArrow(evt:Event):void{
			this.arrow.play();
		}
		
		private function stopArrow(evt:Event):void{
			this.arrow.stop();
		}
		
		//private var totalBet:int = 0;
		private var currentTable:TableData;
		private function onTweenComplete():void{
			//tweening = false;
			/**
			if ( this.tweenQueue.length){
				var temp:Poker = this.tweenQueue.shift();
				//GameUtils.log('ready tweening:', temp.name);
				this.onDispenseBack(temp);
			}else{
				//check split, insurrance
				currentTable = mgr.currentTable;
				
				if ( currentTable != null ){
					//this.arrow.x = currentTable.arrowX;
					//this.arrow.y = currentTable.arrowY;
					this.stage.addChild(this.arrow);
					
					if ( mgr.needShowInsure){
						showBtns(INSURRANCE);
					}else 
					
					if ( currentTable.canSplit ){
						//showBtns(SPLIT);
					}else if ( currentTable.blackjack || currentTable.bust ){
						socketMgr.send({proto:ProtocolClientEnum.PROTO_STAND, tabId:currentTable.tableId});
					}else{
						//showBtns(OPER);
					}
				}
			}
			*/
		}
		
		
		
		
		
		public function updateBalance(value:Number):void{
			this.balance.lab_0.text = GameUtils.NumberToString(value);
		}
		
		public function updateBet():void{
			//this.bet.lab.text = GameUtils.NumberToString(totalBet);
		}
		
		public function update(delta:int):void{
			if ( PokerGameVars.Glow_Filter.strength == 1){
				PokerGameVars.Glow_Filter.strength = 2;
			}else{
				PokerGameVars.Glow_Filter.strength = 1;
			}
			//this.lab_time.text = 'Now:'+GameUtils.GetDateTime(TickerMgr.SYSTIME);
		}
		
		public function onStarted():void{
			
		}
		
		public function onDoubleBack(tabId:int, moreBet:int):void{
			//this.totalBet += moreBet;
			this.updateBet();
		}
		
		public function onStandBack():void{
			currentTable = mgr.currentTable;
			if ( currentTable != null ){
				//this.arrow.x = currentTable.arrowX;
				//this.arrow.y = currentTable.arrowY;
				if ( currentTable.canSplit ){
					//showBtns(SPLIT);
				}else if ( currentTable.blackjack || currentTable.bust ){
					socketMgr.send({proto:ProtocolClientEnum.PROTO_STAND, tabId:currentTable.tableId});
				}else{
					//this.stage.addChild(this.arrow);
					//this.arrow.play();
					//showBtns(OPER);
				}
			}
		}
		
		private var tweening:Boolean = false;
		private var tweenQueue:Array = [];
		public function onDispenseBanker(poker:Poker):void{
			if ( tweening ){
				tweenQueue.push(poker);
				return;
			}
			this.banker_poker_con.addChild(poker);
			var startPos:Point = banker_poker_con.globalToLocal( PokerGameVars.DispensePostion);
			poker.x = startPos.x;
			poker.y = startPos.y;
			poker.targetX = banker_poker_con.x+banker_poker_con.numChildren*20;
			poker.targetY = banker_poker_con.y;
			tweening = true;
			TweenLite.to(poker, 0.5, {rotationX:0, x:poker.targetX, y:poker.targetY, onComplete:this.reOrderBankerContaner});
		}
		
		private function reOrderBankerContaner():void{
			tweening = false;
			TableUtil.reOrderContainer(banker_poker_con, 0, 200, 200);
			if ( tweenQueue.length != 0 ){
				var poker:Poker = tweenQueue.shift();
				onDispenseBanker(poker);
				return;
			}
		}
		
		public function onRoundEnd():void{
			/**
			var poker:Poker;
			while (this.allPoker.length != 0){
				poker = allPoker.pop();
				this.stage.removeChild(poker);
				PoolMgr.reclaim(poker);
			}
			var chip:Chip;
			while ( this.allChip.length != 0){
				chip = this.allChip.pop();
				this.stage.removeChild(chip);
				PoolMgr.reclaim(chip);
			}
			/**
			for each(var mc:MovieClip in this.circles){
				mc.mouseChildren = mc.mouseEnabled = true;
			}
			if( this.arrow && this.arrow.parent != null)
				this.stage.removeChild(this.arrow);
			this.arrow.stop();
			this.showBtns(START);
			*/
			var poker:Poker;
			while ( banker_poker_con.numChildren != 0){
				poker = banker_poker_con.removeChildAt(0) as Poker;
				PoolMgr.reclaim(poker);
			}
			//this.totalBet = 0;
		}
		private var dispenserPos:Point = new Point(612, 50);
		public function onResize():void{
			this.x = GameVars.Stage_Width - this.width >> 1;
			PokerGameVars.DispensePostion = this.localToGlobal(dispenserPos);
		}
		
		private static var _instance:MainViewImpl;
		public static function get Instance():MainViewImpl{
			if ( MainViewImpl._instance == null){
				MainViewImpl._instance = new MainViewImpl();
			}
			return MainViewImpl._instance;
		}
	}

}