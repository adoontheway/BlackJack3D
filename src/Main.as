package
{
	import comman.duke.*;
	import comman.duke.display.BitmapClipFactory;
	import consts.*;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.system.Security;
	import morn.core.handlers.Handler;
	import uiimpl.*;
	
	/**
	 * ...
	 * @author jerry.d
	 */
	[SWF(width='750',height='505',backgroundColor='0x0',frameRate='30')]
	public class Main extends Sprite 
	{
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			onResize(null);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			parseParams();
			Security.allowDomain('*');
			
			App.init(this);
			App.loader.loadAssets(["assets/bg.swf"], new Handler(bgLoaded));
			App.loader.loadAssets(["assets/chips.swf", "assets/ui.swf", "assets/pokers.swf", "assets/images.swf","assets/comp.swf","resource/swfs/effects.swf"], new Handler(onAssetsLoade));
			
			comman.duke.display.BitmapClipFactory.Instance.loadAnim();
			
			GameVars.STAGE = stage;
			GameUtils.DEBUG_LEVEL = GameUtils.LOG;
			
			FrameMgr.Instance.init(stage);
			
			stage.addEventListener(Event.RESIZE, onResize);
		}
		
		private function parseParams():void{
			var params:Object = stage.loaderInfo.parameters;
			PokerGameVars.Model = params.model || 0;//场次
			PokerGameVars.Desk = params.desk || 0;//桌子id
		}
		
		private function bgLoaded():void{
			var claz:* = App.asset.getAsset('png.bg.398');
			this.addChildAt(new Bitmap(claz),0);
			
		}
		private function onAssetsLoade():void{
			/**
			this.addChildAt( ChipsViewUIImpl.Instance, 1);
			this.addChildAt( OperationViewImpl.Instance, 1);
			ChipsViewUIImpl.Instance.updateChips();
			OperationViewImpl.Instance.showBetMsg();
			*/
			SocketMgr.Instance.init();
			this.stage.addChild(LoginImpl.Instance);
			/**
			PokerMgr.Instance.addPlayers();
			*/
		}
		private function onResize(evt:Event):void{
			GameVars.Stage_Width = stage.stageWidth;
			GameVars.Stage_Height = stage.stageHeight;
			//OperationViewImpl.Instance.resize();
		}
	}
	
}