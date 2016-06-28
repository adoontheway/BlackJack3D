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
		private var rawY:Array = [0, 4, 6, 6, 4, 0];
		private var rawX:Array = [-1, 75, 151, 227, 303, 379];
		private var chips:Vector.<Chip> = new  Vector.<Chip>();
		public function ChipsViewUIImpl() 
		{
			super();
			this.x = 156;
			this.y = 625;
			init();
		}
		
		private function init():void{
			var chip:Chip;
			for (var i:int = 0; i <= 5; i++){
				chip = new Chip();
				chip.x = rawX[i];
				chip.y = rawY[i];
				chips.push(chip);
				this.addChild(chip);
				chip.addEventListener(MouseEvent.CLICK, onChip);
			}
		}
		
		public function setupValues(arr:Array):void{
			var chip:Chip;
			for (var i:int = 0; i <= 5; i++){
				chip = chips[i];
				chip.value = arr[i];
			}
		}
		public var currentChip:Chip;
		public var currentValue:uint;
		private function onChip(evt:MouseEvent):void{
			GameUtils.info(evt.target['name'] + ' clicked');
			if ( currentChip && currentChip == evt.target) return;
			if ( currentChip != null){
				TweenLite.to(currentChip, 0.2, {y:rawY[chips.indexOf(currentChip)]});
			}
			currentChip = evt.target as Chip;
			currentValue = currentChip.value;
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
		
		
		private static var _instance:ChipsViewUIImpl;
		public static function get Instance():ChipsViewUIImpl{
			if ( ChipsViewUIImpl._instance == null){
				ChipsViewUIImpl._instance = new ChipsViewUIImpl();
			}
			return ChipsViewUIImpl._instance;
		}
	}

}