/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	public class MyBetUI extends View {
		public var bet_bg:Image = null;
		public var lab:Label = null;
		public var btn_close:Button = null;
		protected static var uiXML:XML =
			<View width="106" height="41">
			  <Image skin="png.images.betMoney" x="0" y="0" var="bet_bg"/>
			  <Label x="10" y="4" width="39" height="29" color="0xffffff" size="20" var="lab" align="left" font="Din" bold="false" autoSize="left"/>
			  <Button skin="png.images.btn_close" x="41" y="-7" stateNum="1" var="btn_close"/>
			</View>;
		public function MyBetUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
		}
	}
}