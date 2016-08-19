/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	public class LoadViewUI extends View {
		public var loading_bar:Image = null;
		protected static var uiXML:XML =
			<View width="193" height="410">
			  <Image skin="png.loading.loading-icon" x="-0.5"/>
			  <Image skin="png.loading.loading-bar" x="22" y="199" var="loading_bar"/>
			  <Image skin="png.loading.img-logo" x="40.5" y="283"/>
			</View>;
		public function LoadViewUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
		}
	}
}