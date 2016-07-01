/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	import game.ui.mui.BalanceUI;
	import game.ui.mui.ButtonGroupUI;
	import game.ui.mui.ChipsViewUI;
	public class MainViewUI extends View {
		public var chips_group:ChipsViewUI = null;
		public var balance:BalanceUI = null;
		public var banker_poker_con:Box = null;
		protected static var uiXML:XML =
			<View width="800" height="600">
			  <Image skin="png.bg.desk" x="-644" y="-1"/>
			  <Image skin="png.images.chip-box" x="259" y="-11"/>
			  <Image skin="png.images.recycle-bin" x="-130" y="-64"/>
			  <Image skin="png.images.dispenser" x="612" y="-63"/>
			  <ChipsView x="156" y="625" var="chips_group" runtime="game.ui.mui.ChipsViewUI"/>
			  <Balance x="831" y="38" var="balance" runtime="game.ui.mui.BalanceUI"/>
			  <Box skin="png.comp.blank" x="293" y="125" var="banker_poker_con" width="81" height="33"/>
			  <ButtonGroup x="650" y="515" runtime="game.ui.mui.ButtonGroupUI"/>
			</View>;
		public function MainViewUI(){}
		override protected function createChildren():void {
			viewClassMap["game.ui.mui.BalanceUI"] = BalanceUI;
			viewClassMap["game.ui.mui.ButtonGroupUI"] = ButtonGroupUI;
			viewClassMap["game.ui.mui.ChipsViewUI"] = ChipsViewUI;
			super.createChildren();
			createView(uiXML);
		}
	}
}