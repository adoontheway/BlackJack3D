/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	public class BalanceUI extends View {
		public var lab_0:Label = null;
		protected static var uiXML:XML =
			<View width="215" height="68">
			  <Image skin="png.images.balance" x="0" y="0" width="214" height="66"/>
			  <Label text="100" x="57" y="24" width="148" height="27" color="0xcccccc" size="18" var="lab_0"/>
			</View>;
		public function BalanceUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
		}
	}
}