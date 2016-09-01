package 
{
	import comman.duke.*;
	import comman.duke.loader.SomeUrlLoader;
	import consts.PokerGameVars;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import uiimpl.BalanceImpl;
	import uiimpl.Buttons;
	import uiimpl.Reminder;
	
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
		public static const SPLIT:int = 1001;
		public static const HIT:int = 1002;
		public static const STOP:int = 1003;
		public static const DOUBLE:int = 1004;
		public static const INSURE:int = 1005;
		public static const START:int = 1006;
		public static const PAIR:int = 1007;
		public static const BANKER_TURN:int = 1008;
		public static const GAME_DATA:int = 1009;
		
		public static var lock:Boolean = false;
		
		public static var submitUrl:String =  "";
		public static var loaddataUrl:String = "";
		public static var pollUserAccountUrl:String = "";
		public static var rechargeUrl:String = "";
		public static var currentTime:Number = 1469425223;
		public static var _token:String = "";
		public static var is_agent:int = 1;
		public var mgr:GameMgr;
		
		public static var decrKey:String = '9WPH0OLXY498JC0X';
		public static var decrIV:String = 'X4O9HHJR05BFSD4I';
		private var key:ByteArray;
		private var pad:IPad;
		private var aes:ICipher;
		public function HttpComunicator() 
		{
			//GameUtils.log("HttpComunicator:",decrKey, decrIV);
			key = Hex.toArray(Hex.fromString(decrKey));                
			pad = new NullPad();
			aes = Crypto.getCipher("aes-cbc", key, pad);
			var ivmode:IVMode = aes as IVMode;
			ivmode.IV = Hex.toArray(Hex.fromString(decrIV));
		}
		
		private function encrypto(obj:*):String{
			var src:String = JSON.stringify(obj);
			GameUtils.log('Sending:'+src);
			if ( !PokerGameVars.NEED_CRYPTO ){
				return src;
			}
			var inputBA:ByteArray = Hex.toArray(Hex.fromString(src));    
			aes.encrypt(inputBA); 
			return Base64.encodeByteArray(inputBA);
		}
		
		public function send(wayId:int, data:*, tableId:int):void{
			lock = true;
			//GameUtils.log(wayId, JSON.stringify(data));
			var loader:SomeUrlLoader = PoolMgr.gain(SomeUrlLoader);
			var request:URLRequest = new URLRequest(submitUrl);
			request.method = URLRequestMethod.POST;
			var vars:URLVariables = new URLVariables();
			vars._token = _token;
			vars.betdata =  encrypto(data);
			vars.is_encode = PokerGameVars.NEED_CRYPTO ? 1 : 0;
			request.data = vars;
			loader.load(data.wayId, tableId, request,onComplete,onError);
		}
		
		/**
		 * 账户信息
		 * **/
		public function requesAccount():void{
			var loader:SomeUrlLoader = PoolMgr.gain(SomeUrlLoader);
			var request:URLRequest = new URLRequest(pollUserAccountUrl);
			request.method = URLRequestMethod.POST;
			loader.load(0,0,request,onAccountInfo,onError);
		}
		
		/**
		 * 游戏存档
		 * **/
		public function requestGameData():void{
			lock = true;
			var loader:SomeUrlLoader = PoolMgr.gain(SomeUrlLoader);
			var request:URLRequest = new URLRequest(submitUrl);
			request.method = URLRequestMethod.POST;
			
			var vars:URLVariables = new URLVariables();
			vars.betdata = encrypto({ stage:0, wayId:HttpComunicator.GAME_DATA });
			vars._token = _token;
			vars.is_encode = PokerGameVars.NEED_CRYPTO ? 1 : 0;
			
			request.data = vars;
			loader.load(HttpComunicator.GAME_DATA,0,request,onComplete,onError);
		}
		
		private function onAccountInfo(proto:int,tabldId:int,str:String, loader:SomeUrlLoader):void{
			//GameUtils.log(loader.data);
			try{
				var result:* = JSON.parse(str);
				if ( result.isSuccess == 1){
					var data:Object =  result.data[0].data[0];
					if ( data.type == "balance"){
						var balance = parseFloat(data.data);
						//GameUtils.log("balance:",balance);
						GameMgr.Instance.money = balance;
						if( BalanceImpl.Instance.parent != null)
							BalanceImpl.Instance.rockAndRoll();
					}
				}
			}catch (e:Error){
				Reminder.Instance.show('解析账户信息出错:'+e.message);
			}finally{
				loader.reset();
				PoolMgr.reclaim(loader);
			}
			
		}
		
		private function onComplete(proto:int, tabId:int, data:String, loader:SomeUrlLoader):void{
			lock = false;
			try{
				var result:* = JSON.parse(data);
				parseResult(proto,tabId, loader, result);
			}catch (e:Error){
				GameUtils.fatal('Error info:',e.message);
				if ( data.indexOf('<html ') != -1){
					navigateToURL(loader.request,'_self');
				}
			}
		}
		
		private function parseResult(proto:int, tabId:int, loader:SomeUrlLoader, result:Object):void{
			if ( result.iSuccess == 1){
				GameUtils.log('Recieve : proto ', proto);
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
				loader.reset();
				PoolMgr.reclaim(loader);
			}else{
				var code:int = result.errcode;
				if ( result.msg != null){
					Reminder.Instance.show(result.msg);
				}else{
					Reminder.Instance.show('未知的错误码:'+code+" 协议号:"+proto+" stage:"+tabId);
				}
				
				Buttons.Instance.enable(true);
				/**--------  错误码处理逻辑 ---------**/
				if ( code == -505 && proto == HttpComunicator.START && mgr.currentTable != null){//牌局已经开始
					mgr.currentTable.display.selected = true;
					loader.reset();
					PoolMgr.reclaim(loader);
				}else if ( code == -417){// && proto == HttpComunicator.BANKER_TURN){//超时结算
					/**
					mgr.requestedBaneker = false;
					Buttons.Instance.switchModel(Buttons.MODEL_END);
					PoolMgr.reclaim(loader);
					*/
					loader.resend();
					Buttons.Instance.enable( false );
				}else if ( code == -512 ){//系统繁忙
					loader.resend();
					Buttons.Instance.enable( false );
				}
			}
			if ( result.data.hasOwnProperty("account") ){
				if( ExternalInterface.available){
					ExternalInterface.call("updateBalance", result.data.account);
				}
				mgr.money = result.data.account;
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
			
			if ( tableData.stop == 1 && tableData.bust == 1 ){
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
			mgr.onHited(data);
		}
		
		private function onStart(data:Object):void{
			if ( data.banker != null && data.player != null ){
				initDispatch(data,true);
			}
		}
		
		private function onGameData(data:Object, isStart:Boolean):void{
			if ( data.banker != null && data.player != null ){
				Reminder.Instance.show("读取游戏存档完成");
				initDispatch(data,isStart);
			}
		}
		
		private function initDispatch(data:Object, isStart:Boolean):void{
			var arr:Array = [];
			var tempArr:Array;
			var maxLen:int = 0;
			var len:int = 0;
			var cardsMap:Object = {};
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
			mgr.onStarted(data.player,  Number(data.account), isStart, data['insuranced'] != null && data['insuranced'] == 1,fakeCard);			
			arr.push(0);
			len = arr.length;
			var tabId:int;
			var num:uint = 0;
			for (var j:int = 0; j < len; j++){
				num++;
				tabId = arr[j];
				tempArr = cardsMap[tabId];
				if ( tempArr.length != 0){
					mgr.dispense(tabId, int(tempArr.shift()));
				}
				
				if ( j == len -1 ){
					maxLen--;
					if ( maxLen <= 0 ){
						break;
					}else{
						j = -1;
					}
				}
			}
			
			mgr.dispense(0, -1);
			num++;
			mgr.needCheck = needCheck;
			if ( needCheck ){
				setTimeout(function():void{
					//mgr.fakeCard = fakeCard;//fakeCard在onStarted里面传入，根据他判断是否
					mgr.playCheck();
					if ( fakeCard != -1){
						mgr.endAllTables();
						//mgr.onRoundEnd();
					}
				}, num * 500);
			}
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