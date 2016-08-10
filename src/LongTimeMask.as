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
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	/**
	 * ...
	 * @author jerry.d
	 */
	public class LongTimeMask extends Sprite 
	{
		private var tf:TextField;
		private var tTimer:TextField;
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
			hide();
		}
		
		
		private function init():void{
			this.name = 'longtimemask';
			this.frameItem = new FrameItem(this.name, this.update);
			
			this.tf = new TextField();
			this.tf.mouseEnabled = false;
			this.tf.autoSize =  TextFieldAutoSize.CENTER;
			var tFormat:TextFormat = new TextFormat();
			tFormat.align = TextFieldAutoSize.CENTER;
			tFormat.color = 0xffffff;
			tFormat.size = 36;
			this.tf.defaultTextFormat = tFormat;
			
			this.tf.text = "您已长时间未进行游戏\r\n如果在倒计时结束前还未进行任何操作，系统将进行自动游戏";
			this.tf.filters = [PokerGameVars.YELLOW_Glow_Filter];
			this.addChild(tf);
			
			this.tTimer = new TextField();
			this.tTimer.mouseEnabled = false;
			this.tTimer.autoSize =  TextFieldAutoSize.CENTER;
			var tFormat1:TextFormat = new TextFormat();
			tFormat1.align = TextFieldAutoSize.CENTER;
			tFormat1.color = 0xffffff;
			tFormat.bold = true;
			tFormat1.size = 48;
			this.tTimer.defaultTextFormat = tFormat1;
			this.tTimer.filters = [PokerGameVars.YELLOW_Glow_Filter];
			this.addChild(tTimer);
		}
		
		public function redraw():void{
			this.graphics.clear();
			this.graphics.beginFill(0, 0.8);
			this.graphics.drawRect(0, 0, GameVars.Stage_Width, GameVars.Stage_Height);
			this.graphics.endFill();
			
			tf.x = GameVars.Stage_Width - tf.width >> 1;
			tf.y = GameVars.Stage_Height - tf.height >> 1;
			tTimer.x = GameVars.Stage_Width - tTimer.width >> 1;
			tTimer.y = tf.y + tf.height;
		}
		
		public function update(delta:int):void{
			deadTime -= delta;
			if ( deadTime > 0 ){
				this.tTimer.text = GameUtils.GetTimeString(deadTime,'[min]:[sec]');
			}else{
				GameMgr.Instance.autoGame();
				hide();
			}
		}
		
		private var deadTime:uint;
		public function show(dTime:uint):void{
			this.deadTime = dTime;
			GameUtils.log('Show Remind for : ', dTime);
			redraw();
			
			GameVars.STAGE.addChild(this);
			FrameMgr.Instance.add(this.frameItem);
		}
		
		public function hide():void{
			if ( this.parent ){
				this.parent.removeChild(this);
			}
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