package
{
	import comman.duke.*;
	import comman.duke.display.BitmapClipFactory;
	import consts.*;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.UncaughtErrorEvent;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.utils.setTimeout;
	import morn.core.handlers.Handler;
	import uiimpl.*;
	
	/**
	 * ...
	 * @author jerry.d
	 */
	[SWF(width='1897',height='1020',backgroundColor='0x0',frameRate='30')]
	public class Main extends Sprite 
	{
		public function Main() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		private var openupLoader:Loader;
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUnknownError);
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.RESIZE, onResize);
			
			
			parseParams();
			Security.allowDomain('*');
			Security.loadPolicyFile('xmlsocket://10.10.4.69:843/crossdomain.xml');
			
			openupLoader = new Loader();
			openupLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onOpenUpLoaded);
			openupLoader.load(new URLRequest("resource/swfs/openup.swf"));
			
			App.init(this);
			
			App.loader.loadAssets([
			"assets/bg.swf",
			"assets/chips.swf", 
			"assets/ui.swf", 
			"assets/nums.swf",
			"assets/pokers.swf", 
			"assets/images.swf",
			"assets/comp.swf",
			"resource/swfs/effects.swf"], new Handler(onAssetsLoade));
			//App.loader.loadAssets([], new Handler(bgLoaded));
			//comman.duke.display.BitmapClipFactory.Instance.loadAnim();
			
			GameVars.STAGE = stage;
			GameUtils.DEBUG_LEVEL = GameUtils.FATAL;
			
			FrameMgr.Instance.init(stage);
		}
		
		private function onUnknownError(event:UncaughtErrorEvent):void{
			var message:String;
             
             if (event.error is Error)
             {
                 message = Error(event.error).message;
             }
             else if (event.error is ErrorEvent)
             {
                 message = ErrorEvent(event.error).text;
             }
             else
             {
                 message = event.error.toString();
             }
			 GameUtils.fatal('Stage Uncaught Errors :', message);
		}
		
		private function parseParams():void{
			var params:Object = stage.loaderInfo.parameters;
			PokerGameVars.Model = params.model || 0;//场次
			PokerGameVars.Desk = params.desk || 0;//桌子id
		}
		private var openupLoaded:Boolean;
		private var othersLoaded:Boolean;
		private function onOpenUpLoaded(e:Event):void{
			openupLoaded = true;
			if ( othersLoaded ){
				playOpenUp();
			}
		}
		
		private function playOpenUp():void{
			openupLoader.x = this.stage.stageWidth >> 1;
			openupLoader.y = this.stage.stageHeight >> 1;
			this.stage.addChild(openupLoader);
			setTimeout(function():void{
				disposeOpenup();
			}, 5000);
		}
		
		private function disposeOpenup():void{
			this.stage.removeChild(openupLoader);
			openupLoader.unloadAndStop();
		}
		
		private var bg:Bitmap;
		private var desk:Bitmap;
		private function bgLoaded():void{
			//var claz:* = App.asset.getAsset('jpg.bg.bg');
			//this.bg = new Bitmap(claz);
			var claz:* = App.asset.getAsset('png.bg.desk');
			this.desk = new Bitmap(claz);
			//this.addChild(bg);
			this.addChild(desk);
			
		}
		private function onAssetsLoade():void{
			SocketMgr.Instance.init();
			bgLoaded();
			this.stage.addChild(MainViewImpl.Instance);
			onResize(null);
			othersLoaded = true;
			if ( openupLoaded ){
				playOpenUp();
			}
			//this.stage.addChild(LoginImpl.Instance);
		}
		
		private function onResize(evt:Event):void{
			GameVars.Stage_Width = stage.stageWidth;
			GameVars.Stage_Height = stage.stageHeight;
			if ( this.bg ){
				this.bg.x = GameVars.Stage_Width - bg.width >> 1;
			}
			if ( this.desk ){
				this.desk.x = GameVars.Stage_Width - desk.width >> 1;
			}
			
			//OperationViewImpl.Instance.resize();
			if ( MainViewImpl.Instance.parent ){
				MainViewImpl.Instance.onResize();
			}
		}
	}
	
}