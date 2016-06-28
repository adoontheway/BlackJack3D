/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	import game.ui.mui.MyBetUI;
	public class TableRightUI extends View {
		public var table:Button = null;
		public var pair:Button = null;
		public var poker_con_1:Box = null;
		public var poker_con_2:Box = null;
		public var bet_display:MyBetUI = null;
		public var point_display:Box = null;
		public var img_points_bg:Image = null;
		public var lab_points:Label = null;
		public var mark_blackjack:Image = null;
		public var btn_insurrance:Button = null;
		public var btn_split:Button = null;
		public var chips_con:Box = null;
		public var pair_con:Box = null;
		protected static var uiXML:XML =
			<View width="345" height="215">
			  <Button skin="png.ui.btn_table_right" stateNum="2" var="table"/>
			  <Button skin="png.ui.btn_pair_right" x="197" stateNum="2" y="11" var="pair"/>
			  <Box skin="png.comp.blank" x="84" y="7" var="poker_con_1"/>
			  <Box skin="png.comp.blank" x="84" y="-53" var="poker_con_2"/>
			  <MyBet x="207" y="160" var="bet_display" runtime="game.ui.mui.MyBetUI"/>
			  <Box x="197" y="-40" var="point_display">
			    <Image skin="png.images.bust" var="img_points_bg"/>
			    <Label text="21" x="10" y="13" color="0xffffff" width="48" height="37" align="center" size="30" var="lab_points"/>
			  </Box>
			  <Image skin="png.images.blackjack" x="24" y="78" var="mark_blackjack"/>
			  <Button skin="png.ui.btn_insurrance" x="44" y="44" stateNum="2" var="btn_insurrance"/>
			  <Button skin="png.ui.btn_split" x="46" y="44" stateNum="2" var="btn_split"/>
			  <Box skin="png.comp.blank" x="150" y="115" var="chips_con"/>
			  <Box skin="png.comp.blank" x="220" y="29" var="pair_con" width="81" height="33"/>
			</View>;
		public function TableRightUI(){}
		override protected function createChildren():void {
			viewClassMap["game.ui.mui.MyBetUI"] = MyBetUI;
			super.createChildren();
			createView(uiXML);
		}
	}
}