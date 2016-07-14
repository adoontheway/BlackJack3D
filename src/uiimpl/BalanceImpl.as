package uiimpl 
{
	import comman.duke.FrameItem;
	import comman.duke.FrameMgr;
	import comman.duke.GameUtils;
	import comman.duke.SoundMgr;
	import consts.SoundsEnum;
	import flash.events.MouseEvent;
	import game.ui.mui.BalanceUI;
	
	/**
	 * ...
	 * @author jerry.d
	 */
	public class BalanceImpl extends BalanceUI 
	{
		private var frameItem:FrameItem;
		public function BalanceImpl() 
		{
			super();
			this.name = 'balanceui';
			this.y = 40;
			frameItem = new FrameItem(name, update);
			btn_recharge.addEventListener(MouseEvent.CLICK, onRecharge);
		}
		
		private function onRecharge(evt:MouseEvent):void{
			SoundMgr.Instance.playEffect( SoundsEnum.BUTTON ); 
		}
		
		public function update(delta:int):void{
			var gap:Number = _blance - current;
			if ( Math.abs(gap) < 1){
				this.lab_0.text = GameUtils.NumberToString(_blance);
				FrameMgr.Instance.remove(name);
			}else{
				current += gap * 0.25;
				this.lab_0.text = GameUtils.NumberToString(current);
			}
		}
		
		private var _blance:Number = 0;
		private var current:Number = 0;
		public function set balance(val:Number):void{
			if ( _blance == val ) return;
			current = _blance;
			if ( _blance == 0 ){
				this.lab_0.text = GameUtils.NumberToString(_blance);
			}
			this._blance = val;
			
			if ( current != 0 && !FrameMgr.Instance.has(name) ){
				FrameMgr.Instance.add(frameItem);
			}
		}
		
		public function get balance():Number{
			return _blance;
		}
		
		public function onResize():void{
			this.x = MainViewImpl.Instance.x + 800;
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