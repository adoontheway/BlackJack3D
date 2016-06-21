package 
{
	import com.worlize.websocket.WebSocket;
	import com.worlize.websocket.WebSocketEvent;
	import comman.duke.*;
	import comman.duke.TickerMgr;
	import consts.CodeInfo;
	import consts.PokerGameVars;
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
			this.socket.connect();
			mgr = GameMgr.Instance;
		}
		
		public function send(data:*):void{
			if (!this.socket.connected){
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
				default:
					GameUtils.log('unhandled proto ', proto);
					break;
			}
		}
		private var mgr:GameMgr;
		private function onTableEnd(data:*):void{
			if (data.hasOwnProperty('money')){
				mgr.money = data.money;
			}
			if ( data.result == -1){
				FloatHint.Instance.show('YOU LOSE '+data.gain);
			}else if ( data.result == 1){
				FloatHint.Instance.show('YOU WIN'+data.gain);
			}else{
				FloatHint.Instance.show('DRAW ROUND!');
			}
		}
		private function onRoundEnd(data:*):void{
			mgr.onRoundEnd();
			setTimeout(function():void{
				MainViewImpl.Instance.onRoundEnd();
			}, 2000);
			
		}
		private function onHitResult(data:*):void{
			
		}
		private function onDoubleBack(data:*):void{
			
		}
		private function onStarted(data:*):void{
			mgr.onStarted(data.table);
			MainViewImpl.Instance.onStarted();
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
			MainViewImpl.Instance.showBtns(MainViewImpl.START);
			mgr.money = data.money;
			MainViewImpl.Instance.updateBalance(data.money);
		}
		
		private function onMessage(evt:WebSocketEvent):void{
			GameUtils.log('recieve message:', evt.message.utf8Data);
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
			GameUtils.log('onclose');
		}
		private function onFrame(evt:WebSocketEvent):void{
			GameUtils.log('onframe');
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