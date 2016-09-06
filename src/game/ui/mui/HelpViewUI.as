/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	public class HelpViewUI extends View {
		public var img_content:Image = null;
		public var scroller:VScrollBar = null;
		public var img_close:Button = null;
		protected static var uiXML:XML =
			<View width="673" height="777">
			  <Image skin="png.images.img_help_bg"/>
			  <Image skin="png.images.img_help_txt" x="17" y="14" var="img_content"/>
			  <VScrollBar skin="png.comp.vscroll" x="637" y="56" width="17" height="698" var="scroller"/>
			  <Button skin="png.images.btn_close_1" x="636" y="20" stateNum="2" var="img_close"/>
			</View>;
		public function HelpViewUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
		}
	}
}