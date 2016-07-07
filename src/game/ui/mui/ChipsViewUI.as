/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	public class ChipsViewUI extends View {
		public var shadow_0:Image = null;
		public var shadow_1:Image = null;
		public var shadow_2:Image = null;
		public var shadow_3:Image = null;
		public var shadow_4:Image = null;
		public var shadow_5:Image = null;
		public var chips_con:Box = null;
		public var img_cover:Image = null;
		public var img_mask:Image = null;
		protected static var uiXML:XML =
			<View width="468" height="69">
			  <Image skin="png.chips.chip-shadow" x="-1" y="0" var="shadow_0" name="shadow_0" alpha="0.7"/>
			  <Image skin="png.chips.chip-shadow" x="75" y="4" var="shadow_1" name="shadow_1" alpha="0.7"/>
			  <Image skin="png.chips.chip-shadow" x="151" y="6" var="shadow_2" name="shadow_2" alpha="0.7"/>
			  <Image skin="png.chips.chip-shadow" x="227" y="6" var="shadow_3" name="shadow_3" alpha="0.7"/>
			  <Image skin="png.chips.chip-shadow" x="303" y="4" var="shadow_4" name="shadow_4" alpha="0.7"/>
			  <Image skin="png.chips.chip-shadow" x="379" y="0" var="shadow_5" name="shadow_5" alpha="0.7"/>
			  <Box skin="png.comp.blank" var="chips_con" x="6"/>
			  <Image skin="png.images.chips_cover" x="-15" y="-2" var="img_cover"/>
			  <Image skin="png.images.chips_cover" x="-15" y="-2" var="img_mask"/>
			</View>;
		public function ChipsViewUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
		}
	}
}