package uiimpl 
{
	import comman.duke.display.BitmapClip;
	import consts.PokerGameVars;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	import game.ui.mui.MainViewUI;
	import model.ProtocolClientEnum;
	import model.Table;
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
		private var circles:Array;
		private var socketMgr:SocketMgr;
		public function MainViewImpl() 
		{
			super();
			this.init();
		}
		private var arrow:MovieClip;
		private function init():void{
			this.currentBtns = new Vector.<Button>();
			this.currentHandler = new Vector.<Function>();
			this.circles = [];
			socketMgr = SocketMgr.Instance;
			
			mgr = GameMgr.Instance;
			mgr.mainView = this;
			
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
			
			var TableCircle:Class = getDefinitionByName('BetCircle') as Class;
			if ( TableCircle != null){
				var circle:MovieClip;
				var posInfo:Object;
				for (i = 1; i <= 3; i++){
					circle = new TableCircle() as MovieClip;
					circle.name = 'circle_'+i;
					posInfo = PokerGameVars.Circle_Pos[i];
					circle.x = posInfo.x;
					circle.y = posInfo.y;
					circle.addEventListener(MouseEvent.ROLL_OVER, this.onCircle);
					circle.addEventListener(MouseEvent.ROLL_OUT, this.onOutCircle);
					circle.addEventListener(MouseEvent.CLICK, this.onCircleClick);
					this.circles.push(circle);
					this.addChild( circle );
				}
			}
			
			var Arrow:Class = getDefinitionByName('Arrow') as Class;
			if ( Arrow != null){
				this.arrow = new Arrow() as MovieClip;
				this.arrow.addEventListener(Event.ADDED_TO_STAGE, playArrow);
				this.arrow.addEventListener(Event.REMOVED_FROM_STAGE, stopArrow);
			}
			
			frameItem = new FrameItem('mainView', this.update);
			FrameMgr.Instance.add(frameItem);
			/**
			var clip:BitmapClip = new BitmapClip('anims', 'anim_dispense');
			clip.play( -1);
			this.addChild(clip);
			*/
		}
		
		private function playArrow(evt:Event):void{
			this.arrow.play();
		}
		
		private function stopArrow(evt:Event):void{
			this.arrow.stop();
		}
		
		private function onCircle(evt:MouseEvent):void{
			var target:MovieClip = evt.currentTarget as MovieClip;
			if ( target != null ){
				target.gotoAndPlay(2);
			}
		}
		
		private function onOutCircle(evt:MouseEvent):void{
			var target:MovieClip = evt.currentTarget as MovieClip;
			if ( target != null ){
				target.gotoAndStop(1);
			}
		}
		
		private function onCircleClick(evt:MouseEvent):void{
			var target:MovieClip = evt.currentTarget as MovieClip;
			if ( target != null && this.currentChip){
				var id:int = parseInt(target.name.replace('circle_', ''));
				if ( this.currentChip ){
					var value:uint = this.currentChip.value;
					var chip:ChipImpl = PoolMgr.gain(ChipImpl);//new ChipImpl(this.currentChip.index);
					chip.index = this.currentChip.index;
					chip.value = value;
					this.stage.addChild(chip);
					chip.x = 200;
					chip.y = 510;
					chip.scaleY = 0.8;
					this.allChip.push(chip);
					TweenLite.to(chip, 0.4, {x:target.x - 30, y:target.y-50});
					mgr.betToTable(this._currentValue, id, id);
					totalBet += _currentValue;
					this.updateBet();
				}
			}
		}
		
		private var totalBet:int = 0;
		
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
			0 : ['START'],
			1 : ['HIT', 'STAND', 'DOUBLE'],
			2 : ['HIT', 'STAND', 'DOUBLE','SPLIT'],
			3 : ['INSURRANCE','NOINSURRANCE']
		};
			private var callMapObject:Object = {
				//'BET' : addbet,
				'START' : start,
				'STAND' : stand,
				'HIT' : hit,
				'DOUBLE' : double,
				'SPLIT' : split,
				//'SURRENDER' : surrender,
				'INSURRANDE' : insurrance,
				'NOINSURRANCE': noinsurrance
			}
		
			private function hideAllBtns():void{
				var btn:Button;
				for (var i:int = 0; i < 5; i++){
					btn = this.btns[i];
					btn.visible = false;
				}
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
				//GameUtils.log('queue:', poker.name);
				this.tweenQueue.push( poker);
				return;
			}
			
			GameVars.STAGE.stage.addChild(poker);
		
			this.allPoker.push(poker);
			poker.x = startX;
			poker.y = startY;
			tweening = true;
			//GameUtils.log('tween:', poker.name);
			if( poker.targetRotate == 0 )
				TweenLite.to(poker, 0.5, {x:poker.targetX, y:poker.targetY, onComplete:this.onTweenComplete});
			else
				TweenLite.to(poker, 0.5, {x:poker.targetX, y:poker.targetY, rotation:poker.targetRotate, onComplete:this.onTweenComplete});
			
		}
		private var currentTable:Table;
		private function onTweenComplete():void{
			tweening = false;
			if ( this.tweenQueue.length){
				var temp:PokerImpl = this.tweenQueue.shift();
				//GameUtils.log('ready tweening:', temp.name);
				this.onDispenseBack(temp);
			}else{
				//check split, insurrance
				currentTable = mgr.currentTable;
				
				if ( currentTable != null ){
					this.arrow.x = currentTable.arrowX;
					this.arrow.y = currentTable.arrowY;
					this.stage.addChild(this.arrow);
					/**
					if ( mgr.needShowInsure){
						showBtns(INSURRANCE);
					}else 
					*/
					if ( currentTable.canSplit ){
						showBtns(SPLIT);
					}else if ( currentTable.blackjack || currentTable.bust ){
						socketMgr.send({proto:ProtocolClientEnum.PROTO_STAND, tabId:currentTable.tableId});
					}else{
						showBtns(OPER);
					}
				}
			}
		}
		
		
		
		private function hit():void{
			this.hideAllBtns();
			socketMgr.send({proto:ProtocolClientEnum.PROTO_HIT,  tabId:currentTable.tableId});
		}
		private var allChip:Vector.<ChipImpl> = new Vector.<ChipImpl>();
		private var allPoker:Vector.<PokerImpl> = new Vector.<PokerImpl>();
		private function start():void{
			this.hideAllBtns();
			mgr.start();	
		}
		private function double():void{
			this.hideAllBtns();
			socketMgr.send({proto:ProtocolClientEnum.PROTO_DOUBLE, tabId:currentTable.tableId});
		}
		private function stand():void{
			this.hideAllBtns();
			socketMgr.send({proto:ProtocolClientEnum.PROTO_STAND, tabId:currentTable.tableId});
		}
		private function split():void{
			this.hideAllBtns();
			socketMgr.send({proto:ProtocolClientEnum.PROTO_SPLIT, tabId:currentTable.tableId});
		}
		
		private function insurrance():void{
			this.hideAllBtns();
			socketMgr.send({proto:ProtocolClientEnum.PROTO_INSURRANCE, tabId:currentTable.tableId});
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
		
		public function updateBalance(value:Number):void{
			this.balance.lab_0.text = GameUtils.NumberToString(value);
		}
		
		public function updateBet():void{
			this.bet.lab.text = GameUtils.NumberToString(totalBet);
		}
		
		public function update(delta:int):void{
			if ( this.currentChip != null ){
				this.currentChip.roll();
			}
			this.lab_time.text = 'Now:'+GameUtils.GetDateTime(TickerMgr.SYSTIME);
		}
		
		public function onStarted():void{
			for each(var mc:MovieClip in this.circles){
				mc.mouseChildren = mc.mouseEnabled = false;
			}
		}
		
		public function onDoubleBack(tabId:int, moreBet:int):void{
			this.totalBet += moreBet;
			this.updateBet();
		}
		
		public function onStandBack():void{
			currentTable = mgr.currentTable;
			if ( currentTable != null ){
				this.arrow.x = currentTable.arrowX;
				this.arrow.y = currentTable.arrowY;
				if ( currentTable.canSplit ){
					showBtns(SPLIT);
				}else if ( currentTable.blackjack || currentTable.bust ){
					socketMgr.send({proto:ProtocolClientEnum.PROTO_STAND, tabId:currentTable.tableId});
				}else{
					this.stage.addChild(this.arrow);
					this.arrow.play();
					showBtns(OPER);
				}
			}
		}
		
		public function onRoundEnd():void{
			var poker:PokerImpl;
			while (this.allPoker.length != 0){
				poker = allPoker.pop();
				this.stage.removeChild(poker);
				PoolMgr.reclaim(poker);
			}
			var chip:ChipImpl;
			while ( this.allChip.length != 0){
				chip = this.allChip.pop();
				this.stage.removeChild(chip);
				PoolMgr.reclaim(chip);
			}
			
			for each(var mc:MovieClip in this.circles){
				mc.mouseChildren = mc.mouseEnabled = true;
			}
			if( this.arrow && this.arrow.parent != null)
				this.stage.removeChild(this.arrow);
			this.arrow.stop();
			this.showBtns(START);
			this.totalBet = 0;
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