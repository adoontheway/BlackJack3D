/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	public class MyBetUI extends View {
		public var lab:Label = null;
		public var btn_close:Button = null;
		protected static var uiXML:XML =
			<View width="106" height="41">
			  <Image skin="png.images.betMoney" x="0" y="0"/>
			  <Label text="100.00" x="6" y="5" width="87" height="29" color="0xffffff" size="20" var="lab" align="center" font="Din" bold="false"/>
			  <Button skin="png.images.btn_close" x="87" y="-3" stateNum="1" var="btn_close"/>
			</View>;
		public function MyBetUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
		}
	}
}