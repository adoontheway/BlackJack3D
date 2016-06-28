package 
{
	import morn.core.components.Image;
	
	/**
	 * ...
	 * @author jerry.d
	 */
	public class Chip extends Image 
	{
		private var _value:uint;
		public function Chip(_val:int=-1) 
		{
			if ( _val != -1){
				this.value = _val;
			}
		}
		public function set value(val:uint):void{
			if ( this._value == val) return;
			this._value = val;
			this.url = 'png.chips.chip-' + val;
		}
		
		public function get value():uint{
			return _value;
		}
	}

}