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
	import flash.system.ApplicationDomain;
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
		
		private function init():void{
			socketMgr = SocketMgr.Instance;
			
			mgr = GameMgr.Instance;
			mgr.mainView = this;
			
			this.addChild(new BaseTable(1));
			this.addChild(new BaseTable(2));
			this.addChild(new BaseTable(3));
			
			this.banker_poker_con.scale = 0.8;
			this.point_display.visible = false;
			
			ChipsViewUIImpl.Instance.updateChips();
			ChipsViewUIImpl.Instance.switchCover(false);
			addChild(ChipsViewUIImpl.Instance);
		}
		
		public function afterStart():void{
			Buttons.Instance.switchModel(Buttons.MODEL_START);
			if( !HttpComunicator.gameDataFlag ){
				Buttons.Instance.enable(false);
			}
			this.addChild(Buttons.Instance);
		}
		
		public var bankerData:TableData;
		public function updatePoints(isSettled:Boolean = false):void{
			this.lab_points.size = 30;
			this.lab_points.y = 12;
			if ( !bankerData.bust ){
				if ( !bankerData.blackjack){
					if ( bankerData.numA == 0 || (bankerData.numA != 0 && bankerData.points >= 11) ){
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
		private var startMiddlePos:Point;
		public function onDispenseBanker(poker:Poker):void{
			if ( tweening ){
				tweenQueue.push(poker);
				return;
			}
			this.banker_poker_con.addChild(poker);
			if( startPos == null){
				startPos = banker_poker_con.globalToLocal( PokerGameVars.DispensePostion);
				startMiddlePos = new Point(startPos.x - 10, startPos.y + 100);
			}
				
			poker.x = startPos.x;
			poker.y = startPos.y;
			poker.targetX = banker_poker_con.numChildren*20;
			poker.targetY = 0;
			tweening = true;
			SoundMgr.Instance.playEffect( SoundsEnum.CARD ); 
			tweenPhase1(poker);
			//TweenLite.to(poker, 0.4, {rotationY:0, x:poker.targetX, y:poker.targetY,rotation:0, onComplete:this.reOrderBankerContaner});
		}
		
		private function tweenPhase1(poker:Poker):void{
			poker.scale = 0.8;
			TweenLite.to(poker, 0.2, {scale:1, x:startMiddlePos.x, y:startMiddlePos.y, onComplete:this.tweenPhase2, onCompleteParams:[poker]});
		}
		
		private function tweenPhase2(poker:Poker):void{
			TweenLite.to(poker, 0.3, {rotationY:0, x:poker.targetX, y:poker.targetY,rotation:0, onComplete:this.reOrderBankerContaner});
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
			updatePoints();
		}
		
		public function traverseTheFakePoker(poker:Poker):void{
			SoundMgr.Instance.playEffect(SoundsEnum.REVERSE);
			poker.rotationY = 180;
			TweenLite.to(poker, 0.2, {rotationY:0,onComplete:onTraverseComplete});		
		}
		
		private function onTraverseComplete():void{
			//GameUtils.log('Fake card reverse complete..');
			updatePoints();
			if ( !tweening ){
				mgr.onBankerDispense();
			}
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
		private var dispenserMiddlePos:Point = new Point(600, 150);
		private var diapearPos:Point = new Point(50, 80);
		private var chipLostPos:Point = new Point(350, 50);
		private var chipGainPos:Point = new Point(850, 50);
		public function onResize():void{
			this.x = GameVars.Stage_Width - this.width >> 1;
			PokerGameVars.DispensePostion = this.localToGlobal(dispenserPos);
			PokerGameVars.DispensePostion.y -= this.y;
			PokerGameVars.DispenseMiddlePostion = this.localToGlobal(dispenserMiddlePos);
			PokerGameVars.DispenseMiddlePostion.y -= this.y;
			
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