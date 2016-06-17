package uiimpl 
{
	import comman.duke.display.BitmapClip;
	import consts.PokerGameVars;
	import flash.events.MouseEvent;
	import game.ui.mui.MainViewUI;
	import model.ProtocolClientEnum;
	import morn.core.components.Button;
	import morn.core.components.Image;
	import comman.duke.*;
	import com.greensock.*;
	/**
	 * ...
	 * @author jerry.d
	 */
	public class MainViewImpl extends MainViewUI 
	{
		private const CHOSEY:int = 440;
		private const CHIPSY:int = 455;
		private const CHIPSX:Array = [126,194,262,330,398,466,534];
		
		private var mgr:GameMgr;
		private var frameItem:FrameItem;
		private var currentBtns:Vector.<Button>;
		private var currentHandler:Vector.<Function>;
		private var socketMgr:SocketMgr;
		public function MainViewImpl() 
		{
			super();
			this.init();
		}
		
		private function init():void{
			this.currentBtns = new Vector.<Button>();
			this.currentHandler = new Vector.<Function>();
			
			socketMgr = SocketMgr.Instance;
			mgr = GameMgr.Instance;
			
			var model:uint = mgr.model;
			var chipValues:Array = PokerGameVars.Model_Config[model];
			var len:int = CHIPSX.length;
			var posx:int = 0;
			var chip:ChipImpl;
			for (var i:int = 0; i < len; i++){
				posx = CHIPSX[i];
				chip = new ChipImpl(i);
				chip.x = posx;
				chip.y = CHIPSY;
				chip.value = chipValues[i];
				chip.addEventListener(MouseEvent.CLICK, this.onChipClick);
				this.addChild(chip);
				if ( i == 1){
					currentChip = chip;
					currentChip.y = CHOSEY;
					_currentValue = currentChip.value;
				}
			}
			
			
			this.btns = [btn_0, btn_1, btn_2, btn_3, btn_4];
			this.btn_0.addEventListener(MouseEvent.CLICK, this.onBtn);
			this.btn_1.addEventListener(MouseEvent.CLICK, this.onBtn);
			this.btn_2.addEventListener(MouseEvent.CLICK, this.onBtn);
			this.btn_3.addEventListener(MouseEvent.CLICK, this.onBtn);
			this.btn_4.addEventListener(MouseEvent.CLICK, this.onBtn);
			
			frameItem = new FrameItem('mainView', this.update);
			FrameMgr.Instance.add(frameItem);
			/**
			var clip:BitmapClip = new BitmapClip('anims', 'anim_dispense');
			clip.play( -1);
			this.addChild(clip);
			*/
		}
		
		private function onBtn(evt:MouseEvent):void{
			var target:Button = evt.currentTarget as Button;
			var name:String = target.name;
			var callBack:Function = callMapObject[name];
			if ( callBack != null ){
				callBack();
			}
		}
		private var btns:Array;
		public static const START:uint = 0;
		public static const OPER:uint = 1;
		public static const SPLIT:uint = 2;
		public static const INSURRANCE:uint = 3;
		private static const LABELS:Object = {
			0 : ['BET', 'START', 'DOUBLE'],
			1 : ['HIT', 'STAND', 'DOUBLE','SURRENDER'],
			2 : ['HIT', 'STAND', 'DOUBLE','SPLIT','SURRENDER'],
			3 : ['INSURRANCE','NOINSURRANCE']
		};
			private var callMapObject:Object = {
				'BET' : addbet,
				'START' : start,
				'STAND' : stand,
				'HIT' : hit,
				'DOUBLE' : double,
				'SPLIT' : split,
				'SURRENDER' : surrender,
				'INSURRANDE' : insurrance,
				'NOINSURRANCE': noinsurrance
			}
		
		public function showBtns(operation:uint):void{
			var labels:Array = LABELS[operation];
			var labelLen:uint = labels.length;
			var btn:Button;
			for (var i:int = 0; i < 5; i++){
				btn = this.btns[i];
				if ( i < labelLen){
					btn.visible = true;
					btn.name = labels[i];
					btn.label = labels[i];
				}else{
					btn.visible = false;
				}
			}
		}
		private var startX:int = 600;
		private var startY:int = 110;
		private var targetX:int = 250;
		private var bankerY:int = 100;
		private var playerY:int = 250;
		private var tweening:Boolean = false;
		private var tweenQueue:Array = [];
		public function onDispenseBack(poker:PokerImpl):void{
			if ( this.tweening ){
				this.tweenQueue.push( poker);
				return;
			}
			this.addChild(poker);
			
			this.allPoker.push(poker);
			
			tweening = true;
			if( !poker.needRotate )
				TweenLite.to(poker, 0.2, {x:poker.targetX, y:poker.targetY, onComplete:this.onTweenComplete});
			else
				TweenLite.to(poker, 0.2, {x:poker.targetX, y:poker.targetY, rotation:90, onComplete:this.onTweenComplete});
		}
		
		private function onTweenComplete():void{
			tweening = false;
			if ( this.tweenQueue.length){
				var temp:PokerImpl = this.tweenQueue.pop();
				this.onDispenseBack(temp);
			}else{
				this.showBtns(OPER);
			}
		}
		
		public function onRoundEnd(){
			
		}
		
		private function hit():void{
			socketMgr.send({proto:ProtocolClientEnum.PROTO_HIT});
		}
		private var allChip:Vector.<ChipImpl> = new Vector.<ChipImpl>();
		private var allPoker:Vector.<PokerImpl> = new Vector.<PokerImpl>();
		private function addbet():void{
			if ( this.currentChip ){
				var value:uint = this.currentChip.value;
				var chip:ChipImpl = new ChipImpl(this.currentChip.index);
				chip.value = value;
				chip.rotationY = -30;
				this.stage.addChild(chip);
				chip.x = 200;
				chip.y = 510;
				this.allChip.push(chip);
				TweenLite.to(chip, 0.4, {x:200 + 20 * (Math.random() - 0.5), y:280 + 20 * (Math.random() - 0.5)});
			}
		}
		private function start():void{
			if ( this._currentValue != 0 ){
				socketMgr.send({proto:ProtocolClientEnum.PROTO_START, bet:[this._currentValue]});
			}
		}
		private function double():void{
			socketMgr.send({proto:ProtocolClientEnum.PROTO_DOUBLE});
		}
		private function stand():void{
			socketMgr.send({proto:ProtocolClientEnum.PROTO_STAND});
		}
		private function split():void{
			socketMgr.send({proto:ProtocolClientEnum.PROTO_SPLIT});
		}
		private function surrender():void{
			socketMgr.send({proto:ProtocolClientEnum.PROTO_SURRENDER});
		}
		private function insurrance():void{
			
		}
		private function noinsurrance():void{
			
		}
		
		private var currentChip:ChipImpl;
		private var _currentValue:uint;
		private function onChipClick(evt:MouseEvent):void{
			if ( currentChip && currentChip == evt.currentTarget) return;
			if ( currentChip != null){
				currentChip.y = CHIPSY;
			}
			currentChip = evt.currentTarget as ChipImpl;
			currentChip.y = CHOSEY;
			_currentValue = currentChip.value;
			GameUtils.info('chose chip :', _currentValue);
		}
		
		public function get currentValue():uint{
			return _currentValue;
		}
		
		public function update(delta:int):void{
			if ( this.currentChip != null ){
				this.currentChip.roll();
			}
			this.lab_time.text = 'Now:'+GameUtils.GetTimeString(TickerMgr.SYSTIME);
		}
		
		private static var _instance:MainViewImpl;
		public static function get Instance():MainViewImpl{
			if ( MainViewImpl._instance == null){
				MainViewImpl._instance = new MainViewImpl();
			}
			return MainViewImpl._instance;
		}
	}

}