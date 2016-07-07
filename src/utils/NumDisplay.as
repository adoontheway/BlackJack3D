package utils 
{
	import com.greensock.TweenLite;
	import comman.duke.GameVars;
	import comman.duke.PoolMgr;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import morn.core.components.Image;
	/**
	 * ...
	 * @author jerry.d
	 */
	public class NumDisplay 
	{
		public static function show(num:int,x:int, y:int):void{
			var str:String = num.toString();
			var con:Sprite = PoolMgr.gain(Sprite);
			
			var prefix:String;
			var posX:int = 0;
			var image:Image;
			var index:int = 1;
			if ( num > 0){
				str = "+" + str;
				prefix = "p";
				image = PoolMgr.gain(Image); 
				image.url = "png.nums.pos";
				image.x = 0;
				con.addChild(image);
				posX += image.width;
			}else{
				prefix = "n";
				/**
				image = PoolMgr.gain(Image); 
				image.url = "png.nums.neg";
				con.addChild(image);
				image.x = 0;
				posX += image.width;
				*/
			}
			var char:String;
			while ( index < str.length){
				char = prefix+str.charAt(index);
				image = PoolMgr.gain(Image); 
				image.url = "png.nums."+char;
				image.x = posX;
				con.addChild(image);
				posX += image.width;
				index++;
			}
			con.x = x;
			con.y = y;
			con.scaleX = con.scaleY = 0.8;
			GameVars.STAGE.addChild(con);
			TweenLite.to(con, 2, {y:y - 100, alpha:0, scaleX:1.2, scaleY:1.2, onComplete:onTweenComplete, onCompleteParams:[con]});
		}
		
		private static function onTweenComplete(con:Sprite):void{
			var image:Image;
			while (con.numChildren != 0){
				image = con.removeChildAt(0) as Image;
				PoolMgr.reclaim(image);
			}
			GameVars.STAGE.removeChild(con);
			con.scaleX = con.scaleY = con.alpha = 1;
			PoolMgr.reclaim(con);
		}
	}

}