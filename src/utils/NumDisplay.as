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
				con.addChild(image);
				posX += image.width;
			}else{
				prefix = "n";
				image = PoolMgr.gain(Image); 
				image.url = "png.nums.neg";
				con.addChild(image);
				posX += image.width;
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
			GameVars.STAGE.addChild(con);
			TweenLite.to(con, 2, {y:y - 100, alpha:0, onComplete:onTweenComplete, onCompleteParams:[con]});
		}
		
		private static function onTweenComplete(con:Sprite):void{
			var image:Image;
			while (con.numChildren != 0){
				image = con.removeChildAt(0) as Image;
				PoolMgr.reclaim(image);
			}
			GameVars.STAGE.removeChild(con);
			con.alpha = 1;
			PoolMgr.reclaim(con);
		}
		
		/**
		private static var displayList:Array = [];
		private static var conPool:Array = [];
		private static function gain():DisplayObjectContainer{
			if ( conPool.length != 0 ){
				return conPool.pop();
			}
			return new Sr();
		}
		
		private static function reclaim(con:DisplayObjectContainer):void{
			if ( conPool.indexOf(con) == -1){
				conPool.push(con);
			}
		}
		*/
	}

}