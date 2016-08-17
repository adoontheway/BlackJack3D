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

		/***--- voices ----***/
		public static const WELCOME:String = "sounds/welcome.mp3";
		public static const POINT_1:String = "sounds/point_1.mp3";
		public static const POINT_2:String = "sounds/point_2.mp3";
		public static const POINT_3:String = "sounds/point_3.mp3";
		public static const POINT_4:String = "sounds/point_4.mp3";
		public static const POINT_5:String = "sounds/point_5.mp3";
		public static const POINT_6:String = "sounds/point_6.mp3";
		public static const POINT_7:String = "sounds/point_7.mp3";
		public static const POINT_8:String = "sounds/point_8.mp3";
		public static const POINT_9:String = "sounds/point_9.mp3";
		public static const POINT_10:String = "sounds/point_10.mp3";
		public static const POINT_11:String = "sounds/point_11.mp3";
		public static const POINT_12:String = "sounds/point_12.mp3";
		public static const POINT_13:String = "sounds/point_13.mp3";
		public static const POINT_14:String = "sounds/point_14.mp3";
		public static const POINT_15:String = "sounds/point_15.mp3";
		public static const POINT_16:String = "sounds/point_16.mp3";
		public static const POINT_17:String = "sounds/point_17.mp3";
		public static const POINT_18:String = "sounds/point_18.mp3";
		public static const POINT_19:String = "sounds/point_19.mp3";
		public static const POINT_20:String = "sounds/point_20.mp3";
		public static const POINT_21_0:String = "sounds/point_21_0.mp3";
		public static const POINT_21_1:String = "sounds/point_21_1.mp3";
		public static const BUST_0:String = "sounds/bust_0.mp3";
		public static const BUST_1:String = "sounds/bust_1.mp3";
		public static const BLACKJACK:String = "sounds/player_blackjack.mp3";
		
		public static const BANKER_BJ_0:String = "sounds/banker_bj_0.mp3";
		public static const BANKER_BJ_1:String = "sounds/banker_bj_1.mp3";
		public static const BANKER_BUST_0:String = "sounds/banker_bj_0.mp3";
		public static const BANKER_BUST_1:String = "sounds/banker_bj_1.mp3";
		
		public static const NEED_INSURRANCE:String = "sounds/need_insure.mp3";
		public static function InitSounds():void{
			//GameUtils.log('init sounds');
		}
	}

}