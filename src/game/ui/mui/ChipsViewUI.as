/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	public class ChipsViewUI extends View {
		protected static var uiXML:XML =
			<View width="468" height="69"/>;
		public function ChipsViewUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
		}
	}
}