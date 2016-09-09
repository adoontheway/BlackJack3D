package 
{
	import com.greensock.TweenLite;
	import comman.duke.GameVars;
	import comman.duke.PoolMgr;
	import consts.PokerGameVars;
	import flash.geom.Point;
	import morn.core.components.Box;
	import morn.core.components.Image;
	import uiimpl.BalanceImpl;
	
	/**
	 * ...
	 * @author jerry.d
	 */
	public class Chip extends Image 
	{
		private var _value:uint;
		public function Chip() 
		{
		}
		public function set value(val:uint):void{
			if ( this._value == val) return;
			this._value = val;
			this.url = 'png.chips.chip-' + val;
		}
		
		public function get value():uint{
			return _value;
		}
		/**
		 * type : 0 lost  1 gain
		 * */
		public function autoHide(type:int):void{
			if ( this.parent ){
				var targetPosition:Point = type == 0 ? PokerGameVars.ChipLostPos : PokerGameVars.ChipGainPos;
				GameVars.Raw_Point.x = this.x;
				GameVars.Raw_Point.y = this.y;
				var point:Point = this.parent.localToGlobal(GameVars.Raw_Point);
				this.x = point.x;
				this.y = point.y;
				GameVars.STAGE.addChild(this);
				TweenLite.to(this, 0.5, {x:targetPosition.x, y:targetPosition.y, onComplete:removeSelf});
			}
		}
		
		public function removeSelf():void{
			if ( this.parent ){
				this.parent.removeChild(this);
				this.scale = 1;
			}
			BalanceImpl.Instance.rockAndRoll();
			PoolMgr.reclaim(this);
		}
	}

}