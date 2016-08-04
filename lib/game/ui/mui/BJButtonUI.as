/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	public class BJButtonUI extends View {
		public var img_bg:Image = null;
		public var icon:Image = null;
		protected static var uiXML:XML =
			<View width="99" height="99">
			  <Image skin="png.images.img-0-1" var="img_bg"/>
			  <Image skin="png.images.icon-clean" var="icon"/>
			</View>;
		public function BJButtonUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
		}
	}
}