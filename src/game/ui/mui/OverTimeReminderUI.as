/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	public class OverTimeReminderUI extends View {
		public var btn_return:Button = null;
		public var timer:Label = null;
		protected static var uiXML:XML =
			<View width="437" height="143">
			  <Image skin="png.images.img-remind-bg"/>
			  <Button skin="png.images.btn_back" x="172" y="90" stateNum="2" var="btn_return" name="btn_return"/>
			  <Label text="HI~你还在不在啊？快回来" x="29" y="22" width="382" height="34" multiline="true" wordWrap="true" align="center" autoSize="center" color="0xffffff" size="20" font="Microsoft Yahei"/>
			  <Label text="游戏将在            秒后自动进行" x="43" y="52" width="360" height="37" multiline="true" wordWrap="true" align="center" autoSize="center" color="0xffffff" size="16" font="Microsoft Yahei"/>
			  <Label x="178" y="53" width="57" height="36" color="0xf0d860" font="Arial" size="20" align="center" var="timer"/>
			</View>;
		public function OverTimeReminderUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
		}
	}
}