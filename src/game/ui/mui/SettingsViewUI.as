/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	public class SettingsViewUI extends View {
		public var btn_voice_on:Button = null;
		public var btn_mucis_on:Button = null;
		public var btn_help:Button = null;
		public var img_add:Image = null;
		public var img_sub:Image = null;
		public var lab_voice:Label = null;
		public var lab_music:Label = null;
		public var lab_scale:Label = null;
		public var btn_music_off:Button = null;
		public var btn_voice_off:Button = null;
		public var btn_close:Button = null;
		protected static var uiXML:XML =
			<View width="437" height="143">
			  <Image skin="png.images.img-remind-bg"/>
			  <Image skin="png.images.img_btn_bg" x="52" y="34"/>
			  <Image skin="png.images.img_btn_bg" x="116" y="34"/>
			  <Image skin="png.images.img_btn_bg" x="184" y="34"/>
			  <Image skin="png.images.img_btn_bg" x="256" y="35" sizeGrid="20,20,3,3,1" width="137" height="45"/>
			  <Button skin="png.images.btn_voice" x="57" y="41" stateNum="2" var="btn_voice_on"/>
			  <Button skin="png.images.btn_music_on" x="122" y="41" stateNum="2" var="btn_mucis_on"/>
			  <Button skin="png.images.btn_help" x="190" y="41" stateNum="2" var="btn_help"/>
			  <Image skin="png.images.img_add" x="265" y="51" var="img_add"/>
			  <Image skin="png.images.img_sub" x="367" y="51" var="img_sub"/>
			  <Label text="音效开" x="46" y="87" color="0xffffff" var="lab_voice" font="Microsoft Yahei" size="16"/>
			  <Label text="音乐开" x="111" y="87" color="0xffffff" var="lab_music" font="Microsoft Yahei" size="16"/>
			  <Label text="帮助" x="189" y="87" color="0xffffff" font="Microsoft Yahei" size="16"/>
			  <Label text="界面缩放" x="289" y="87" color="0xffffff" font="Microsoft Yahei" size="16"/>
			  <Label x="288" y="49" color="0xffffff" font="Arial" size="16" var="lab_scale" width="73" height="21" align="center"/>
			  <Button skin="png.images.btn_music_off" x="118" y="37" stateNum="2" var="btn_music_off"/>
			  <Button skin="png.images.btn_voice_off" x="53" y="37" var="btn_voice_off" stateNum="2"/>
			  <Button skin="png.images.btn_close_1" x="406" y="13" stateNum="2" var="btn_close"/>
			</View>;
		public function SettingsViewUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
		}
	}
}