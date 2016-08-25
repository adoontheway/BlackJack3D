package uiimpl 
{
	import comman.duke.GameVars;
	import comman.duke.SoundMgr;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import game.ui.mui.SettingsViewUI;
	
	/**
	 * ...
	 * @author jerry.d
	 */
	public class SettingsView extends SettingsViewUI 
	{
		private var currentScale:int = 100;
		public function SettingsView() 
		{
			super();
			this.btn_music_off.visible = this.btn_voice_off.visible = false;
			
			this.x = GameVars.Stage_Width - this.width >> 1;
			this.y = GameVars.Stage_Height - this.height >> 1;
			this.btn_close.addEventListener(MouseEvent.CLICK, hide);
			
			this.btn_help.addEventListener(MouseEvent.CLICK, onHelp);
			this.btn_mucis_on.addEventListener(MouseEvent.CLICK, onMusicOn);
			this.btn_music_off.addEventListener(MouseEvent.CLICK, onMusicOff);
			this.btn_voice_off.addEventListener(MouseEvent.CLICK, onVoiceOff);
			this.btn_voice_on.addEventListener(MouseEvent.CLICK, onVoiceOn);
			this.img_add.addEventListener(MouseEvent.CLICK, addScale);
			this.img_sub.addEventListener(MouseEvent.CLICK, reduceScale);
		}
		
		public function addScale(e:MouseEvent):void{
			currentScale += 5;
			this.lab_scale.text = currentScale + "%";
			if ( ExternalInterface.available ){
				ExternalInterface.call("changeViewScale", currentScale);
			}
		}
		
		public function reduceScale(e:MouseEvent):void{
			currentScale -= 5;
			if ( currentScale <= 0 ){
				currentScale = 5;
			}
			this.lab_scale.text = currentScale + "%";
			if ( ExternalInterface.available ){
				ExternalInterface.call("changeViewScale", currentScale);
			}
		}
		
		public function onMusicOn(e:MouseEvent):void{
			this.btn_mucis_on.visible = false;
			this.btn_music_off.visible = true;
			this.lab_music.text = "音乐关";
			
			SoundMgr.Instance.musicSwitch(false);
		}
		public function onMusicOff(e:MouseEvent):void{
			this.btn_mucis_on.visible = true;
			this.btn_music_off.visible = false;
			this.lab_music.text = "音乐开";
			
			SoundMgr.Instance.musicSwitch(true);
		}
		public function onVoiceOn(e:MouseEvent):void{
			this.btn_voice_on.visible = false;
			this.btn_voice_off.visible = true;
			this.lab_voice.text = "音效关";
			
			SoundMgr.Instance.voiceSwitch(false);
		}
		public function onVoiceOff(e:MouseEvent):void{
			this.btn_voice_on.visible = true;
			this.btn_voice_off.visible = false;
			this.lab_voice.text = "音效开";
			
			SoundMgr.Instance.voiceSwitch(true);
		}
		public function onHelp(e:MouseEvent):void{
			
		}
		
		public function show():void{
			if (!GameVars.STAGE.contains(this)){
				GameVars.STAGE.addChild(this);
			}
		}
		
		public function hide(e:MouseEvent):void{
			if ( this.parent != null ){
				this.parent.removeChild(this);
			}
		}
		
		private static var _instance:SettingsView;
		public static function get Instance():SettingsView{
			if ( SettingsView._instance == null){
				SettingsView._instance = new SettingsView();
			}
			return SettingsView._instance;
		}
	}

}