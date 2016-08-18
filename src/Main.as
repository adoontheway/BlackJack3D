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
	import flash.events.MouseEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.system.ApplicationDomain;
	import flash.system.Security;
	import flash.text.Font;
	import flash.utils.ByteArray;
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
			
			parseParams();
			Security.allowDomain('*');
			//Security.loadPolicyFile('xmlsocket://10.10.4.69:843/crossdomain.xml');
			
			openupLoader = new Loader();
			openupLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onOpenUpLoaded);
			openupLoader.load(new URLRequest(PokerGameVars.resRoot+"swfs/openup.swf?v="+PokerGameVars.VERSION));
			App.init(this);
			
			App.loader.loadAssets([PokerGameVars.resRoot+"assets/loading.swf"],new Handler(onLoadingViewLoaded));
			
			GameVars.STAGE = stage;
			GameVars.Stage_Width = stage.stageWidth;
			GameVars.Stage_Height = stage.stageHeight;
			
			stage.frameRate = 30;
			stage.quality = StageQuality.HIGH;
			GameUtils.test();
			GameUtils.DEBUG_LEVEL = GameUtils.LOG;
			FrameMgr.Instance.init(stage);
			SoundMgr.Instance.playBg(SoundsEnum.BG);
			SoundMgr.Instance.playEffect(SoundsEnum.WELCOME);
		}
		
		private function parseParams():void{
			var params:Object = stage.loaderInfo.parameters;
			
			if ( ExternalInterface.available){
				PokerGameVars.NEED_CRYPTO = params.is_encode == 1;
				PokerGameVars.resRoot = params.resRoot;
				HttpComunicator._token = params._token;
				HttpComunicator.is_agent = params.is_agent;
				HttpComunicator.submitUrl = params.submitUrl;
				HttpComunicator.loaddataUrl = params.loaddataUrl;
				HttpComunicator.pollUserAccountUrl = params.pollUserAccountUrl;
				HttpComunicator.rechargeUrl = params.rechargeUrl;
			}
			GameMgr.Instance.setup(params.table || 1);
		}
		
		private function onLoadingViewLoaded():void{
			App.loader.loadAssets([
				PokerGameVars.resRoot+"assets/bg.swf?v="+PokerGameVars.VERSION,
				PokerGameVars.resRoot+"assets/chips.swf?v="+PokerGameVars.VERSION, 
				PokerGameVars.resRoot+"assets/ui.swf?v="+PokerGameVars.VERSION, 
				PokerGameVars.resRoot+"assets/nums.swf?v="+PokerGameVars.VERSION,
				PokerGameVars.resRoot+"assets/pokers.swf?v="+PokerGameVars.VERSION, 
				PokerGameVars.resRoot+"assets/images.swf?v="+PokerGameVars.VERSION,
				PokerGameVars.resRoot+"assets/comp.swf?v="+PokerGameVars.VERSION,
				PokerGameVars.resRoot+"swfs/effects.swf?v="+PokerGameVars.VERSION], 
				new Handler(onAssetsLoade), 
				new Handler(onProgress)
			);
				
			LoadView.Instance.show();
		}
		
		private function onProgress(value:Number):void{
			LoadView.Instance.showProgress(value);
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
			HttpComunicator.Instance.requesAccount();//assets all loaded, or something display incorrectly
			
			bgLoaded();
			
			LoadView.Instance.hide();
			
			if ( ApplicationDomain.currentDomain.hasDefinition('DinBold')){
				var FontClass:Class = ApplicationDomain.currentDomain.getDefinition('DinBold') as Class;
				Font.registerFont(FontClass);
			}
			

			SoundsEnum.InitSounds();
			MainViewImpl.Instance.y = -150;
			this.stage.addChild(MainViewImpl.Instance);
			this.stage.addChild(BalanceImpl.Instance);
			
			var SoundBtn :Class = ApplicationDomain.currentDomain.getDefinition('SoundBtn') as Class; 
			
			if ( SoundBtn != null){
				var mc:MovieClip = new SoundBtn() as MovieClip;
				mc.x = 50;
				mc.y = 100;
				this.stage.addChild(mc);
				SoundMgr.Instance.setBtn(mc);
			}
			
			onResize(null);
			othersLoaded = true;
			if ( openupLoaded ){
				playOpenUp();
			}
		}
		
		private function onResize(evt:Event):void{
			GameVars.Stage_Width = stage.stageWidth;
			GameVars.Stage_Height = stage.stageHeight;
			GameVars.RedrawMask();
			if ( this.bg ){
				this.bg.x = GameVars.Stage_Width - bg.width >> 1;
			}
			
			if ( MainViewImpl.Instance.parent ){
				MainViewImpl.Instance.onResize();
			}
			if( BalanceImpl.Instance.parent)
				BalanceImpl.Instance.onResize();
				
			if ( OverTimeReminder.Instance.parent != null){
				OverTimeReminder.Instance.onResize();
			}
			
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
	}
	
}