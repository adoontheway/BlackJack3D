package 
{
	import com.worlize.websocket.WebSocket;
	import com.worlize.websocket.WebSocketEvent;
	import comman.duke.*;
	import comman.duke.TickerMgr;
	import consts.CodeInfo;
	import consts.PokerGameVars;
	import flash.events.IOErrorEvent;
	import flash.utils.setTimeout;
	import model.ProtocolServerEnum;
	import uiimpl.*;
	/**
	 * ...
	 * @author jerry.d
	 */
	public class SocketMgr 
	{
		private var socket:WebSocket;
		public function SocketMgr() 
		{
			
		}
		
		public function init():void{
			this.socket = new WebSocket("ws://10.10.4.69:3333", "ws://10.10.4.69:3333");
			this.socket.addEventListener(WebSocketEvent.MESSAGE, onMessage);
			this.socket.addEventListener(WebSocketEvent.OPEN, onOpen);
			this.socket.addEventListener(WebSocketEvent.PING, onPing);
			this.socket.addEventListener(WebSocketEvent.PONG, onPong);
			this.socket.addEventListener(WebSocketEvent.CLOSED, onClosed);
			this.socket.addEventListener(WebSocketEvent.FRAME, onFrame);
			this.socket.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			this.socket.connect();
			mgr = GameMgr.Instance;
		}
		
		public function send(data:*):void{
			return;
			if (!this.socket.connected){
				FloatHint.Instance.show('服务器已经断开连接，请重新进入游戏');
				return;
			}
			var msg:String = JSON.stringify(data);
			GameUtils.log('sended: ', msg); 
			this.socket.sendUTF(msg);
		}
		
		private function parseData(data:Object):void{
			var code:uint = data.code;
			var proto:uint = data.proto;
			if ( code != 0 ){
				GameUtils.fatal('Error : ', CodeInfo.getInfo(code), ' from proto ', proto);
				return;
			}
			switch(proto){
				case ProtocolServerEnum.S_R_LOGIN:
					this.onLogin(data);
					break;
				case ProtocolServerEnum.S_B_DISPENSE:
					this.onDispense(data);
					break;
				case ProtocolServerEnum.S_B_HEARTBEAT:
					this.onHeartbeat(data);
					break;
				case ProtocolServerEnum.S_B_TURN:
					this.onTurn(data);
					break;
				case ProtocolServerEnum.S_R_BET:
					this.onBet(data);
					break;
				case ProtocolServerEnum.S_R_SPLIT:
					this.onSplit(data);
					break;
				case ProtocolServerEnum.S_R_STAND:
					this.onStand(data);
					break;
				case ProtocolServerEnum.S_R_SURRENDER:
					this.onSurrender(data);
					break;
				case ProtocolServerEnum.S_R_START:
					this.onStarted(data);
					break;
				case ProtocolServerEnum.S_R_DOUBLE:
					this.onDoubleBack(data);
					break;
				case ProtocolServerEnum.S_R_HIT:
					//use for notice bust
					break;
				case ProtocolServerEnum.S_B_ROUND_END:
					this.onRoundEnd(data);
					break;
				case ProtocolServerEnum.S_B_END://游戏结束并结算
					this.onTableEnd(data);
					break;
				case ProtocolServerEnum.S_R_INSURE://游戏结束并结算
					this.onInsurranceBack(data);
					break;
				case ProtocolServerEnum.S_B_FAKE_CARD://游戏结束并结算
					this.onFakeCard(data);
					break;
				case ProtocolServerEnum.S_B_PAIR_RESULT://游戏结束并结算
					this.pairBetResult(data);
					break;
				default:
					GameUtils.log('unhandled proto ', proto);
					break;
			}
		}
		private var mgr:GameMgr;
		private function pairBetResult(data:Object):void{
			//mgr.onPairBetResult(data);
		}
		private function onFakeCard(data:Object):void{
			var card:int = data.card;
			mgr.onFakeCard(card);
		}
		
		private function onTableEnd(data:*):void{
			if (data.hasOwnProperty('money')){
				mgr.money = data.money;
			}
			mgr.onTableEnd(data);
			
		}
		
		private function onRoundEnd(data:*):void{
			setTimeout(function():void{
				//MainViewImpl.Instance.onRoundEnd();
				mgr.onRoundEnd();
			}, 2000);
		}
		
		private function onHitResult(data:*):void{
			
		}
		private function onInsurranceBack(data:*):void{
			mgr.onInsureBack(data);
		}
		
		private function onDoubleBack(data:*):void{
			mgr.onDoubleBack(data);
		}
		
		private function onStarted(data:*):void{
			mgr.onStarted(data.tables,data.money, true);
		}
		
		private function onDispense(data:Object):void{
			mgr.dispense(data.table, data.card);
		}
		private function onBet(data:Object):void{
		}
		private function onTurn(data:Object):void{
		}
		private function onHeartbeat(data:Object):void{
		}
		private function onSplit(data:Object):void{
			mgr.onSplitBack(data);
		}
		private function onStand(data:Object):void{
			mgr.onStandBack(data);
		}
		private function onSurrender(data:Object):void{
		}
		private function onLogin(data:Object):void{
			GameVars.STAGE.removeChild(LoginImpl.Instance);
			GameVars.STAGE.addChild( MainViewImpl.Instance);
			//MainViewImpl.Instance.showBtns(MainViewImpl.START);
			mgr.money = data.money;
			//MainViewImpl.Instance.updateBalance(data.money);
		}
		
		private function onMessage(evt:WebSocketEvent):void{
			GameUtils.info('recieve message:', evt.message.utf8Data);
			var data:Object = JSON.parse(evt.message.utf8Data);
			TickerMgr.SYSTIME = data.time;
			this.parseData(data);
		}
		
		private function onOpen(evt:WebSocketEvent):void{
			GameUtils.log('opened');
		}
		
		private function onPing(evt:WebSocketEvent):void{
			GameUtils.log('onping');
		}
		
		private function onPong(evt:WebSocketEvent):void{
			GameUtils.log('onpong');
		}
		private function onClosed(evt:WebSocketEvent):void{
			FloatHint.Instance.show('CONNECTION CLOSED...');
		}
		private function onFrame(evt:WebSocketEvent):void{
			GameUtils.log('onframe');
		}
		private function onIOError(evt:IOErrorEvent):void{
			GameUtils.log(evt.text);
		}
		private var reconnectiong:Boolean = false;
		
		private static var _instance:SocketMgr;
		public static function get Instance():SocketMgr{
			if ( SocketMgr._instance == null){
				SocketMgr._instance = new SocketMgr();
			}
			return SocketMgr._instance;
		}
	}

}