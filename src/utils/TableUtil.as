package utils 
{
	import com.greensock.TweenLite;
	import comman.duke.PoolMgr;
	import flash.display.DisplayObjectContainer;
	import comman.duke.GameVars;
	/**
	 * ...
	 * @author jerry.d
	 */
	public class TableUtil 
	{
		public static function reOrderContainer(con:DisplayObjectContainer,px:int, py:int, r:int):void{
			var num:int = con.numChildren;
			if ( num != 0){
				var startA:int = 270 - 10 * num;
				var radius:Number = 0; 
				var poker:Poker;
				var index:int = 0;
				var angel:int = 10;
				while ( index < num){
					startA += angel; 
					radius = startA * GameVars.RADIUS_PER_DEGREE;
					poker = con.getChildAt(index) as Poker;
					poker.targetX = px + r * Math.cos(radius);
					poker.targetY = py + r * Math.sin(radius);
					TweenLite.to(poker, 0.3, {x:poker.targetX, y:poker.targetY, rotation:startA - 270});
					index++;
					r += 5;
					angel--;
				}
			}
		}
		
	}

}