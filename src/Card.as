package 
{
	import morn.core.components.Image;
	
	/**
	 * ...
	 * @author jerry.d
	 */
	public class Card extends Image 
	{
		private var _value:uint;
		private var _realValue:uint;
		public function Card(value:uint=0,url:String=null) 
		{
			super(url);
			if (value != 0){
				this.value = value;
			}
			this.scale = 0.3;
		}
		
		public function set value(val:uint):void{
			if (this._value == val) return;
			this._value = val;
			this._realValue = val % 13 + 1;
			this.url = 'png.pokers.' + realValue;
		}
		
		public function get value():uint{
			return _value;
		}
		
		public function get realValue():uint{
			return _realValue;
		}
		
		override public function set rotationX(value:Number):void{
			super.rotationX  = value;
			if ( rotationX > 90 ){
				if ( this.url != 'png.pokers.back'){
					this.url = 'png.pokers.back';
				}
			}else{
				if ( this.url != 'png.pokers.' + _realValue){
					this.url = 'png.pokers.' + _realValue
				}
			}
		}
	}

}