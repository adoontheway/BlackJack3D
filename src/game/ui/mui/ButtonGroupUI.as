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
			  <Image skin="png.ui.btn-clean" x="614" y="-180" stateNum="1" var="btn_clean"/>
			  <Image skin="png.ui.btn-double" x="198" y="-5" stateNum="1" var="btn_double"/>
			  <Image skin="png.ui.btn-hit" x="0" y="50" stateNum="1" var="btn_hit"/>
			  <Image skin="png.ui.btn-stand" x="99" y="25" stateNum="1" var="btn_stand"/>
			  <Image skin="png.ui.btn-ok" x="396" y="-99" stateNum="1" var="btn_ok"/>
			  <Image skin="png.ui.btn-skip" x="506" y="-156" stateNum="1" var="btn_skip"/>
			  <Image skin="png.ui.btn-rebet" x="297" y="-46" stateNum="1" var="btn_rebet"/>
			</View>;
		public function ButtonGroupUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
		}
	}
}