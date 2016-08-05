package uiimpl 
{
	import com.greensock.loading.core.DisplayObjectLoader;
	import comman.duke.display.BitmapClip;
	import consts.PokerGameVars;
	import consts.SoundsEnum;
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
		//private var arrow:MovieClip;
		private function init():void{
			//this.circles = [];
			socketMgr = SocketMgr.Instance;
			
			mgr = GameMgr.Instance;
			mgr.mainView = this;
			
			this.addChild(new BaseTable(1));
			this.addChild(new BaseTable(2));
			this.addChild(new BaseTable(3));
			
			this.banker_poker_con.scale = 0.8;
			this.point_display.visible = false;
			var model:uint = mgr.currentModel;
			var chipValues:Array = PokerGameVars.Model_Config[model];
			ChipsViewUIImpl.Instance.setupValues(chipValues);
			ChipsViewUIImpl.Instance.switchCover(false);
			addChild(ChipsViewUIImpl.Instance);
			
			/*
			frameItem = new FrameItem('mainView', this.update);
			FrameMgr.Instance.add(frameItem);
			*/
		}
		
		public function afterStart():void{
			Buttons.Instance.switchModel(Buttons.MODEL_START);
			this.addChild(Buttons.Instance);
		}
		
		public var bankerData:TableData;
		public function updatePoints(isSettled:Boolean = false):void{
			this.lab_points.size = 30;
			this.lab_points.y = 12;
			if ( !bankerData.bust ){
				if ( !bankerData.blackjack){
					if ( !bankerData.hasA || (bankerData.hasA && bankerData.points >= 11) ){
						this.img_points_bg.url = 'png.images.green';
						if (bankerData.points < 21 ){
							this.lab_points.text =  bankerData.points+"";
						}else{
							this.lab_points.text =  bankerData.points+"";
						}
					}else{
						this.img_points_bg.url = 'png.images.green';
						this.lab_points.size = 30;
						this.lab_points.text =  (bankerData.points + 10) + "";
					}
					
				}else{
					this.img_points_bg.url = 'png.images.full';
					this.lab_points.text =  "21";
				}
			}else{
				this.img_points_bg.url = 'png.images.bust';
				this.lab_points.text = bankerData.points + "";
			}
			this.point_display.visible = true;
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
			SoundMgr.Instance.playEffect( SoundsEnum.CARD ); 
			if (poker.value != -1){
				TweenLite.to(poker, 0.4, {rotationY:0, x:poker.targetX, y:poker.targetY,rotation:0, onComplete:this.reOrderBankerContaner});
			}else{
				TweenLite.to(poker, 0.4, {x:poker.targetX, y:poker.targetY, rotation:0, onComplete:this.reOrderBankerContaner});
			}
			updatePoints();
		}
		public var showFakeCardAfterTween:Boolean;
		private function reOrderBankerContaner():void{
			tweening = false;
			TableUtil.reOrderContainer(banker_poker_con, 0, 200, 200);
			if ( tweenQueue.length != 0 ){
				var poker:Poker = tweenQueue.shift();
				onDispenseBanker(poker);
			}else {
				//GameUtils.log('Banker dipense complete..');
				mgr.onBankerDispense();
			}
			/**
			if (showFakeCardAfterTween){
				var index:int = 0;
				var num:int = this.banker_poker_con.numChildren;
				while ( index < num){
					poker = banker_poker_con.getChildAt(index) as Poker;
					if ( poker.value == -1){
						this.traverseTheFakePoker(poker);
						break;
					}
					index++;
				}
			}*/
		}
		
		public function traverseTheFakePoker(poker:Poker):void{
			SoundMgr.Instance.playEffect(SoundsEnum.REVERSE);
			poker.rotationY = 180;
			TweenLite.to(poker, 0.2, {rotationY:0});
			updatePoints();
			GameUtils.log('Fake card reverse complete..');
			mgr.onBankerDispense();
		}
		
		public function onRoundEnd():void{
			var poker:Poker;
			while ( banker_poker_con.numChildren != 0){
				poker = banker_poker_con.removeChildAt(0) as Poker;
				PoolMgr.reclaim(poker);
			}
			this.point_display.visible = false;
			this.showFakeCardAfterTween = false;
		}
		private var dispenserPos:Point = new Point(612, 50);
		private var diapearPos:Point = new Point(50, 80);
		private var chipLostPos:Point = new Point(350, 50);
		private var chipGainPos:Point = new Point(850, 50);
		public function onResize():void{
			this.x = GameVars.Stage_Width - this.width >> 1;
			PokerGameVars.DispensePostion = this.localToGlobal(dispenserPos);
			PokerGameVars.DispensePostion.y -= this.y;
			PokerGameVars.DisaprearPoint = this.localToGlobal(diapearPos);
			PokerGameVars.DisaprearPoint.y -= this.y;
			PokerGameVars.ChipLostPos = this.localToGlobal(chipLostPos);
			PokerGameVars.ChipLostPos.y -= this.y;
			PokerGameVars.ChipGainPos = this.localToGlobal(chipGainPos);
			PokerGameVars.ChipGainPos.y -= this.y;
		}
		/**
		 * true 弹出并显示筹码盖子
		 * false 拉上并打开筹码盖子
		 * */
		public function tween(flag:Boolean):void{
			if ( flag ){
				if ( this.y == 0 ) return;
				TweenLite.to(this, 0.5, {y:0});
				ChipsViewUIImpl.Instance.switchCover(true);
			}else{
				if ( this.y == -150 ) return;
				TweenLite.to(this, 0.5, {y:-150});
				ChipsViewUIImpl.Instance.switchCover(false);
			}
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