/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	public class ChipsViewUI extends View {
		public var chips_con:Box = null;
		public var img_cover:Image = null;
		protected static var uiXML:XML =
			<View width="468" height="69">
			  <Box skin="png.comp.blank" var="chips_con"/>
			  <Image skin="png.images.chips_cover" x="-15" y="-9" var="img_cover"/>
			</View>;
		public function ChipsViewUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
		}
	}
}