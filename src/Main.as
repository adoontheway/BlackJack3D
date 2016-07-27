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
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.UncaughtErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.system.ApplicationDomain;
	import flash.system.Security;
	import flash.text.Font;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import morn.core.handlers.Handler;
	import uiimpl.*;
	
	/**
	 * ...
	 * @author jerry.d
	 */
	[SWF(width='1897',height='1020',backgroundColor='0x0')]
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
			
			trace(Font.enumerateFonts(false));
			
			parseParams();
			Security.allowDomain('*');
			//Security.loadPolicyFile('xmlsocket://10.10.4.69:843/crossdomain.xml');
			
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
			"resource/swfs/effects.swf"], 
			new Handler(onAssetsLoade));
			
			//App.loader.loadAssets([], new Handler(bgLoaded));
			//comman.duke.display.BitmapClipFactory.Instance.loadAnim();
			
			GameVars.STAGE = stage;
			
			stage.frameRate = 30;
			//stage.quality = StageQuality.HIGH_16X16;
			
			GameUtils.DEBUG_LEVEL = GameUtils.LOG;
			GameUtils.log(PokerGameVars.VERSION);
			FrameMgr.Instance.init(stage);
			SoundMgr.Instance.playBg(SoundsEnum.BG);
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
			if ( ExternalInterface.available){
				HttpComunicator._token = params._token;
				HttpComunicator.is_agent = params.is_agent;
				HttpComunicator.submitUrl = params.submitUrl;
				HttpComunicator.loaddataUrl = params.loaddataUrl;
				HttpComunicator.cookieHeader = new URLRequestHeader("Cookie",params.cookie);
			}
			
			//GameUtils.log('model and desk:', params.model, params.desk);
			
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
			openupLoader.y = 170;
			openupLoader.blendMode = 'add';
			this.stage.addChild(openupLoader);
			var stopTime:uint = Math.floor(1000*140 / 30);
			setTimeout(function():void{
				disposeOpenup();
				MainViewImpl.Instance.afterStart();
				HttpComunicator.Instance.requestGameData();
			}, stopTime);
		}
		
		private function disposeOpenup():void{
			this.stage.removeChild(openupLoader);
			openupLoader.unloadAndStop();
		}
		
		private var bg:Bitmap;
		private function bgLoaded():void{
			var claz:* = App.asset.getAsset('jpg.bg.bg');
			this.bg = new Bitmap(claz);
			this.addChild(bg);
			
		}
		private function onAssetsLoade():void{
			//SocketMgr.Instance.init();
			bgLoaded();
			if ( ApplicationDomain.currentDomain.hasDefinition('DinBold')){
				//GameUtils.log('register the font');
				var FontClass:Class = ApplicationDomain.currentDomain.getDefinition('DinBold') as Class;
				Font.registerFont(FontClass);
			}
			SoundsEnum.InitSounds();
			MainViewImpl.Instance.y = -150;
			this.stage.addChild(MainViewImpl.Instance);
			this.stage.addChild(BalanceImpl.Instance);
			onResize(null);
			othersLoaded = true;
			if ( openupLoaded ){
				playOpenUp();
			}
		}
		
		private function onResize(evt:Event):void{
			GameVars.Stage_Width = stage.stageWidth;
			GameVars.Stage_Height = stage.stageHeight;
			if ( this.bg ){
				this.bg.x = GameVars.Stage_Width - bg.width >> 1;
			}
			
			if ( MainViewImpl.Instance.parent ){
				MainViewImpl.Instance.onResize();
			}
			if( BalanceImpl.Instance.parent)
				BalanceImpl.Instance.onResize();
		}
	}
	
}