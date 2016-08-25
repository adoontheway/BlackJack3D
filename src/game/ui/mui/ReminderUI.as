/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	public class ReminderUI extends View {
		public var content:Label = null;
		protected static var uiXML:XML =
			<View width="437" height="143">
			  <Image skin="png.images.img-remind-bg"/>
			  <Label text="" x="20" y="51" width="393" height="72" multiline="true" wordWrap="true" align="center" autoSize="center" color="0xffffff" size="20" font="Microsoft Yahei" var="content" name="content" selectable="false"/>
			</View>;
		public function ReminderUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
		}
	}
}