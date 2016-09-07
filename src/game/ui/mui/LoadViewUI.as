/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	public class LoadViewUI extends View {
		public var loading_bar:Image = null;
		protected static var uiXML:XML =
			<View width="193" height="410">
			  <Image skin="png.loading.loading-bar-1" x="22" y="198" var="loading_bar" sizeGrid="4,3,1,2,1" width="61" height="8"/>
			  <Image skin="png.loading.img-logo" x="40.5" y="283"/>
			  <Image skin="png.loading.loading-icon"/>
			</View>;
		public function LoadViewUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
		}
	}
}