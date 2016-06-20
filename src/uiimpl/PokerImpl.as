package uiimpl 
{
	import comman.duke.IRecyclable;
	import consts.PokerGameVars;
	import game.ui.mui.PokerUI;
	
	/**
	 * ...
	 * @author jerry.d
	 */
	public class PokerImpl extends PokerUI implements IRecyclable
	{
		public var targetX:int;
		public var targetY:int;
		public var targetRotate:Number;
		public function PokerImpl(val:int = -1) 
		{
			super();
			if ( val != -1 ){
				this.value = val;
			}
		}
		private var _value:int = -1;
		public var type:uint;
		public var realValue:uint;
		public var compareValue:uint = 0;
		public function get value():int{
			return this._value;
		}
		
		public function set value(val:int):void{
			if ( this._value == val ) return;
			this.realValue = (val-1)%13+1;
			this.compareValue = this.realValue < 10 ? this.realValue : 10;
			this.lab_0.text = this.lab_1.text = PokerGameVars.Chars[realValue-1];
			this.type = Math.ceil(val / 13);
			this.img_0.url = this.img_1.url = "png.images.type_" + this.type;
			this.name = 'poker_' + val;
		}
		
		public function reset():void{
			
		}
		
		public function destroy():void{
			
		}
	}

}