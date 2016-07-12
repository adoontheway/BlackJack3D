package uiimpl 
{
	import com.greensock.*;
	import com.greensock.easing.*;
	import comman.duke.*;
	import consts.PokerGameVars;
	import consts.SoundsEnum;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import game.ui.mui.SubTableUI;
	import model.ProtocolClientEnum;
	import model.TableData;
	import utils.TableUtil;
	
	/**
	 * ...
	 * @author jerry.d
	 */
	public class SubTable extends SubTableUI 
	{
		public var id:int;
		public var tableData:TableData;
		private var _selected:Boolean;
		private var frameItem:FrameItem;
		private var mgr:GameMgr;
		public function SubTable($id:int) 
		{
			super();
			this.id = $id;
			this.x = $id <= 3 ? 35 : 65;
			this.y = $id <= 3 ? 40 : -20;
			this.visible = $id <= 3;
			this.poker_con.scale = 0.8;
			this.name = 'subtable' + $id;
			btn_insurrance.visible = btn_split.visible = mark_blackjack.visible = point_display.visible = bet_display.visible = false;
			btn_insurrance.addEventListener(MouseEvent.CLICK, this.insurrance);
			btn_split.addEventListener(MouseEvent.CLICK, this.split);
			this.bet_display.btn_close.addEventListener(MouseEvent.CLICK, onCloseBets);
			
			this.frameItem = new FrameItem(this.name, this.update);
			
			mgr = GameMgr.Instance;
			this.lab_points.text = this.id+"";
			mgr.registerSubTableDisplay( $id, this);
			ImageClickCenter.Instance.add(this.btn_insurrance);
			ImageClickCenter.Instance.add(this.btn_split);
			chips_con.filters = [PokerGameVars.Drop_Shadow_Filter_SHORTWAY];
		}
		
		public function showBet():void{
			if ( chips_con.numChildren == 0){
				//todo merge chips
				var chip:Chip = PoolMgr.gain(Chip);
				chip.y = 0;
				chip.x = 0;
				chip.value = tableData.currentBet;
				chip.scale = 0.2;
				chip.mouseChildren = chip.mouseEnabled = false;
				chips_con.addChild(chip);
				TweenLite.to(chip, 0.2, {scale:1, ease: Back.easeOut});
			}else{
				TableUtil.displayChipsToContainer(tableData.currentBet, chips_con);
			}
			this.updateBetinfo();
		}
		
		public function addCard(poker:Poker):void 
		{
			tableData.addCard(poker);
			updatePoints();
			mark_blackjack.visible = tableData.blackjack;
			doTween(poker);
		}
		private var dispenseStartPoint:Point;
		private function doTween(poker:Poker):void{
			this.poker_con.addChild(poker);
			poker.targetX = poker_con.numChildren*20;
			poker.targetY = 0;
			
			if ( dispenseStartPoint == null ){
				dispenseStartPoint = this.globalToLocal( PokerGameVars.DispensePostion); 
			}
			
			poker.x = dispenseStartPoint.x;
			poker.y = dispenseStartPoint.y;
			SoundMgr.Instance.playEffect( SoundsEnum.CARD );
			TweenLite.to(poker, 0.4, {x:poker.targetX, rotationY:0,rotation:0,y:poker.targetY, onComplete:this.onTweenComplete});
		}
		
		private function onTweenComplete():void{
			TableUtil.reOrderContainer(poker_con, 0, 200, 200);
		}
		private function betTable(evt:MouseEvent):void{
			var bet:int = ChipsViewUIImpl.Instance.currentValue;
			if ( bet != 0 ){
				mgr.betToTable(id, bet);
			}
		}
		
		public function updateBetinfo():void{
			this.bet_display.visible = true;
			this.bet_display.lab.text = GameUtils.NumberToString(tableData.currentBet);
		}
		
		public function updatePoints(isSettled:Boolean = false):void{
			this.lab_points.size = 30;
			this.lab_points.y = 12;
			if ( !tableData.bust ){
				if ( !tableData.blackjack){
					if ( !tableData.hasA || (tableData.hasA && tableData.points >= 11) ){
						if (tableData.points < 21 ){
							this.img_points_bg.url = 'png.images.green';
							this.lab_points.text =  tableData.points+"";
						}else{
							this.img_points_bg.url = 'png.images.full';
							this.lab_points.text =  tableData.points+"";
						}
					}else{
						if ( !isSettled ){
							this.img_points_bg.url = 'png.images.soft';
							this.lab_points.size = 20;
							this.lab_points.y = 22;
							this.lab_points.text =  tableData.points+"/"+(tableData.points+10);
						}else{
							this.img_points_bg.url = 'png.images.green';
							this.lab_points.size = 30;
							this.lab_points.text =  (tableData.points + 10) + "";
						}
					}
					
				}else{
					this.img_points_bg.url = 'png.images.green';
					this.lab_points.text =  "21";
				}
			}else{
				this.img_points_bg.url = 'png.images.bust';
				this.lab_points.text = tableData.points + "";
			}
			this.point_display.visible = true;
		}
		
		public function onInsureBack(bet:int):void{
			
			var value:uint = bet > 0 ? bet : -bet;
			/**
			var chip:Chip = PoolMgr.gain(Chip);
			chip.value = value;
			chip.x = 30;
			chip.y = 50;
			this.addChild(chip);
			this.insurranceChip.push(chip);
			*/
			TableUtil.displayChipsToContainer(value, this.insure_con);
			
			var targetPos:Point;
			if ( bet > 0 ){
				targetPos = this.insure_con.globalToLocal( new Point(130, 112));
			}else{
				targetPos =  this.insure_con.globalToLocal(new Point(130, 640));
			}
			var chip:Chip;
			var num:int = insure_con.numChildren - 1;
			while ( num >= 0 ){
				chip = insure_con.getChildAt(num) as Chip;
				TweenLite.to(chip, 0.4, {x:targetPos.x, y:targetPos.y, onComplete:onChipComplete, onCompleteParams:[chip]});
				num--;
			}
		}
		
		private function onChipComplete(chip:Chip):void{
			chip.parent.removeChild(chip);
			PoolMgr.reclaim(chip);
		}
		
		private function split(evt:MouseEvent):void{ 
			SoundMgr.Instance.playEffect( SoundsEnum.SPLIT );
			SocketMgr.Instance.send({proto:ProtocolClientEnum.PROTO_SPLIT, tabId:id});
			this.btn_split.visible = false;
		}
		
		private function insurrance(evt:MouseEvent):void{
			SoundMgr.Instance.playEffect( SoundsEnum.INSURRANCE);
			tableData.insured = true;
			this.btn_insurrance.visible = false;
			Buttons.Instance.switchModel(Buttons.MODEL_INSRRURING);
			
			/**
			var bet:int = this.tableData.currentBet;//要组合
			var chip:Chip = PoolMgr.gain(Chip);
			chip.value = bet;
			chip.x = 80;
			chip.y = 80;
			this.addChild(chip);
			this.insurranceChip.push(chip);
			*/
		}
		//private var insurranceChip:Array = [];
		
		private function onCloseBets(evt:MouseEvent):void{
			this.bet_display.visible = false;
		}
		
		public function update(delta:int):void{
			if ( _selected && (poker_con.scale > 0.9) ){
				parent.setChildIndex(this,parent.numChildren - 1);
				FrameMgr.Instance.remove(this.name);
				btn_split.visible = !tableData.isSplited && tableData.canSplit;
			}else if ( !_selected && (poker_con.scale <= 0.9)){
				parent.setChildIndex(this,parent.numChildren - 2);
				FrameMgr.Instance.remove(this.name);
			}
		}
		
		public function end(data:Object):void{
			var pos:Point = localToGlobal(new Point(100,50))
			if ( data.result == -1){
				comman.duke.NumDisplay.show( -data.gain, pos.x,  pos.y);
				removeAllBet( -1, chips_con,114,96);
			}else if ( data.result == 1){
				comman.duke.NumDisplay.show( data.gain, pos.x, pos.y);
				var sp:Sprite = TableUtil.getChipStack(data.gain);
				var pos:Point = this.globalToLocal(PokerGameVars.ChipLostPos);
				sp.x = pos.x;
				sp.y = pos.y;
				this.addChild(sp);
				TweenLite.to(sp, 0.8, {x:50, y:50, onComplete:onGainComplete, onCompleteParams:[sp]});
			}else{
				comman.duke.NumDisplay.show( 0, pos.x,  pos.y);
			}
		}
		
		private function onGainComplete(sp:Sprite):void{
			removeAllBet(1, chips_con,114,96);
			removeAllBet(1, sp,0,0,true);
			
		}
		
		public function removeAllBet(type:int,con:DisplayObjectContainer, rawX:int, rawY:int,reclamContainer:Boolean=false):void{
			var point:Point = con.parent.globalToLocal(type == -1 ? PokerGameVars.ChipLostPos : PokerGameVars.ChipGainPos );
			TweenLite.to(con, 0.8, {x:point.x, y:point.y, onComplete:removeAllChip, onCompleteParams:[con,rawX,rawY,reclamContainer]});
		}
		
		public function removeAllChip(con:DisplayObjectContainer,rawX:int,rawY:int,reclamContainer:Boolean):void{
			var chip:Chip;
			while ( con.numChildren != 0){
				chip = con.removeChildAt(0) as Chip;
				PoolMgr.reclaim(chip);
			}
			if ( !reclamContainer){
				con.x = 114;
				con.y = 96;
			}else{
				if ( con.parent ){
					con.parent.removeChild(con);
				}
				PoolMgr.reclaim(con);
			}
			
		}
		
		public function reset():void 
		{
			var poker:Poker;
			var num:int = poker_con.numChildren - 1;
			while ( num >= 0){
				poker = poker_con.getChildAt(num) as Poker;
				//poker.rotation = 0;//disapear tween
				//PoolMgr.reclaim(poker);
				poker.autoHide();
				num--;
			}
			
			var chip:Chip;
			while ( chips_con.numChildren != 0){
				chip = chips_con.removeChildAt(0) as Chip;
				PoolMgr.reclaim(chip);
			}
			
			while ( chips_con.numChildren != 0){
				chip = chips_con.removeChildAt(0) as Chip;
				PoolMgr.reclaim(chip);
			}
			btn_insurrance.visible = btn_split.visible = mark_blackjack.visible = point_display.visible = bet_display.visible = false;
			this.visible = id <= 3;
		}
		
		public function set selected(val:Boolean):void{
			_selected = val;
			this.chips_con.visible = !val;
			if ( val ){
				this.btn_split.visible = tableData.canSplit;
				TweenLite.to(poker_con, 0.2, {scale:1, ease:Bounce.easeInOut});
				Buttons.Instance.switchModel(Buttons.MODEL_NORMAL);
				this.poker_con.filters = [PokerGameVars.Drop_Shadow_Filter_LONGWAY];
				SoundMgr.Instance.playEffect( SoundsEnum.SELECT_UP);
			}else{
				this.btn_split.visible = false;
				TweenLite.to(poker_con, 0.2, {scale:0.8, ease:Bounce.easeInOut}); 
				Buttons.Instance.hideAll();
				this.poker_con.filters = [];
				SoundMgr.Instance.playEffect( SoundsEnum.SELECT_DOWN);
			}
			
			if ( id > 3 ){
				FrameMgr.Instance.add(this.frameItem);
			}
		}
		
		public function get selected():Boolean{
			return _selected;
		}
		
		private var _referChipPos:Point;
		public function getChipReferPoint():Point{
			if ( _referChipPos == null ){
				_referChipPos = this.chips_con.localToGlobal(GameVars.Raw_Point);
			}
			return _referChipPos;
		}
	}

}