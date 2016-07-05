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
		public var point_display:Box = null;
		public var img_points_bg:Image = null;
		public var lab_points:Label = null;
		public var insure_con:Box = null;
		protected static var uiXML:XML =
			<View width="260" height="200">
			  <Box skin="png.comp.blank" x="43" y="-1" var="poker_con"/>
			  <Box skin="png.comp.blank" x="114" y="96" var="chips_con"/>
			  <Image skin="png.ui.btn-split" x="25" y="20" stateNum="1" var="btn_split"/>
			  <Image skin="png.ui.btn-insurrance" x="25" y="20" stateNum="1" var="btn_insurrance"/>
			  <Image skin="png.images.blackjack" x="-5" y="42" var="mark_blackjack"/>
			  <MyBet x="134" y="132" var="bet_display" runtime="game.ui.mui.MyBetUI"/>
			  <Box x="134" y="-27" var="point_display">
			    <Image skin="png.images.bust" var="img_points_bg"/>
			    <Label x="5" y="12" var="lab_points" color="0xffffff" text="21" size="30" width="56" height="39" align="center"/>
			  </Box>
			  <Box skin="png.comp.blank" x="109" y="65" var="insure_con"/>
			</View>;
		public function SubTableUI(){}
		override protected function createChildren():void {
			viewClassMap["game.ui.mui.MyBetUI"] = MyBetUI;
			super.createChildren();
			createView(uiXML);
		}
	}
}