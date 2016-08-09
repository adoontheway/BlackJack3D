package 
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
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author jerry.d
	 */
	public class LongTimeMask extends Sprite 
	{
		private var tf:TextField;
		public var frameItem:FrameItem;
		public function LongTimeMask() 
		{
			super();	
			init();
			this.addEventListener(MouseEvent.CLICK, this.onTouched);
			this.addEventListener(Event.REMOVED_FROM_STAGE, this.onRemoved);
		}
		
		private function onRemoved(e:Event):void{
			FrameMgr.Instance.remove(this.name);
		}
		
		private function onTouched(e:MouseEvent):void{
			if ( this.parent ){
				this.parent.removeChild(this);
			}
			
		}
		
		
		private function init():void{
			this.name = 'longtimemask';
			this.frameItem = new FrameItem(this.name, this.update);
			this.tf = new TextField();
			var tFormat:TextFormat = new TextFormat();
			tFormat.align = 'center';
			tFormat.color = 0xffffff;
			tFormat.size = 32;
			this.tf.setTextFormat(tFormat);
			this.tf.text = "您已长时间未进行游戏，如果在倒计时结束前还未进行任何操作，系统将进行自动游戏:";
			this.tf.filters = [PokerGameVars.YELLOW_Glow_Filter];
			this.addChild(tf);
		}
		
		public function redraw():void{
			this.graphics.beginFill(0, 0.8);
			this.graphics.drawRect(0, 0, GameVars.Stage_Width, GameVars.Stage_Height);
			this.graphics.endFill();
		}
		
		public function update(delta:int):void{
			deadTime -= delta;
			this.tf.text = "您已长时间未进行游戏，如果在倒计时结束前还未进行任何操作，系统将进行自动游戏:\r\n"+ GameUtils.GetTimeString(deadTime);
		}
		
		private var deadTime:uint;
		public function show(dTime:uint):void{
			this.deadTime = dTime;
			redraw();
			tf.x = GameVars.Stage_Width - tf.width >> 1;
			tf.y = GameVars.Stage_Height - tf.height >> 1;
			GameVars.STAGE.addChild(this);
			FrameMgr.Instance.add(this.frameItem);
		}
		
		private static var _instance:LongTimeMask;
		public static function get Instance():LongTimeMask{
			if ( LongTimeMask._instance == null ){
				LongTimeMask._instance = new LongTimeMask();
			}
			return LongTimeMask._instance;
		}
	}

}