package uiimpl 
{
	import comman.duke.GameVars;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import game.ui.mui.HelpViewUI;
	
	/**
	 * ...
	 * @author jerry.d
	 */
	public class HelpView extends HelpViewUI 
	{
		private var contentRect:Rectangle;
		public function HelpView() 
		{
			super();
			y = 30;
			this.scroller.target = this.img_content;
			this.img_content.scrollRect = contentRect = new Rectangle(0, 0, 615, 740);
			this.scroller.setScroll(0, 724, 10);
			this.scroller.addEventListener('change', onScrollerChange);
			this.img_close.addEventListener(MouseEvent.CLICK, hide);
		}
		
		private function onScrollerChange(e:Event):void{
			contentRect.y = this.scroller.value;
			this.img_content.scrollRect = contentRect;
		}
		
		public function show():void{
			if (!GameVars.STAGE.contains(this)){
				GameVars.STAGE.addChild(this);
				this.x = GameVars.Stage_Width - this.width >> 1;
			} 
		}
		
		public function hide(e:MouseEvent):void{
			if ( this.parent != null ){
				this.parent.removeChild(this);
			}
		}
		
		private static var _instance:HelpView;
		public static function get Instance():HelpView{
			if ( HelpView._instance == null){
				HelpView._instance = new HelpView();
			}
			return HelpView._instance;
		}
		
	}

}