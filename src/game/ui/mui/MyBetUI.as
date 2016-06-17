/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	public class MyBetUI extends View {
		protected static var uiXML:XML =
			<View width="183" height="68">
			  <Image skin="png.images.betMoney" x="0" y="0" width="183" height="68"/>
			  <Label text="100" x="36" y="25" width="143" height="29" color="0xffffff" size="20"/>
			</View>;
		public function MyBetUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
		}
	}
}