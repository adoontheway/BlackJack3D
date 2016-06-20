/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	public class PokerUI extends View {
		public var lab_0:Label = null;
		public var lab_1:Label = null;
		public var img_0:Image = null;
		public var img_1:Image = null;
		protected static var uiXML:XML =
			<View width="93" height="133">
			  <Image skin="png.images.face_1"/>
			  <Image skin="png.images.face_0"/>
			  <Label text="A" x="2" y="4" width="20" height="19" size="15" var="lab_0" align="center"/>
			  <Label text="A" x="70" y="128" rotationX="180" size="15" var="lab_1" width="19" height="18" align="center"/>
			  <Image skin="png.images.type_1" x="3" y="26" width="16" height="16" var="img_0"/>
			  <Image skin="png.images.type_1" x="71" y="106" width="16" height="16" var="img_1" rotationX="180"/>
			</View>;
		public function PokerUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
		}
	}
}