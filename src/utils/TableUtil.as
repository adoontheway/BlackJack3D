package utils 
{
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	import comman.duke.PoolMgr;
	import consts.PokerGameVars;
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
				var startA:int = 270 - 8 * num;
				var radius:Number = 0; 
				var poker:Poker;
				var index:int = 0;
				var angel:Number = 10;
				while ( index < num){
					startA += angel; 
					radius = startA * GameVars.RADIUS_PER_DEGREE;
					poker = con.getChildAt(index) as Poker;
					poker.targetX = px + r * Math.cos(radius);
					poker.targetY = py + r * Math.sin(radius);
					TweenLite.to(poker, 0.3, {x:poker.targetX, y:poker.targetY, rotation:startA - 270});
					index++;
					r += 5;
					angel -= 1;
				}
			}
		}
		
		public static function displayChipsToContainer(bet:int, con:DisplayObjectContainer):void{
			cleanContainer(con);
			var len:int = PokerGameVars.ALL_CHIP_VALUE.length - 1;
			var value:int;
			var chip:Chip;
			var cnt:int;
			while (len >= 0 && bet > 0){
				value = PokerGameVars.ALL_CHIP_VALUE[len];
				
				if ( bet >= value ){
					cnt = bet / value;
					while (cnt > 0 ){
						bet -= value;
						chip = PoolMgr.gain(Chip);
						chip.value = value;
						chip.scale = 0.2;
						con.addChild(chip);
						chip.y = con.numChildren *-5;
						chip.x = 0;
						chip.mouseChildren = chip.mouseEnabled = false;
						TweenLite.to(chip, 0.2, {scale:1, ease: Back.easeOut}); 
						cnt--;
					}
				}
				
				len--;
			}
			
		}
		
		public static function cleanContainer(con:DisplayObjectContainer):void{
			while (con.numChildren != 0 ){
				PoolMgr.reclaim(con.removeChildAt(0));
			}
		}
	}

}