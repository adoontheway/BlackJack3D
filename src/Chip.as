package 
{
	import com.greensock.TweenLite;
	import comman.duke.GameVars;
	import comman.duke.PoolMgr;
	import consts.PokerGameVars;
	import flash.geom.Point;
	import morn.core.components.Box;
	import morn.core.components.Image;
	
	/**
	 * ...
	 * @author jerry.d
	 */
	public class Chip extends Box 
	{
		private var _value:uint;
		private var chip:Image;
		private var shadow:Image;
		public function Chip() 
		{
			this.chip = new Image();
			this.shadow = new Image();
			this.shadow.url = "png.chips.chip-shadow";
			this.addChild(this.shadow);
			this.addChild(this.chip);
			this.mouseChildren = false;
		}
		public function set value(val:uint):void{
			if ( this._value == val) return;
			this._value = val;
			this.chip.url = 'png.chips.chip-' + val;
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
			PoolMgr.reclaim(this);
		}
	}

}