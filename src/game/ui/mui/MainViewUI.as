/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	public class MainViewUI extends View {
		public var banker_poker_con:Box = null;
		public var point_display:Box = null;
		public var img_points_bg:Image = null;
		public var lab_points:Label = null;
		protected static var uiXML:XML =
			<View width="800" height="600">
			  <Image skin="png.bg.desk" x="-644" y="-1"/>
			  <Image skin="png.loading.img-logo" x="332" y="833"/>
			  <Image skin="png.images.chip-box" x="259" y="-11"/>
			  <Image skin="png.images.recycle-bin" x="-130" y="-64"/>
			  <Image skin="png.images.dispenser" x="612" y="-63"/>
			  <Box skin="png.comp.blank" x="359" y="125" var="banker_poker_con" width="81" height="33"/>
			  <Box x="453" y="98" var="point_display">
			    <Image skin="png.images.bust" var="img_points_bg"/>
			    <Label x="4" y="7" var="lab_points" color="0xffffff" text="21" size="30" width="58" height="36" align="center" font="Din"/>
			  </Box>
			</View>;
		public function MainViewUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
		}
	}
}