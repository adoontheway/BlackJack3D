/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	public class BalanceUI extends View {
		public var lab_0:Label = null;
		public var btn_recharge:Button = null;
		protected static var uiXML:XML =
			<View width="212" height="46">
			  <Image skin="png.images.balance" x="0" y="0"/>
			  <Label text="100" x="46" y="10" width="97" height="27" color="0xcccccc" size="18" var="lab_0"/>
			  <Button skin="png.images.btn_recharge" x="149" y="7" stateNum="1" var="btn_recharge"/>
			</View>;
		public function BalanceUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
		}
	}
}