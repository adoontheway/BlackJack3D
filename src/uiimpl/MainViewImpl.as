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
			
			Buttons.Instance.switchModel(Buttons.MODEL_START);
			this.banker_poker_con.scaleX = this.banker_poker_con.scaleY = 0.8;
			/*
			var Arrow:Class = getDefinitionByName('Arrow') as Class;
			if ( Arrow != null){
				this.arrow = new Arrow() as MovieClip;
				this.arrow.addEventListener(Event.ADDED_TO_STAGE, playArrow);
				this.arrow.addEventListener(Event.REMOVED_FROM_STAGE, stopArrow);
			}
			
			frameItem = new FrameItem('mainView', this.update);
			FrameMgr.Instance.add(frameItem);
			
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
		public function updateBalance(value:Number):void{
			this.balance.lab_0.text = GameUtils.NumberToString(value);
		}
		
		public function updateBet():void{
			//this.bet.lab.text = GameUtils.NumberToString(totalBet);
		}
		
		public function update(delta:int):void{
			//this.lab_time.text = 'Now:'+GameUtils.GetDateTime(TickerMgr.SYSTIME);
		}
		
		public function onDoubleBack(tabId:int, moreBet:int):void{
			//this.totalBet += moreBet;
			this.updateBet();
		}
		
		
		private var tweening:Boolean = false;
		private var tweenQueue:Array = [];
		private var startPos:Point;
		public function onDispenseBanker(poker:Poker):void{
			if ( tweening ){
				tweenQueue.push(poker);
				return;
			}
			this.banker_poker_con.addChild(poker);
			if( startPos == null)
				startPos = banker_poker_con.globalToLocal( PokerGameVars.DispensePostion);
			poker.x = startPos.x;
			poker.y = startPos.y;
			poker.targetX = banker_poker_con.numChildren*20;
			poker.targetY = 0;
			tweening = true;
			if (poker.value != -1){
				TweenLite.to(poker, 0.5, {rotationY:0, x:poker.targetX, y:poker.targetY, onComplete:this.reOrderBankerContaner});
			}else{
				TweenLite.to(poker, 0.5, {x:poker.targetX, y:poker.targetY, onComplete:this.reOrderBankerContaner});
			}
			
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
		
		public function traverseTheFakePoker(card:int):void{
			var index:int = 0;
			var num:int = this.banker_poker_con.numChildren;
			var poker:Poker;
			while (index < num){
				poker = this.banker_poker_con.getChildAt(index) as Poker;
				if ( poker.value == -1){
					poker.value = card;
					poker.rotationY = 180;
					TweenLite.to(poker, 0.3, {rotationY:0});
					break;
				}
				index++;
			}
		}
		
		public function checkTheFakePoker():void{
			var index:int = 0;
			var num:int = this.banker_poker_con.numChildren;
			var poker:Poker;
			while (index < num){
				poker = this.banker_poker_con.getChildAt(index) as Poker;
				if ( poker.value == -1){
					//todo popup and shake it
					break;
				}
				index++;
			}
		}
		
		public function onRoundEnd():void{
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