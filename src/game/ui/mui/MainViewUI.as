/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	public class MainViewUI extends View {
		public var img_bg:Image = null;
		public var banker_poker_con:Box = null;
		public var point_display:Box = null;
		public var img_points_bg:Image = null;
		public var lab_points:Label = null;
		protected static var uiXML:XML =
			<View width="1939" height="953">
			  <Image skin="png.bg.desk-1" x="0" y="-1" var="img_bg"/>
			  <Image skin="png.loading.img-logo" x="921" y="834"/>
			  <Image skin="png.images.chip-box" x="848" y="-10"/>
			  <Image skin="png.images.recycle-bin" x="459" y="-63"/>
			  <Image skin="png.images.dispenser" x="1201" y="-62"/>
			  <Box skin="png.comp.blank" x="948" y="126" var="banker_poker_con" width="81" height="33"/>
			  <Box x="1042" y="99" var="point_display">
			    <Image skin="png.images.bust" var="img_points_bg"/>
			    <Label x="4" y="7" var="lab_points" color="0xffffff" size="30" width="58" height="36" align="center" font="Din"/>
			  </Box>
			</View>;
		public function MainViewUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
		}
	}
}