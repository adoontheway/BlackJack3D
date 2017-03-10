package utils 
{
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	import comman.duke.PoolMgr;
	import consts.PokerGameVars;
	import flash.display.DisplayObjectContainer;
	import comman.duke.GameVars;
	import flash.display.Sprite;
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
					//angel -= 1;
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
		
		public static function getChipStack(bet:Number):Sprite{
			var con:Sprite = PoolMgr.gain(Sprite);
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
						con.addChild(chip);
						chip.y = con.numChildren *-5;
						chip.x = 0;
						chip.mouseChildren = chip.mouseEnabled = false;
						cnt--;
					}
				}
				
				len--;
			}
			return con;
		}
		
		public static function cleanContainer(con:DisplayObjectContainer):void{
			while (con.numChildren != 0 ){
				PoolMgr.reclaim(con.removeChildAt(0));
			}
		}
		
		public static function shuffle(pokers:Array, times:int=15, scope:int=5):void{
			var index0;
			var index1;
			var len:int = pokers.length;
			var i:int = 0;
			var temp:*;
			var r0:*;
			var r1:*;
			while (times > 0){
				index0 = Math.floor(Math.random() * len);
				index1 = Math.floor(Math.random() * len);

				while (index0 == index1 ){
					index1 = Math.floor(Math.random() * len);
				}
				for (i = 0; i < scope; i++){
					r0 = index0 % len;
					r1 = index1 % len;
					temp = pokers[r0];
					pokers[r0] = pokers[r1];
					pokers[r1] = temp;
					index0++;
					index1++;
				}
				times--;
			}
		}
	}

}