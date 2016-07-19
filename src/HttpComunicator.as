package 
{
	import comman.duke.*;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	/**
	 * ...
	 * @author jerry.d
	 */
	public class HttpComunicator 
	{
		public static var SERVER_ADDR:String;
		public function HttpComunicator() 
		{
			
		}
		
		public function send(data:*):void{
			if (!this.socket.connected){
				return;
			}
			var msg:String = JSON.stringify(data);
			var loader:URLLoader = PoolMgr.gain(URLLoader);
			var request:URLRequest = new URLRequest(SERVER_ADDR);
			request.method = URLRequestMethod.POST;
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			loader.data = msg;
			loader.load(request);
			GameUtils.log('http sended: ', msg); 
		}
		
		private function onComplete(e:Event):void{
			var loader:URLLoader = e.target as URLLoader;
			var result:Object = JSON.parse(loader.data);
			parseData(data);
		}
		
		private function onError(e:IOErrorEvent):void{
			GameUtils.fatal(e.text);
		}
		
		private function parseData(data:Object):void{
			
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