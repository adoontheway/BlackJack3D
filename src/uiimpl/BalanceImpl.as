package uiimpl 
{
	import game.ui.mui.BalanceUI;
	
	/**
	 * ...
	 * @author jerry.d
	 */
	public class BalanceImpl extends BalanceUI 
	{
		
		public function BalanceImpl() 
		{
			super();
			this.y = 10;
		}
		
		private var _blance:int;
		public function set balance(val:int):void{
			
		}
		
		public function get balance():int{
			return _blance;
		}
		
		private static var _instance:BalanceImpl;
		public static function get Instance():BalanceImpl{
			if ( BalanceImpl._instance == null){
				BalanceImpl._instance = new BalanceImpl();
			}
			return BalanceImpl._instance;
		}
	}

}