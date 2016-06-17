/**Created by the Morn,do not modify.*/
package game.ui.mui {
	import morn.core.components.*;
	public class ChipsViewUI extends View {
		public var chip_0:Image = null;
		public var chip_1:Image = null;
		public var chip_2:Image = null;
		public var chip_3:Image = null;
		public var chip_4:Image = null;
		public var chip_5:Image = null;
		public var chip_6:Image = null;
		protected static var uiXML:XML =
			<View width="750" height="150">
			  <Image skin="png.chips.chip-1" x="-1" y="71" var="chip_0" name="chip_0"/>
			  <Image skin="png.chips.chip-2" x="107" y="71" var="chip_1"/>
			  <Image skin="png.chips.chip-5" x="221" y="64" var="chip_2" name="chip_2"/>
			  <Image skin="png.chips.chip-10" x="329" y="52" var="chip_3" name="chip_3"/>
			  <Image skin="png.chips.chip-50" x="430" y="39" var="chip_4" name="chip_4"/>
			  <Image skin="png.chips.chip-100" x="533" y="27" var="chip_5" name="chip_5"/>
			  <Image skin="png.chips.chip-1000" x="633" y="5" var="chip_6" name="chip_6"/>
			</View>;
		public function ChipsViewUI(){}
		override protected function createChildren():void {
			super.createChildren();
			createView(uiXML);
		}
	}
}