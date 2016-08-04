/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	import game.ui.mui.MyBetUI;
	public class PokerContainerUI extends View {
		public var poker_con:Box = null;
		public var point_bg:Image = null;
		public var ponit_lab:Label = null;
		public var chips_con:Box = null;
		public var btn_split:Image = null;
		public var btn_insurrance:Image = null;
		public var mark_blackjack:Image = null;
		public var bet_display:MyBetUI = null;
		protected static var uiXML:XML =
			<View width="600" height="400">
			  <Box skin="png.comp.blank" x="64" y="-1" var="poker_con"/>
			  <Image skin="png.images.bust" x="123" y="0" var="point_bg"/>
			  <Label x="137" y="11" var="ponit_lab" color="0xffffff" text="21" size="30" width="38" height="39"/>
			  <Box skin="png.comp.blank" x="153" y="117" var="chips_con"/>
			  <Image skin="png.ui.btn-split" x="35" y="34" stateNum="1" var="btn_split"/>
			  <Image skin="png.ui.btn-insurrance" x="34" y="35" stateNum="1" var="btn_insurrance"/>
			  <Image skin="png.images.blackjack" x="-9" y="63" var="mark_blackjack"/>
			  <MyBet x="153" y="154" var="bet_display" runtime="game.ui.mui.MyBetUI"/>
			</View>;
		public function PokerContainerUI(){}
		override protected function createChildren():void {
			viewClassMap["game.ui.mui.MyBetUI"] = MyBetUI;
			super.createChildren();
			createView(uiXML);
		}
	}
}