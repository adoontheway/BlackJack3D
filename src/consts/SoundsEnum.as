package consts 
{
	import comman.duke.GameUtils;
	import flash.media.Sound;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	import org.as3wavsound.WavSound;
	/**
	 * ...
	 * @author jerry.d
	 */
	public class SoundsEnum 
	{
		
		public static const BG:String = "sounds/bg_sound.mp3";
		public static const CHIP_DOWN:String = "sounds/chips_stacking.mp3";
		public static const DOUBLE_DOWN:String = "sounds/Raise-2.mp3";
		public static const SPLIT:String = "sounds/7_split.mp3";
		public static const HIT:String = "sounds/19_hitSound.mp3";
		public static const INSURRANCE:String = "sounds/17_insurance.mp3";
		public static const STAND:String = "sounds/20_staySound.mp3";
		public static const SELECT_DOWN:String = "sounds/27_selectDown.mp3";
		public static const SELECT_UP:String = "sounds/26_selectUp.mp3";
		public static const CHIP:String = "sounds/chips_hit_settle.mp3";
		public static const CARD:String = "sounds/fcard.mp3";
		public static const REVERSE:String = "sounds/ShowCards.mp3";

		public static function InitSounds():void{
			GameUtils.log('init sounds');
		}
	}

}