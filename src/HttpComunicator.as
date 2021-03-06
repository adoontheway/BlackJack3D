package 
{
	import comman.duke.*;
	import comman.duke.loader.SomeUrlLoader;
	import consts.PokerGameVars;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import uiimpl.BalanceImpl;
	import uiimpl.Buttons;
	
	import flash.utils.ByteArray;
	import com.hurlant.util.Base64;
	import com.hurlant.util.Hex;
	import com.hurlant.crypto.Crypto;
	import com.hurlant.crypto.symmetric.AESKey;
	import com.hurlant.crypto.symmetric.ICipher;
	import com.hurlant.crypto.symmetric.IPad;
	import com.hurlant.crypto.symmetric.IVMode;
	import com.hurlant.crypto.symmetric.NullPad;
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
		
		private const decrKey:String = '0123456789abcdef';
		private	const decrIV:String = '1234567891234567';
		private var key:ByteArray;
		private var pad:IPad;
		private var aes:ICipher;
		public function HttpComunicator() 
		{
			key = Hex.toArray(Hex.fromString(decrKey));                
			pad = new NullPad();
			aes = Crypto.getCipher("aes-cbc", key, pad);
			var ivmode:IVMode = aes as IVMode;
			ivmode.IV = Hex.toArray(Hex.fromString(decrIV));    
		}
		private var lastRequestTime:uint = 0;
		
		public function send(wayId:int, data:*, tableId:int, isAutoRequest:Boolean=false):void{
			var now:uint = flash.utils.getTimer();
			if ( now - lastRequestTime < 1000 && !isAutoRequest){
				FloatHint.Instance.show("??????????????????");
				Buttons.Instance.enable(true);
				return;
			}
			lastRequestTime = now;
			
			//GameUtils.log(wayId, JSON.stringify(data));
			var loader:SomeUrlLoader = PoolMgr.gain(SomeUrlLoader);
			var request:URLRequest = new URLRequest(submitUrl);
			request.method = URLRequestMethod.POST;
			var vars:URLVariables = new URLVariables();
			vars._token = _token;
			//vars.betdata =  JSON.stringify(data);
			vars.betdata =  encrypto(data);
			request.data = vars;
			loader.load(data.wayId, tableId, request,onComplete,onError);
		}
		
		private function encrypto(obj:*):String{
			var src:String = JSON.stringify(obj);
			GameUtils.log('Sending:'+src);
			if ( !PokerGameVars.NEED_CRYPTO ){
				return src;
			}
			var inputBA:ByteArray=Hex.toArray(Hex.fromString(src));    
			aes.encrypt(inputBA); 
			return Base64.encodeByteArray(inputBA);
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
			vars.betdata = encrypto({ stage:0, wayId:9 });
			vars._token = _token;
			
			request.data = vars;
			loader.load(HttpComunicator.GAME_DATA,0,request,onComplete,onError);
		}
		
		private function onAccountInfo(proto:int,tabldId:int,str:String):void{
			//GameUtils.log(loader.data);
			try{
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
			}catch (e:Error){
				GameUtils.fatal('????????????????????????:',e.message);
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
						onDoubleBack(int(result.data.newCard), result.data.stageId, result.data.stage);
						mgr.money = Number(result.data.account);
						BalanceImpl.Instance.rockAndRoll();
						break;
					case INSURE:
						onInsure(result.data);
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
						onGameData(result.data, false);
						break;
					default:
						GameUtils.log('unknown proto', proto);
						break;
				}
			}else{
				Buttons.Instance.enable(true);
				if ( result.msg != null){
					FloatHint.Instance.show(result.msg);
				}else{
					FloatHint.Instance.show('??????????????????:'+result.errcode+" ?????????:"+proto+" stage:"+tabId);
				}
				
			}
		}
		
		private function onInsure(data:Object):void{
			//GameUtils.log('onInsureBack:');
			if (data.banker != null){
				mgr.onInsured(data.banker.cards,data.player);
			}else if ( data.bankerNewCard != null){
				mgr.onInsured(data.bankerNewCard,data.player);
			}
			mgr.money = Number(data.account);
			BalanceImpl.Instance.rockAndRoll();
		}
		
		private function onDoubleBack(newCard:int, tableId:int, tableData:Object):void{
			//GameUtils.log('onDoubleBack:',newCard,tableId);
			mgr.onDoubled(newCard, tableId, tableData);
			
			if ( tableData.bust == 1 ){
				setTimeout(function():void{
					mgr.onTableEnd(tableId,tableData);
				}, 500);
			}
		}
		
		private function onSplitBack(data:Object,tableId:int):void{
			mgr.onSplited(tableId, data.newStageId, data.father_card, data.newCards);
			mgr.money = Number(data.account);
			BalanceImpl.Instance.rockAndRoll();
		}
		
		private function onBankerTurn(data:Object):void{
			mgr.onBankerTurn(data);
			mgr.money = Number(data.account);
		}
		
		private function onStopBack(data:*, tableId:int):void{
			mgr.onStandBack({tabId:tableId});
		}
		
		private function onHitBack(data:Object):void{
			//GameUtils.log('onHit ', data.newCard,  data.stageId);
			mgr.onHited(data);
		}
		
		private function onStart(data:Object):void{
			//GameUtils.log('onStart ', data.banker,  data.player);
			if ( data.banker != null && data.player != null ){
				initDispatch(data,true);
			}
		}
		
		private function onGameData(data:Object, isStart:Boolean):void{
			//GameUtils.log('onGameData ');
			if ( data.banker != null && data.player != null ){
				FloatHint.Instance.show("????????????????????????");
				initDispatch(data,isStart);
			}else{
				Buttons.Instance.switchModel(Buttons.MODEL_START);
			}
		}
		
		private function initDispatch(data:Object, isStart:Boolean):void{
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
			var fakeCard:int = cardsMap[0].length == 1 ? -1 : cardsMap[0].pop();
			var needCheck:Boolean = int(cardsMap[0][0]) % 100 >= 10;
			arr.sort();
			mgr.onStarted(data.player,  Number(data.account),isStart);			
			arr.push(0);
			len = arr.length;
			var tabId:int;
			//GameUtils.log('arr:',arr.join(','));
			var num:uint = 0;
			for (var j:int = 0; j < len; j++){
				num++;
				tabId = arr[j];
				tempArr = cardsMap[tabId];
				//GameUtils.log('loop:',j,' tabld:'+tabId,' tempArr:'+tempArr,' arrLen:'+len,' repeat:'+maxLen);
				if ( tempArr.length != 0){
					mgr.dispense(tabId, int(tempArr.shift()));
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
			
			mgr.dispense(0, -1);
			num++;
			mgr.needPlayCheck = needCheck;
			mgr.fakeCard = fakeCard;
			/**
			if ( needCheck ){
				setTimeout(function():void{
					mgr.fakeCard = fakeCard;
					mgr.playCheck();
					if ( fakeCard != -1){
						mgr.endAllTables();
						mgr.onRoundEnd();
					}
				}, num * 500);
			}
			*/
		}
		
		private function onError(proto:*, tabldId:int, e:IOErrorEvent):void{
			GameUtils.fatal('ProtoId:',proto,'  tabelId:',tabldId, ' Error:',e.text);
			Buttons.Instance.enable(true);
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