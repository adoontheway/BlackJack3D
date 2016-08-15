package uiimpl 
{
	import comman.duke.FrameItem;
	import comman.duke.FrameMgr;
	import comman.duke.GameUtils;
	import comman.duke.GameVars;
	import consts.PokerGameVars;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import game.ui.mui.OverTimeReminderUI;
	
	/**
	 * ...
	 * @author jerry.d
	 */
	public class OverTimeReminder extends OverTimeReminderUI 
	{
		public var frameItem:FrameItem;
		public function OverTimeReminder() 
		{
			super();	
			init();
			this.btn_return.addEventListener(MouseEvent.CLICK, this.onTouched);
			this.addEventListener(Event.REMOVED_FROM_STAGE, this.onRemoved);
		}
		
		private function onRemoved(e:Event):void{
			FrameMgr.Instance.remove(this.name);
		}
		
		private function onTouched(e:MouseEvent):void{
			hide();
		}
		
		private function init():void{
			this.name = 'longtimemask';
			this.frameItem = new FrameItem(this.name, this.update);
		}
		
		public function update(delta:int):void{
			deadTime -= delta;
			//GameUtils.log('OverTimeReminder:',deadTime);
			if ( deadTime > 0 ){
				this.timer.text = GameUtils.GetTimeString(deadTime,'[min]:[sec]');
			}else{
				GameMgr.Instance.autoGame();
				hide();
			}
		}
		
		public function onResize():void{
			this.x = GameVars.Stage_Width - this.width >> 1;
			this.y = GameVars.Stage_Height - this.height >> 1;
		}
		
		private var deadTime:int;
		public function show(dTime:int):void{
			this.deadTime = dTime;
			GameVars.ShowMask();
			GameVars.STAGE.addChild(this);
			FrameMgr.Instance.add(this.frameItem);
			onResize();
		}
		
		public function hide():void{
			if ( this.parent ){
				this.parent.removeChild(this);
			}
			GameVars.HideMask();
		}
		
		private static var _instance:OverTimeReminder;
		public static function get Instance():OverTimeReminder{
			if ( OverTimeReminder._instance == null ){
				OverTimeReminder._instance = new OverTimeReminder();
			}
			return OverTimeReminder._instance;
		}
	}

}