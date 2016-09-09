/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	import game.ui.mui.MyBetUI;
	public class TableRightUI extends View {
		public var table:Button = null;
		public var pair:Button = null;
		public var pair_con:Box = null;
		public var pair_bet_display:MyBetUI = null;
		protected static var uiXML:XML =
			<View width="345" height="215">
			  <Button skin="png.images.btn_table_right" stateNum="2" var="table"/>
			  <Button skin="png.images.btn_pair_right" x="197" stateNum="2" y="11" var="pair"/>
			  <Box skin="png.comp.blank" x="228" y="14" var="pair_con" width="81" height="33"/>
			  <MyBet x="293" y="2" var="pair_bet_display" runtime="game.ui.mui.MyBetUI"/>
			</View>;
		public function TableRightUI(){}
		override protected function createChildren():void {
			viewClassMap["game.ui.mui.MyBetUI"] = MyBetUI;
			super.createChildren();
			createView(uiXML);
		}
	}
}