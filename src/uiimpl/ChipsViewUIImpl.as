package uiimpl 
{
	import com.greensock.TweenLite;
	import comman.duke.GameUtils;
	import consts.PokerGameVars;
	import flash.display.BlendMode;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.utils.getDefinitionByName;
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
			this.x = 149;
			this.y = 623;
			this.img_cover.visible = false;
			init();
		}

		private var selectEffect:MovieClip;
		private function init():void{
			var chip:Chip;
			for (var i:int = 0; i <= 5; i++){
				chip = new Chip();
				chip.x = rawX[i];
				chip.y = rawY[i];
				chips.push(chip);
				this.chips_con.addChild(chip);
				chip.addEventListener(MouseEvent.CLICK, onChip);
			}
			var clas:* = getDefinitionByName('SelecteChip');
			selectEffect = new clas() as MovieClip;
			selectEffect.blendMode = BlendMode.OVERLAY;
			selectEffect.filters = [PokerGameVars.YELLOW_Glow_Filter];
		}
		
		public function setupValues(arr:Array):void{
			var chip:Chip;
			for (var i:int = 0; i <= 5; i++){
				chip = chips[i];
				chip.value = arr[i];
			}
		}
		
		public function switchCover(flag:Boolean):void{
			this.img_cover.visible = flag;
			this.selectEffect.visible = !flag;
			if ( this.currentChip ){
				if ( flag ){
					this.currentChip.y = rawY[chips.indexOf(currentChip)];
				}else if ( !flag ){
					this.currentChip.y = rawY[chips.indexOf(currentChip)]-38;
				}
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
			if ( this.selectEffect.parent == null ){
				this.addChildAt(selectEffect,0);
			}
			selectEffect.x = currentChip.x + 40;
			selectEffect.y = currentChip.y + -3;
			TweenLite.to(currentChip, 0.2, {y:rawY[chips.indexOf(currentChip)]-38});
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