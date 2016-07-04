/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	public class TableRightUI extends View {
		public var table:Button = null;
		public var pair:Button = null;
		public var pair_con:Box = null;
		protected static var uiXML:XML =
			<View width="345" height="215">
			  <Button skin="png.ui.btn_table_right" stateNum="2" var="table"/>
			  <Button skin="png.ui.btn_pair_right" x="197" stateNum="2" y="11" var="pair"/>
			  <Box skin="png.comp.blank" x="228" y="14" var="pair_con" width="81" height="33"/>
			</View>;
		public function TableRightUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
		}
	}
}