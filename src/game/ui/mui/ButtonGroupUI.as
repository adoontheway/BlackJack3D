/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	public class ButtonGroupUI extends View {
		protected static var uiXML:XML =
			<View width="480" height="119"/>;
		public function ButtonGroupUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
		}
	}
}