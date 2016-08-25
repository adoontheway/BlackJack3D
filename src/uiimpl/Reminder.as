package uiimpl 
{
	import comman.duke.FrameItem;
	import comman.duke.FrameMgr;
	import comman.duke.GameVars;
	import game.ui.mui.ReminderUI;
	
	/**
	 * ...
	 * @author jerry.d
	 */
	public class Reminder extends ReminderUI 
	{
		private var frameItem:FrameItem;
		public function Reminder() 
		{
			super();
			 
			this.name = 'reminder';
			this.frameItem = new FrameItem(this.name, this.update);
			this.x = GameVars.Stage_Width - this.width >> 1;
			this.y = GameVars.Stage_Height - this.height >> 1;
		}
		private var resetTime:int = 2000;
		public function show(msg:String):void{
			this.content.text = msg;
			GameVars.STAGE.addChild(this);
			resetTime = 2000;
			if ( !FrameMgr.Instance.has(this.name)){
				FrameMgr.Instance.add(this.frameItem);
			}
		}
		
		public function update(delta:int):void{
			this.resetTime -= delta;
			if ( this.resetTime <= 0){
				if ( this.parent != null){
					this.parent.removeChild(this);
				}
				FrameMgr.Instance.remove(this.name);
			}
		}
		
		private static var _instance:Reminder;
		public static function get Instance():Reminder{
			if ( Reminder._instance == null ){
				Reminder._instance = new Reminder();
			}
			return Reminder._instance;
		}
	}

}