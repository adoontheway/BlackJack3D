package uiimpl 
{
	import com.greensock.loading.core.DisplayObjectLoader;
	import comman.duke.display.BitmapClip;
	import consts.PokerGameVars;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	import game.ui.mui.MainViewUI;
	import model.ProtocolClientEnum;
	import model.TableData;
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
		
		//-------------ui elments ------------------//

		public function MainViewImpl() 
		{
			super();
			this.init();
		}
		private var arrow:MovieClip;
		private function init():void{
			//this.circles = [];
			socketMgr = SocketMgr.Instance;
			
			mgr = GameMgr.Instance;
			mgr.mainView = this;
			
			
			var model:uint = mgr.model;
			var chipValues:Array = PokerGameVars.Model_Config[model];
			ChipsViewUIImpl.Instance.setupValues(chipValues);
			addChild(ChipsViewUIImpl.Instance);

			this.addChild(new BaseTable(1));
			this.addChild(new BaseTable(2));
			this.addChild(new BaseTable(3));
			
			this.btn_group.btn_double.addEventListener(MouseEvent.CLICK, this.double);
			this.btn_group.btn_hit.addEventListener(MouseEvent.CLICK, this.hit);
			this.btn_group.btn_stand.addEventListener(MouseEvent.CLICK, this.stand);
			this.btn_group.btn_rebet.addEventListener(MouseEvent.CLICK, this.rebet);

			balance.btn_recharge.addEventListener(MouseEvent.CLICK, onRecharge);
			/*
			var Arrow:Class = getDefinitionByName('Arrow') as Class;
			if ( Arrow != null){
				this.arrow = new Arrow() as MovieClip;
				this.arrow.addEventListener(Event.ADDED_TO_STAGE, playArrow);
				this.arrow.addEventListener(Event.REMOVED_FROM_STAGE, stopArrow);
			}
			
			frameItem = new FrameItem('mainView', this.update);
			FrameMgr.Instance.add(frameItem);
			
			var clip:BitmapClip = new BitmapClip('anims', 'anim_dispense');
			clip.play( -1);
			this.addChild(clip);
			*/
		}
		
		private function onRecharge(evt:MouseEvent):void{
			
		}
		/*
		private function playArrow(evt:Event):void{
			this.arrow.play();
		}
		
		private function stopArrow(evt:Event):void{
			this.arrow.stop();
		}
		
		*/
		
		public function betTable(table:BaseTable):void{
			var bet:int = ChipsViewUIImpl.Instance.currentValue;
			
			if ( bet != 0 ){
				var chip:Chip = PoolMgr.gain(Chip);
				chip.value = bet;
				this.stage.addChild(chip);
				var pos:Point = ChipsViewUIImpl.Instance.currentChip.localToGlobal(GameVars.Raw_Point);
				chip.x = pos.x;
				chip.y = pos.y;
				var targetPo:Point = table.getChipReferPoint();
				TweenLite.to(chip, 0.4, {x:targetPo.x, y:targetPo.y, onComplete:onChipTweenComplete, onCompleteParams:[table,chip,0]});
				mgr.betToTable(bet, table.id);
				totalBet += bet;
				this.updateBet();
			}
		}
		/** type 0:bet 1 :pair **/
		private function onChipTweenComplete(table:BaseTable, chip:Chip, type:int):void{
			table.addChip(chip,type);
		}
		
		public function betPair(table:BaseTable):void{
			var bet:int = ChipsViewUIImpl.Instance.currentValue;
			
			if ( bet != 0 ){
				var chip:Chip = PoolMgr.gain(Chip);
				chip.value = bet;
				this.stage.addChild(chip);
				var pos:Point = ChipsViewUIImpl.Instance.currentChip.localToGlobal(GameVars.Raw_Point);
				chip.x = pos.x;
				chip.y = pos.y;
				var targetPo:Point = table.getPairReferPoint();
				TweenLite.to(chip, 0.4, {x:targetPo.x, y:targetPo.y,onComplete:onChipTweenComplete, onCompleteParams:[table,chip,1]});
				mgr.betPair(bet, table.id);
				totalBet += bet;
				this.updateBet();
			}
		}
		
		
		private var totalBet:int = 0;
		private var currentTable:TableData;
		private function onTweenComplete():void{
			//tweening = false;
			/**
			if ( this.tweenQueue.length){
				var temp:Poker = this.tweenQueue.shift();
				//GameUtils.log('ready tweening:', temp.name);
				this.onDispenseBack(temp);
			}else{
				//check split, insurrance
				currentTable = mgr.currentTable;
				
				if ( currentTable != null ){
					//this.arrow.x = currentTable.arrowX;
					//this.arrow.y = currentTable.arrowY;
					this.stage.addChild(this.arrow);
					
					if ( mgr.needShowInsure){
						showBtns(INSURRANCE);
					}else 
					
					if ( currentTable.canSplit ){
						//showBtns(SPLIT);
					}else if ( currentTable.blackjack || currentTable.bust ){
						socketMgr.send({proto:ProtocolClientEnum.PROTO_STAND, tabId:currentTable.tableId});
					}else{
						//showBtns(OPER);
					}
				}
			}
			*/
		}
		
		
		
		private function hit(evt:MouseEvent):void{
			if (mgr.started){
				socketMgr.send({proto:ProtocolClientEnum.PROTO_HIT,  tabId:mgr.currentTable.tableId});
			}else{
				start();
			}
		}
		//private var allChip:Vector.<Chip> = new Vector.<Chip>();
		//private var allPoker:Vector.<Poker> = new Vector.<Poker>();
		private function start():void{
			//this.hideAllBtns();
			mgr.start();	
		}
		private function rebet(evt:MouseEvent):void{
			//this.hideAllBtns();
		}
		private function double(evt:MouseEvent):void{
			//this.hideAllBtns();
			socketMgr.send({proto:ProtocolClientEnum.PROTO_DOUBLE, tabId:mgr.currentTable.tableId});
		}
		private function stand(evt:MouseEvent):void{
			//this.hideAllBtns();
			socketMgr.send({proto:ProtocolClientEnum.PROTO_STAND, tabId:mgr.currentTable.tableId});
		}
		private function split(evt:MouseEvent):void{
			//this.hideAllBtns();
			socketMgr.send({proto:ProtocolClientEnum.PROTO_SPLIT, tabId:mgr.currentTable.tableId});
		}
		
		private function insurrance(evt:MouseEvent):void{
			//this.hideAllBtns();
			socketMgr.send({proto:ProtocolClientEnum.PROTO_INSURRANCE, tabId:mgr.currentTable.tableId});
		}
		
		public function updateBalance(value:Number):void{
			this.balance.lab_0.text = GameUtils.NumberToString(value);
		}
		
		public function updateBet():void{
			//this.bet.lab.text = GameUtils.NumberToString(totalBet);
		}
		
		public function update(delta:int):void{
			//this.lab_time.text = 'Now:'+GameUtils.GetDateTime(TickerMgr.SYSTIME);
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
				//this.arrow.x = currentTable.arrowX;
				//this.arrow.y = currentTable.arrowY;
				if ( currentTable.canSplit ){
					//showBtns(SPLIT);
				}else if ( currentTable.blackjack || currentTable.bust ){
					socketMgr.send({proto:ProtocolClientEnum.PROTO_STAND, tabId:currentTable.tableId});
				}else{
					//this.stage.addChild(this.arrow);
					//this.arrow.play();
					//showBtns(OPER);
				}
			}
		}
		
		public function onRoundEnd():void{
			/**
			var poker:Poker;
			while (this.allPoker.length != 0){
				poker = allPoker.pop();
				this.stage.removeChild(poker);
				PoolMgr.reclaim(poker);
			}
			var chip:Chip;
			while ( this.allChip.length != 0){
				chip = this.allChip.pop();
				this.stage.removeChild(chip);
				PoolMgr.reclaim(chip);
			}
			/**
			for each(var mc:MovieClip in this.circles){
				mc.mouseChildren = mc.mouseEnabled = true;
			}
			if( this.arrow && this.arrow.parent != null)
				this.stage.removeChild(this.arrow);
			this.arrow.stop();
			this.showBtns(START);
			*/
			this.totalBet = 0;
		}
		private var dispenserPos:Point = new Point(612, 50);
		public function onResize():void{
			this.x = GameVars.Stage_Width - this.width >> 1;
			PokerGameVars.DispensePostion = this.localToGlobal(dispenserPos);
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