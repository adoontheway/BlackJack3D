package uiimpl 
{
	import comman.duke.FrameItem;
	import comman.duke.FrameMgr;
	import comman.duke.GameUtils;
	import comman.duke.SoundMgr;
	import consts.SoundsEnum;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
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
			
			this.addEventListener(Event.ADDED_TO_STAGE, onAdded);
			btn_recharge.addEventListener(MouseEvent.CLICK, onRecharge);
		}
		
		private function onAdded(e:Event):void{
			this.lab_0.font = 'Din';
			this.balance = GameMgr.Instance.money;
			this.removeEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		private function onRecharge(evt:MouseEvent):void{
			
		}
		
		public function update(delta:int):void{
			var gap:Number = _blance - current;
			if ( Math.abs(gap) < 1){
				this.lab_0.text = GameUtils.NumberToString(_blance,',',0);
				FrameMgr.Instance.remove(name);
			}else{
				current += gap * 0.25;
				this.lab_0.text = GameUtils.NumberToString(current,',',0);
			}
			//GameUtils.log("balance update",current);
		}
		
		public function rockAndRoll():void{
			//GameUtils.log("rock and roll",current);
			if( current!= -99999 && !FrameMgr.Instance.has(name) )
				FrameMgr.Instance.add(frameItem);
		}
		
		private var _blance:int = 0;
		private var current:Number = -99999;
		private var timeout:int = -1;
		public function set balance(val:int):void{
			//GameUtils.log("set balance",val);
			if ( _blance == val ) return;
			current = _blance;
			if ( _blance == 0 ){
				this.lab_0.text = GameUtils.NumberToString(_blance,',',0);
			}
			this._blance = val;
		}
		
		public function get balance():int{
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