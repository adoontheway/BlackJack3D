package 
{
	import com.greensock.TweenLite;
	import comman.duke.IRecyclable;
	import comman.duke.PoolMgr;
	import consts.PokerGameVars;
	import flash.geom.Point;
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
		private var _value:int = -2;
		public var type:uint;
		public var realValue:uint;
		public var compareValue:uint = 0;
		public function Poker(value:int=-1) 
		{
			super(url);
			if (value != -1){
				this.value = value;
			}
			this.smoothing = true;
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
				this.url = 'png.pokers.' + val;
				this.name = 'poker_' + val;
			}	
		}
		
		public function get value():int{
			return _value;
		}
		
		public function autoHide():void{
			if ( this.parent != null){
				var disapearPoint:Point = parent.globalToLocal(PokerGameVars.DisaprearPoint);
				TweenLite.to(this, 0.4, {rotation:0, x:disapearPoint.x, y:disapearPoint.y, onComplete:hideSelf});
			}
		}
		
		public function hideSelf():void{
			if ( this.parent ){
				this.parent.removeChild(this);
				PoolMgr.reclaim(this);
			}
		}
		
		override public function set rotationY(value:Number):void{
			super.rotationY  = value;
			if ( rotationY > 90 ){
				if ( this.url != 'png.pokers.back'){
					this.url = 'png.pokers.back';
				}
			}else{
				if ( this.url != 'png.pokers.' + _value){
					this.url = 'png.pokers.' + _value
				}
			}
		}
	}

}