package 
{
	import comman.duke.IRecyclable;
	import morn.core.components.Image;
	
	/**
	 * ...
	 * @author jerry.d
	 */
	public class Poker extends Image
	{
		public var targetX:int;
		public var targetY:int;
		public var targetRotate:Number;
		private var _value:int = -1;
		public var type:uint;
		public var realValue:uint;
		public var compareValue:uint = 0;
		public function Poker(value:int=-1) 
		{
			super(url);
			if (value != -1){
				this.value = value;
			}
			//this.anchorX = 0.5;
			//this.anchorY = 0.5;
		}
		
		public function set value(val:int):void{
			if ( this._value == val ) return;
			_value = val;
			if ( val == -1 ){
				this.url = 'png.pokers.back';
			}else{
				
				this.realValue = (val-1)%13+1;
				this.compareValue = this.realValue < 10 ? this.realValue : 10;
				this.type = Math.ceil(val / 13);
				this.url = 'png.pokers.' + realValue;
				this.name = 'poker_' + val;
			}	
		}
		
		public function get value():int{
			return _value;
		}
		
		override public function set rotationX(value:Number):void{
			super.rotationX  = value;
			if ( rotationX > 90 ){
				if ( this.url != 'png.pokers.back'){
					this.url = 'png.pokers.back';
				}
			}else{
				if ( this.url != 'png.pokers.' + realValue){
					this.url = 'png.pokers.' + realValue
				}
			}
		}
	}

}