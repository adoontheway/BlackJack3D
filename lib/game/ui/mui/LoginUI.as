/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	public class LoginUI extends View {
		public var btn_login:Button = null;
		public var name_input:TextInput = null;
		public var pass_input:TextInput = null;
		protected static var uiXML:XML =
			<View width="295" height="200">
			  <Image skin="png.comp.bg" width="295" height="200" x="1" y="0"/>
			  <Label text="LOGIN" x="108" y="18" size="20"/>
			  <Label text="USERNAME" x="33" y="84"/>
			  <Label text="PASSWORD" x="33" y="121"/>
			  <Button label="LOGIN" skin="png.comp.button" x="104" y="155" var="btn_login"/>
			  <TextInput skin="png.comp.textinput" x="112" y="80" var="name_input"/>
			  <TextInput skin="png.comp.textinput" x="114" y="121" var="pass_input" asPassword="true"/>
			</View>;
		public function LoginUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
		}
	}
}