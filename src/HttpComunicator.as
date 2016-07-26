package 
{
	import comman.duke.*;
	import comman.duke.loader.SomeUrlLoader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import uiimpl.BalanceImpl;
	/**
	 * ...
	 * @author jerry.d
	 */
	public class HttpComunicator 
	{
		public static const SPLIT:int = 1;
		public static const HIT:int = 2;
		public static const STOP:int = 3;
		public static const DOUBLE:int = 4;
		public static const INSURE:int = 5;
		public static const START:int = 6;
		public static const PAIR:int = 7;
		public static const BANKER_TURN:int = 8;
		public static const GAME_DATA:int = 9;
		
		
		public static var submitUrl:String =  "http://t.bomao.lgv/casino/bet/8001/1";
		public static var loaddataUrl:String = "http://t.bomao.lgv/bets/load-data/8001";
		public static var pollUserAccountUrl:String = "http://t.bomao.lgv/users/user-account-info";
		public static var currentTime:Number = 1469425223;
		public static var _token:String = "EyBkMMA9prt7GN1IAaSqLXr1FmueWjvsbHoIm0Ys";
		public static var is_agent:int = 1;
		public static var cookieHeader:URLRequestHeader = new URLRequestHeader('Cookie', 'laravel_session=eyJpdiI6Ik9jckpTVEJLblNwNmNDaHJ0ZlhrRU5Eb2VFV01McHRxNGJ6TXA3TGljVEk9IiwidmFsdWUiOiJYWHJ6d3hUMjZyK3lcL1FValcxaE5KUXdad1NNUlZselhDZTc3YVNXWFJpblVkazQxRWF2SVZFOUlmazBHYkUwbDRDUUFjU1Q1bUlTWGtyanhZK0NRUEE9PSIsIm1hYyI6ImQ1NGNkYTE5MDEyOWZhZTJiNGM4YTg3YWRjZmE2YzlmNzkyYjliOTdkNmJiODc2MGQzZDY2MWU0YjU3YzEzNjkifQ%3D%3D');
		public function HttpComunicator() 
		{
			
		}
		
		public function send(data:*):void{
			var loader:SomeUrlLoader = PoolMgr.gain(SomeUrlLoader);
			var request:URLRequest = new URLRequest(submitUrl);
			request.method = URLRequestMethod.POST;
			//loader.dataFormat = URLLoaderDataFormat.TEXT;
			//loader.addEventListener(Event.COMPLETE, onComplete);
			//loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			
			var vars:URLVariables = new URLVariables();
			vars._token = _token;
			vars.betdata = JSON.stringify(data);
			request.data = vars;
			loader.load(data.wayId,request,onComplete,onError);
		}
		
		public function requesAccount():void{
			var loader:SomeUrlLoader = PoolMgr.gain(SomeUrlLoader);
			var request:URLRequest = new URLRequest(pollUserAccountUrl);
			request.method = URLRequestMethod.POST;
			//loader.dataFormat = URLLoaderDataFormat.TEXT;
			//loader.addEventListener(Event.COMPLETE, onAccountInfo);
			//loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.load(0,request,onAccountInfo,onError);
		}
		
		public function requestGameData():void{
			var obj:Object = {};
			obj.wayId = HttpComunicator.GAME_DATA;
			obj.stage = {};
			send(obj);
		}
		
		private function onAccountInfo(e:Event):void{
			var loader:URLLoader = e.target as URLLoader;
			//GameUtils.log(loader.data);
			var result:* = JSON.parse(loader.data);
			if ( result.isSuccess == 1){
				var data:Object =  result.data[0].data[0];
				if ( data.type == "balance"){
					var balance = parseFloat(data.data);
					GameUtils.log("balance:",balance);
					GameMgr.Instance.money = balance;
					BalanceImpl.Instance.rockAndRoll();
				}
			}
		}
		
		private function onComplete(proto:int, data:String):void{
			GameUtils.log('proto back:', proto, data);
			var result:* = JSON.parse(data);
			if ( result.iSuccess == 1){
				switch(proto){
					case SPLIT:
						break;
					case HIT:
						break;
					case STOP:
						break;
					case DOUBLE:
						break;
					case INSURE:
						break;
					case START:
						break;
					case PAIR:
						break;
					case BANKER_TURN:
						break;
					case GAME_DATA:
						onGameData(result.data);
						break;
				}
			}else{
				FloatHint.Instance.show(result.msg);
			}
		}
		
		private function onGameData(data:Object):void{
			if ( data.banker != null && data.player != null ){
				initDispatch(data);
			}
		}
		
		private function initDispatch(){
			var arr = [];
		}
		
		
		private function onError(proto:*, e:IOErrorEvent):void{
			GameUtils.fatal(e.text);
		}
		
		private static var _instance:HttpComunicator;
		public static function get Instance():HttpComunicator{
			if ( HttpComunicator._instance == null){
				HttpComunicator._instance = new HttpComunicator();
			}
			return HttpComunicator._instance;
		}
	}

}