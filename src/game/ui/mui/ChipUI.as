/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	public class ChipUI extends View {
		public var img_0:Image = null;
		public var lab_0:Label = null;
		protected static var uiXML:XML =
			<View width="60" height="60">
			  <Image skin="png.images.chip_side_0" width="60" height="60" var="img_0" x="30" y="30" anchorX="0.5" anchorY="0.5" rotation="0"/>
			  <Label text="100" x="3" y="19" width="53" height="18" align="center" size="15" var="lab_0"/>
			</View>;
		public function ChipUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
		}
	}
}