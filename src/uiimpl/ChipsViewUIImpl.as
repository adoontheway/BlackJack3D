package uiimpl 
{
	import com.greensock.TweenLite;
	import comman.duke.GameUtils;
	import comman.duke.PoolMgr;
	import comman.duke.ShakeItem;
	import comman.duke.ShakeMgr;
	import comman.duke.SoundMgr;
	import consts.PokerGameVars;
	import consts.SoundsEnum;
	import flash.display.BlendMode;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.utils.clearInterval;
	import flash.utils.getDefinitionByName;
	import flash.utils.setInterval;
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
			this.img_mask.cacheAsBitmap = this.img_cover.cacheAsBitmap = true;
			this.img_cover.mask = this.img_mask;
			this.x = 149;
			this.y = 623;
			//this.img_cover.visible = false;
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
			//this.img_cover.visible = flag;
			if ( flag && img_cover.y != -9){
				TweenLite.to(img_cover, 1.5, {y: -9});
			}else if ( !flag && img_cover.y != -104){
				TweenLite.to(img_cover, 1.5, {y: -104});
			}
			this.selectEffect.visible = !flag && this.currentChip != null;
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
			//GameUtils.info(evt.target['name'] + ' clicked');
			GameMgr.Instance.refresh();
			SoundMgr.Instance.playEffect( SoundsEnum.CHIP);
			if ( currentChip != null && currentChip == evt.target) {
				TweenLite.to(currentChip, 0.2, {y:rawY[chips.indexOf(currentChip)]});
				this.currentChip = null;
				this.currentValue = 0;
				this.selectEffect.visible = false;
				return;
			}
			
			if ( currentChip != null){
				TweenLite.to(currentChip, 0.2, {y:rawY[chips.indexOf(currentChip)]});
			}
			currentChip = evt.target as Chip;
			currentValue = currentChip.value;
			if ( this.selectEffect.parent == null ){
				this.addChildAt(selectEffect,0);
			}
			selectEffect.visible = true;
			selectEffect.x = currentChip.x + 38;
			selectEffect.y = currentChip.y - 3;
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
		/**
		private var shakeInterval:int = -1;
		private var currentShakeIndex:int = -1;
		public function shakeIt():void{
			if ( this.shakeInterval == -1){
				this.shakeInterval = setInterval(function():void{
					shakeIt();
				}, 1000);
				return;
			}
				
			this.currentShakeIndex++;
			if ( this.currentShakeIndex < this.chips.length){
				var chip:Chip = this.chips[this.currentShakeIndex];
				var item:ShakeItem = PoolMgr.gain(ShakeItem);
				item.init(this.name+chip.name, chip, 5, 4, ShakeMgr.SHAKE_VER, chip.x, chip.y);
				ShakeMgr.Instance.addShakeItem(item);
			}else{
				clearInterval(this.shakeInterval);
				this.shakeInterval = -1;
			}
		}
		*/
		private static var _instance:ChipsViewUIImpl;
		public static function get Instance():ChipsViewUIImpl{
			if ( ChipsViewUIImpl._instance == null){
				ChipsViewUIImpl._instance = new ChipsViewUIImpl();
			}
			return ChipsViewUIImpl._instance;
		}
	}

}