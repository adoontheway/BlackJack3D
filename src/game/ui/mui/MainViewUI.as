/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	import game.ui.mui.BalanceUI;
	import game.ui.mui.MyBetUI;
	public class MainViewUI extends View {
		public var balance:BalanceUI = null;
		public var bet:MyBetUI = null;
		public var gameIntro:Image = null;
		public var lab_time:Label = null;
		public var btn_0:Button = null;
		public var btn_1:Button = null;
		public var btn_2:Button = null;
		public var btn_3:Button = null;
		public var btn_4:Button = null;
		protected static var uiXML:XML =
			<View width="751" height="505">
			  <Image skin="png.bg.398"/>
			  <Balance y="355" var="balance" x="536" runtime="game.ui.mui.BalanceUI"/>
			  <MyBet y="355" var="bet" runtime="game.ui.mui.MyBetUI"/>
			  <Image skin="png.images.game_intro" var="gameIntro"/>
			  <Label text="time:" x="112" y="17" color="0x6600" size="15" width="118" height="18" var="lab_time"/>
			  <Button label="STAND" skin="png.comp.button" x="31" y="181" var="btn_0" visible="false"/>
			  <Button label="HIT" skin="png.comp.button" x="32" y="212" var="btn_1" visible="false"/>
			  <Button label="START" skin="png.comp.button" x="32" y="243" var="btn_2" visible="false"/>
			  <Button label="BET" skin="png.comp.button" x="32" y="274" var="btn_3" visible="false"/>
			  <Button label="SURRENDER" skin="png.comp.button" x="32" y="303" var="btn_4" visible="false"/>
			</View>;
		public function MainViewUI(){}
		override protected function createChildren():void {
			viewClassMap["game.ui.mui.BalanceUI"] = BalanceUI;
			viewClassMap["game.ui.mui.MyBetUI"] = MyBetUI;
			super.createChildren();
			createView(uiXML);
		}
	}
}