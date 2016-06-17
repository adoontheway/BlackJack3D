package uiimpl 
{
	import consts.PokerGameVars;
	import game.ui.mui.ChipUI;
	
	/**
	 * ...
	 * @author jerry.d
	 */
	public class ChipImpl extends ChipUI 
	{
		private var _value:uint;//bet value
		private var _index:int;//bg related
		public function ChipImpl(tindex:int=-1) 
		{
			super();
			if ( tindex != -1){
				this.index = tindex;
			}
		}
		
		public function set value(val:uint):void{
			if ( this._value == val) return;
			this._value = val;
			this.lab_0.text = PokerGameVars.CHIP_SHOWS[val];
		}
		
		public function get value():uint{
			return this._value;
		}
		
		public function set index(val:uint):void{
			if ( this._index == val) return;
			this._index = val;
			if ( val > 4 ) return;
			this.img_0.skin = 'png.images.chip_side_'+val;
		}
		
		public function get index():uint{
			return this._index;
		}
		
		public function roll():void{
			this.img_0.rotation++;
		}
	}

}