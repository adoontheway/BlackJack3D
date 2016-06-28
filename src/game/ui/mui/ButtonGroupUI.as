/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	public class ButtonGroupUI extends View {
		public var btn_rebet:Button = null;
		public var btn_double:Button = null;
		public var btn_hit:Button = null;
		public var btn_stand:Button = null;
		protected static var uiXML:XML =
			<View width="480" height="119">
			  <Button skin="png.ui.btn_clean" x="320" y="-54" stateNum="2" var="btn_rebet"/>
			  <Button skin="png.ui.btn_double" x="213" y="-7" stateNum="2" var="btn_double"/>
			  <Button skin="png.ui.btn_hit" x="0" y="47" stateNum="2" var="btn_hit"/>
			  <Button skin="png.ui.btn_stand" x="107" y="25" stateNum="2" var="btn_stand"/>
			</View>;
		public function ButtonGroupUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
		}
	}
}