/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	import game.ui.mui.MyBetUI;
	public class SubTableUI extends View {
		public var poker_con:Box = null;
		public var chips_con:Box = null;
		public var btn_split:Image = null;
		public var btn_insurrance:Image = null;
		public var mark_blackjack:Image = null;
		public var bet_display:MyBetUI = null;
		public var insure_con:Box = null;
		public var img_result_0:Image = null;
		public var img_result_1:Image = null;
		public var point_display:Box = null;
		public var img_points_bg:Image = null;
		public var lab_points:Label = null;
		protected static var uiXML:XML =
			<View width="260" height="200">
			  <Box skin="png.comp.blank" x="43" y="-1" var="poker_con"/>
			  <Box skin="png.comp.blank" x="114" y="96" var="chips_con"/>
			  <Image skin="png.images.btn-split" x="25" y="20" stateNum="1" var="btn_split"/>
			  <Image skin="png.images.btn-insurrance" x="25" y="20" stateNum="1" var="btn_insurrance"/>
			  <Image skin="png.images.blackjack" x="-5" y="50" var="mark_blackjack"/>
			  <MyBet x="179" y="84" var="bet_display" runtime="game.ui.mui.MyBetUI"/>
			  <Box skin="png.comp.blank" x="79" y="116" var="insure_con"/>
			  <Image skin="png.images.result_lose" x="165" y="-5" var="img_result_0"/>
			  <Image skin="png.images.result_lose" x="60" y="-5" var="img_result_1"/>
			  <Box x="144" y="-17" var="point_display">
			    <Image skin="png.images.bust" var="img_points_bg"/>
			    <Label x="6" y="8" var="lab_points" color="0xffffff" text="21" size="30" width="56" height="38" align="center" font="Din" multiline="true"/>
			  </Box>
			</View>;
		public function SubTableUI(){}
		override protected function createChildren():void {
			viewClassMap["game.ui.mui.MyBetUI"] = MyBetUI;
			super.createChildren();
			createView(uiXML);
		}
	}
}