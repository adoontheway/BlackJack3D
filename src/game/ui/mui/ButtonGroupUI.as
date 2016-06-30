/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	public class ButtonGroupUI extends View {
		public var btn_clean:Image = null;
		public var btn_double:Image = null;
		public var btn_hit:Image = null;
		public var btn_stand:Image = null;
		public var btn_ok:Image = null;
		public var btn_skip:Image = null;
		public var btn_rebet:Image = null;
		protected static var uiXML:XML =
			<View width="480" height="119">
			  <Image skin="png.ui.btn-clean" x="627" y="-267" stateNum="1" var="btn_clean"/>
			  <Image skin="png.ui.btn-double" x="213" y="-7" stateNum="1" var="btn_double"/>
			  <Image skin="png.ui.btn-hit" x="0" y="47" stateNum="1" var="btn_hit"/>
			  <Image skin="png.ui.btn-stand" x="107" y="25" stateNum="1" var="btn_stand"/>
			  <Image skin="png.ui.btn-ok" x="419" y="-123" stateNum="1" var="btn_ok"/>
			  <Image skin="png.ui.btn-skip" x="517" y="-194" stateNum="1" var="btn_skip"/>
			  <Image skin="png.ui.btn-rebet" x="320" y="-54" stateNum="1" var="btn_rebet"/>
			</View>;
		public function ButtonGroupUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
		}
	}
}