/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	public class BalanceUI extends View {
		public var lab_0:Label = null;
		public var btn_recharge:Button = null;
		protected static var uiXML:XML =
			<View width="212" height="46">
			  <Image skin="png.images.balance" x="0" y="0"/>
			  <Label text="100" x="40" y="8" width="108" height="27" color="0xcccccc" size="20" var="lab_0" font="Din"/>
			  <Button skin="png.images.btn_recharge" x="149" y="7" stateNum="1" var="btn_recharge"/>
			</View>;
		public function BalanceUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
		}
	}
}