package uiimpl 
{
	import comman.duke.*;
	import consts.PokerGameVars;
	import flash.events.MouseEvent;
	import game.ui.mui.LoginUI;
	import model.ProtocolClientEnum;
	
	/**
	 * ...
	 * @author jerry.d
	 */
	public class LoginImpl extends LoginUI 
	{
		
		public function LoginImpl() 
		{
			super();
			this.btn_login.addEventListener(MouseEvent.CLICK, onLogin);
			this.x = GameVars.Stage_Width - this.width >> 1;
			this.y = GameVars.Stage_Height - this.height >> 1;
		}
		
		private function onLogin(evt:MouseEvent):void{
			var username:String = this.name_input.text;
			var password:String = this.pass_input.text;
			if ( username.length == 0 || password.length == 0){
				GameUtils.log('input illegal');
				return;
			}
			SocketMgr.Instance.send({proto:ProtocolClientEnum.PROTO_LOGIN, user:username, pass:password});
		}
		
		private static var _instance:LoginImpl;
		public static function get Instance():LoginImpl{
			if ( LoginImpl._instance == null){
				LoginImpl._instance = new LoginImpl();
			}
			return LoginImpl._instance;
		}
	}

}