/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	public class OperationViewUI extends View {
		public var btn_clear:Button = null;
		public var btn_double:Button = null;
		public var btn_submit:Button = null;
		public var lab_bet:Label = null;
		public var label_balance:Label = null;
		protected static var uiXML:XML =
			<View width="1000" height="100">
			  <Image skin="png.ui.balance" x="855" y="1"/>
			  <Image skin="png.ui.betMoney" x="-133" y="15"/>
			  <Button skin="png.ui.btn_clear" x="167" y="4" stateNum="1" var="btn_clear" buttonMode="true"/>
			  <Button skin="png.ui.btn_double" x="635" y="-3" var="btn_double" buttonMode="true"/>
			  <Button skin="png.ui.btn_submit" x="395" y="-4" var="btn_submit" buttonMode="true"/>
			  <Label text="0" x="-77" y="51" color="0x996600" size="24" var="lab_bet" width="225" height="37"/>
			  <Label text="label" x="945" y="40" var="label_balance" width="208" height="30" color="0x996600" size="24"/>
			</View>;
		public function OperationViewUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
		}
	}
}