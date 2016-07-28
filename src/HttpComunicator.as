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
	import flash.utils.setInterval;
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
		public static var cookieHeader:URLRequestHeader = new URLRequestHeader('Cookie', 'laravel_session=eyJpdiI6IllCK3g0MSsyVU9PWEtVdmw4WkJ1VjQzVVVZRHZOQjdlZEFNYXdLMmJQYnM9IiwidmFsdWUiOiJZM2tqeWxIQis0dUoyNnJzSHpWODJKZHNReGFEM2xHNjc3bTk5NE14NTU2d0s0RnV0MDlrdWhUUml0UHZNSXpvNkhRZFwvUDluV21RTVVjZlFQZ1piclE9PSIsIm1hYyI6IjY1OTdkMGNkZDM4MTliYmUxZmIzMzg0MWFjYWZmNDY1MDFkOWM4YTJiNzI4M2RhOGNhMTBlMDZjYzVmOGE1ZWMifQ%3D%3D');
		
		public var mgr:GameMgr;
		public function HttpComunicator() 
		{
			
		}
		
		public function send(wayId:int, data:*, tableId:int):void{
			GameUtils.log(wayId, JSON.stringify(data));
			var loader:SomeUrlLoader = PoolMgr.gain(SomeUrlLoader);
			var request:URLRequest = new URLRequest(submitUrl);
			request.method = URLRequestMethod.POST;
			var vars:URLVariables = new URLVariables();
			vars._token = _token;
			vars.betdata =  JSON.stringify(data);
			request.data = vars;
			loader.load(data.wayId, tableId, request,onComplete,onError);
		}
		
		public function requesAccount():void{
			//return;
			var loader:SomeUrlLoader = PoolMgr.gain(SomeUrlLoader);
			var request:URLRequest = new URLRequest(pollUserAccountUrl);
			request.method = URLRequestMethod.POST;
			loader.load(0,0,request,onAccountInfo,onError);
			
		}
		
		public function requestGameData():void{
			var loader:SomeUrlLoader = PoolMgr.gain(SomeUrlLoader);
			var request:URLRequest = new URLRequest(submitUrl);
			request.method = URLRequestMethod.POST;
			
			var vars:URLVariables = new URLVariables();
			vars.betdata = JSON.stringify({ stage:0, wayId:9 });
			vars._token = _token;
			
			request.data = vars;
			loader.load(HttpComunicator.GAME_DATA,0,request,onComplete,onError);
			
			/**
			var aa:String = '{"iSuccess":1,"msg":"\u6295\u6ce8\u6210\u529f","data":{"banker":{"cards":["405"]},"player":{"1":{"cards":"212,409","amount":{"6":100,"7":50},"is_pair":0,"father_table_id":0,"double":0,"split_table_id":0,"stop":0,"bust":0,"blackJack":0,"insurance":0,"hitAbleCount":10},"2":{"cards":"201,307","amount":{"6":50,"7":50},"is_pair":0,"father_table_id":0,"double":0,"split_table_id":0,"stop":0,"bust":0,"blackJack":0,"insurance":1,"hitAbleCount":10},"3":{"cards":"312,108","amount":{"6":100,"7":200},"is_pair":0,"father_table_id":0,"double":0,"split_table_id":0,"stop":0,"bust":0,"blackJack":0,"insurance":0,"hitAbleCount":10}},"gameInfo":{"position":7,"jacpotPrize":82.463,"iRequestPrize":550,"jacpotEnough":0,"projectIds":[1398,1399,1400,1401,1402,1403],"manProjectId":189}}}';
			var result:* = JSON.parse(aa);
			this.onGameData(result.data);
			*/
		}
		
		private function onAccountInfo(proto:int,tabldId:int,str:String):void{
			//GameUtils.log(loader.data);
			//return;
			var result:* = JSON.parse(str);
			if ( result.isSuccess == 1){
				var data:Object =  result.data[0].data[0];
				if ( data.type == "balance"){
					var balance = parseFloat(data.data);
					//GameUtils.log("balance:",balance);
					GameMgr.Instance.money = balance;
					BalanceImpl.Instance.rockAndRoll();
				}
			}
		}
		
		private function onComplete(proto:int, tabId:int, data:String):void{
			//GameUtils.log('proto back:', proto, data);
			var result:* = JSON.parse(data);
			if ( result.iSuccess == 1){
				GameUtils.log('proto :', proto);
				switch(proto){
					case SPLIT:
						onSplitBack(result.data,tabId);
						break;
					case HIT:
						onHitBack(result.data);
						break;
					case STOP:
						onStopBack(result.data, tabId);
						break;
					case DOUBLE:
						break;
					case INSURE:
						break;
					case START:
						onStart(result.data);
						break;
					case PAIR:
						break;
					case BANKER_TURN:
						onBankerTurn(result.data);
						break;
					case GAME_DATA:
						onGameData(result.data);
						break;
				}
			}else{
				FloatHint.Instance.show(result.msg);
			}
		}
		
		private function onSplitBack(data:Object,tableId:int):void{
			mgr.onSplited(tableId, data.father_card, data.newCards);
		}
		
		private function onBankerTurn(data:Object):void{
			var cards:Array = data.banker.cards;
			mgr.onBankerTurn(cards);
		}
		
		private function onStopBack(data:*, tableId:int):void{
			mgr.onStandBack({tabId:tableId});
		}
		
		private function onHitBack(data:Object):void{
			GameUtils.log('onHit ', data.banker,  data.player);
			var stage:Object = data.stage;
			mgr.dispense(data.stageId,int(data.newCard));
		}
		
		private function onStart(data:Object):void{
			GameUtils.log('onStart ', data.banker,  data.player);
			if ( data.banker != null && data.player != null ){
				initDispatch(data);
			}
		}
		
		private function onGameData(data:Object):void{
			GameUtils.log('onGameData ');
			if ( data.banker != null && data.player != null ){
				FloatHint.Instance.show("Request game data finished");
				initDispatch(data);
			}
		}
		
		private function initDispatch(data:Object):void{
			var arr:Array = [];
			var tempArr:Array;
			var maxLen:int = 0;
			var len:int = 0;
			var cardsMap:Object = {};
			//GameUtils.log('initDispatch');
			for (var i:String in data.player){
				arr.push(int(i));
				tempArr =  data.player[i].cards.split(",");
				len = tempArr.length;
				maxLen = len < maxLen ? maxLen : len;
				cardsMap[i] = tempArr;
			}
			cardsMap[0] = data.banker.cards;
			arr.sort();
			mgr.onStarted(data.player, 0);			
			arr.push(0);
			len = arr.length;
			var tabId:int;
			//GameUtils.log('arr:',arr.join(','));
			for (var j:int = 0; j < len; j++){
				tabId = arr[j];
				tempArr = cardsMap[tabId];
				//GameUtils.log('loop:',j,' tabld:'+tabId,' tempArr:'+tempArr,' arrLen:'+len,' repeat:'+maxLen);
				if ( tempArr.length != 0){
					mgr.dispense(tabId, int(tempArr.pop()));
				}
				
				if ( j == len -1 ){
					maxLen--;
					if ( maxLen <= 0 ){
						//GameUtils.log(j,maxLen);
						break;
					}else{
						j = -1;
					}
				}
			}
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