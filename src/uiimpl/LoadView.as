package uiimpl 
{
	import comman.duke.GameUtils;
	import comman.duke.GameVars;
	import game.ui.mui.LoadViewUI;
	
	/**
	 * ...
	 * @author jerry.d
	 */
	public class LoadView extends LoadViewUI 
	{
		private static const MAX_LENGTH:int = 150;
		public function LoadView() 
		{
			super();
			//this.loading_bar.sizeGrid = '4,2,6,4,1';
		}
		
		/** pro:0-1 */
		public function showProgress(pro:Number):void{
			if ( pro < 0 || pro > 1){
				GameUtils.fatal("异常加载进度:", pro);
				return;
			}
			loading_bar.width = MAX_LENGTH * pro;
		}
		
		public function show():void{
			GameVars.STAGE.addChild(this);
			this.x = GameVars.Stage_Width - this.width >> 1;
			this.y = GameVars.Stage_Height - this.height >> 1;
		}
		
		public function hide():void{
			if ( this.parent != null ){
				this.parent.removeChild(this);
			}
		}
		
		private static var _instance:LoadView;
		public static function get Instance():LoadView{
			if ( LoadView._instance == null){
				LoadView._instance = new LoadView();
			}
			return LoadView._instance;
		}
	}

}