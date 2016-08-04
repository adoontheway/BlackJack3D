package uiimpl 
{
	import game.ui.mui.BJButtonUI;
	
	/**
	 * ...
	 * @author jerry.d
	 */
	public class BJButton extends BJButtonUI 
	{
		private var _enable:Boolean = true;
		public function BJButton() 
		{
			super();
			this.mouseChildren = false;
		}
		
		public function setup(name:String, bType:int):void{
			if ( this.name == name ) return;
			this.icon.url = "png.images.icon-" + name;
			this.name = name;
			this.bgType = bType;
		}
		
		private var _bgType:int = 0;
		public function set bgType(val:int):void{
			this._bgType = val;
			if ( _enable ){
				this.img_bg.url = 'png.images.img-'+this._bgType+'-1';
			}else{
				this.img_bg.url = 'png.images.img-'+this._bgType+'-0';
			}
		}
		public function get bgType():int{
			return _bgType;
		}
		
		public function get enable():Boolean{
			return _enable;
		}
		
		public function set enable(val:Boolean):void{
			this._enable = val;
			this.mouseEnabled = val;
			if ( val ){
				this.img_bg.url = 'png.images.img-'+this._bgType+'-1';
			}else{
				this.img_bg.url = 'png.images.img-'+this._bgType+'-0';
			}
		}
		
	}

}