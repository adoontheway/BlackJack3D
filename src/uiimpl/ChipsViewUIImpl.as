package uiimpl 
{
	import com.greensock.TweenLite;
	import comman.duke.GameUtils;
	import consts.PokerGameVars;
	import flash.events.MouseEvent;
	import game.ui.mui.ChipsViewUI;
	import morn.core.components.Image;
	
	/**
	 * ...
	 * @author jerry.d
	 */
	public class ChipsViewUIImpl extends ChipsViewUI 
	{
		private var rawY:Vector.<int> = new Vector.<int>();
		private var chips:Vector.<Image> = new  Vector.<Image>();
		public function ChipsViewUIImpl() 
		{
			super();
			this.y = 480;
			this.x = 1000;
			this.chip_0.addEventListener(MouseEvent.CLICK, onChip);
			this.chip_1.addEventListener(MouseEvent.CLICK, onChip);
			this.chip_2.addEventListener(MouseEvent.CLICK, onChip);
			this.chip_3.addEventListener(MouseEvent.CLICK, onChip);
			this.chip_4.addEventListener(MouseEvent.CLICK, onChip);
			this.chip_5.addEventListener(MouseEvent.CLICK, onChip);
			this.chip_6.addEventListener(MouseEvent.CLICK, onChip);
			rawY.push(chip_0.y, chip_1.y, chip_2.y, chip_3.y, chip_4.y, chip_5.y, chip_6.y);
			chips.push(chip_0, chip_1, chip_2, chip_3, chip_4, chip_5, chip_6);
		}
		private var currentChip:Image;
		private var _currentValue:uint;
		private function onChip(evt:MouseEvent):void{
			GameUtils.info(evt.target['name'] + ' clicked');
			if ( currentChip && currentChip == evt.target) return;
			if ( currentChip != null){
				TweenLite.to(currentChip, 0.2, {y:rawY[chips.indexOf(currentChip)]});
			}
			currentChip = evt.target as Image;
			_currentValue = parseInt(evt.target['name'].replace('chip_', ''));
			TweenLite.to(currentChip, 0.2, {y:rawY[chips.indexOf(currentChip)]-30});
		}
		
		public function updateChips():void{
			var currentChip:Array = PokerGameVars.Model_Config[PokerGameVars.Model];
			var len:uint = currentChip.length;
			for (var i:uint = 0; i < len; i++){
				this['chip_' + i].name = 'chip_' + currentChip[i];
				(this['chip_' + i] as Image).url = 'png.chips.chip-'+currentChip[i];
			}
		}
		
		public function get currentValue():uint{
			return _currentValue;
		}
		
		private static var _instance:ChipsViewUIImpl;
		public static function get Instance():ChipsViewUIImpl{
			if ( ChipsViewUIImpl._instance == null){
				ChipsViewUIImpl._instance = new ChipsViewUIImpl();
			}
			return ChipsViewUIImpl._instance;
		}
	}

}