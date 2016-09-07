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
	import flash.geom.Rectangle;
	import flash.utils.setTimeout;
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
		private var dispenseTime:Number = 0.4;
		
		public function SubTable($id:int) 
		{
			super();
			this.id = $id;
			this.x = $id <= 3 ? 35 : 65;
			this.y = $id <= 3 ? 40 : -20;
			if ( $id % 3 == 2){
				dispenseTime = 0.5;
				middleOffsetX = -90;
				middleOffsetY = 40;
			}else if ( $id % 3 == 0 ){
				dispenseTime = 0.6;
				middleOffsetX = -180;
				middleOffsetY = 60;
			}
			this.visible = $id <= 3;
			this.poker_con.scale = 0.8;
			this.name = 'subtable' + $id;
			
			this.img_result_0.mask = this.img_result_1;
			this.bet_display.bet_bg.sizeGrid = '20,18,22,20,1';
			
			btn_insurrance.visible = btn_split.visible = mark_blackjack.visible = point_display.visible = bet_display.visible = false;
			btn_insurrance.addEventListener(MouseEvent.CLICK, this.insurrance);
			btn_split.addEventListener(MouseEvent.CLICK, this.split);
			this.bet_display.btn_close.addEventListener(MouseEvent.CLICK, onCloseBets);
			
			this.frameItem = new FrameItem(this.name, this.update);
			
			mgr = GameMgr.Instance;
			this.lab_points.text = "";
			mgr.registerSubTableDisplay( $id, this);
			ImageClickCenter.Instance.add(this.btn_insurrance);
			ImageClickCenter.Instance.add(this.btn_split);
			insure_con.filters = chips_con.filters = [PokerGameVars.Drop_Shadow_Filter_SHORTWAY];
			//GameUtils.log('SubTable init : '+this.name);
		}
		
		public function showBet():void{
			SoundMgr.Instance.playEffect(SoundsEnum.CHIP_DOWN);
			TableUtil.displayChipsToContainer(tableData.currentBet, chips_con);
			this.updateBetinfo();
		}
		
		public function addCard(poker:Poker,needTween:Boolean=true):void 
		{
			tableData.addCard(poker);
			updatePoints();
			mark_blackjack.visible = tableData.blackjack;
			bet_display.visible = false;
			if( needTween )
				doTween(poker);
		}
		
		
		
		private var dispenseStartPoint:Point;
		private function doTween(poker:Poker):void{
			GameVars.STAGE.addChild(poker);
			poker.x = PokerGameVars.DispensePostion.x;
			poker.y = PokerGameVars.DispensePostion.y;
			/**
			GameVars.Raw_Point.x = (poker_con.numChildren+1) * 20;
			GameVars.Raw_Point.y = 0;
			
			var targetPos:Point = poker_con.localToGlobal(GameVars.Raw_Point);
			poker.targetX = targetPos.x;
			poker.targetY = targetPos.y;
			*/
			
			if ( dispenseStartPoint == null ){
				dispenseStartPoint = this.poker_con.globalToLocal( PokerGameVars.DispensePostion); 
				dispenseMiddlePoint = this.poker_con.globalToLocal(PokerGameVars.DispenseMiddlePostion);
			}
			/**
			this.poker_con.addChild(poker);
			poker.targetX = poker_con.numChildren*20;
			poker.targetY = 0;
			
			if ( dispenseStartPoint == null ){
				dispenseStartPoint = this.poker_con.globalToLocal( PokerGameVars.DispensePostion); 
				dispenseMiddlePoint = this.poker_con.globalToLocal(PokerGameVars.DispenseMiddlePostion);
			}
			
			poker.x = dispenseStartPoint.x;
			poker.y = dispenseStartPoint.y;
			*/
			SoundMgr.Instance.playEffect( SoundsEnum.CARD );
			tweenPhase1(poker);
			//TweenLite.to(poker, this.dispenseTime, {x:poker.targetX, rotationY:0,rotation:0,y:poker.targetY, onComplete:this.onTweenComplete});
		}
		
		private var dispenseMiddlePoint:Point;
		private var middleOffsetX:int = -30;
		private var middleOffsetY:int = -10;
		private function tweenPhase1(poker:Poker):void{
			poker.scale = 0.8;
			TweenLite.to(poker, 0.2, {scale:1, x:PokerGameVars.DispenseMiddlePostion.x, y:PokerGameVars.DispenseMiddlePostion.y, onComplete:tweenPhase2,onCompleteParams:[poker]});
			/**
			if( _selected ){
				TweenLite.to(poker, 0.2, {scale:1, x:PokerGameVars.DispenseMiddlePostion.x, y:PokerGameVars.DispenseMiddlePostion.y, onComplete:tweenPhase2,onCompleteParams:[poker]});
			}else{//未选中的桌子的scale是0.8
				TweenLite.to(poker, 0.2, {x:PokerGameVars.DispenseMiddlePostion.x, y:PokerGameVars.DispenseMiddlePostion.y, onComplete:tweenPhase2,onCompleteParams:[poker]});
			}
			/**
			TweenLite.to(poker, 0.2, {scale:1, x:dispenseMiddlePoint.x, y:dispenseMiddlePoint.y, onComplete:tweenPhase2,onCompleteParams:[poker]});
			*/
		}
		
		private function tweenPhase2(poker:Poker):void{
			poker_con.addChild(poker);
			poker.targetX = poker_con.numChildren*20;
			poker.targetY = 0;
			poker.scale = 1;
			poker.x = dispenseMiddlePoint.x + (_selected ? middleOffsetX : 0);
			poker.y = dispenseMiddlePoint.y + (_selected ? middleOffsetY : 0);
			TweenLite.to(poker, dispenseTime, {x:poker.targetX, rotationY:0,rotation:0,y:poker.targetY, onComplete:onTweenComplete});
		}
		
		private function onTweenComplete():void{
			TableUtil.reOrderContainer(poker_con, 0, 200, 200);
			mgr.dispenseComplete(id);
			if ( mgr.dispenseQueue.length == 0 && this._selected){
				readPoints();
			}
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
			this.bet_display.lab.width = this.bet_display.lab.textField.textWidth + 10;
			this.bet_display.bet_bg.width =  15 + this.bet_display.lab.width;
			this.bet_display.btn_close.x = this.bet_display.bet_bg.width - 12;
		}
		
		public function updatePoints(isSettled:Boolean = false):void{
			this.soft_gro.visible = false;
			this.lab_points.visible = true;
			if ( !tableData.bust ){
				if ( !tableData.blackjack){
					if ( tableData.numA <= 0 || (tableData.numA > 0 && tableData.points >= 11) ){
						this.img_points_bg.url = 'png.images.green';
						if (tableData.points < 21 ){
							this.lab_points.text =  tableData.points+"";
						}else{
							this.lab_points.text =  tableData.points+"";
						}
					}else{
						if ( isSettled || !tableData.actived ){
							this.img_points_bg.url = 'png.images.green';
							this.lab_points.text =  (tableData.points + 10) + "";
						}else{
							this.lab_points.visible = false;
							this.soft_gro.visible = true;
							this.img_points_bg.url = 'png.images.soft';
							this.soft_0.text =  tableData.points +"";
							this.soft_2.text =  (tableData.points + 10 )+ "";
						}
					}
					
				}else{
					this.img_points_bg.url = 'png.images.full';
					this.lab_points.text =  "21";
				}
			}else{
				this.img_points_bg.url = 'png.images.bust';
				this.lab_points.text = tableData.points + "";
			}
			this.point_display.visible = true;
		}
		
		public function onInsureBack(bet:int):void{
			//GameUtils.log('Subtable.onInsureBack : ',id," -->",bet);
			var value:uint = bet > 0 ? bet : -bet;			
			var targetPos:Point;
			if ( bet > 0 ){
				var sp:Sprite = TableUtil.getChipStack(value);
				var pos:Point = this.globalToLocal(PokerGameVars.ChipLostPos);
				sp.x = pos.x;
				sp.y = pos.y;
				this.addChild(sp);
				TweenLite.to(sp, 0.8, {x:50, y:50, onComplete:onGainSure, onCompleteParams:[sp]});
			}else{
				//GameUtils.log('Subtable.onInsureBack(insure_con) : ',id," -->",bet);
				removeAllBet(-1, insure_con,79,116);
			}

		}
		
		private function onGainSure(sp:Sprite):void{
			//GameUtils.log('Subtable.onInsureBack(insure_con): ',id);
			removeAllBet(1, insure_con, 79, 116);
			//GameUtils.log('Subtable.removeAllBet(sp): ',id);
			removeAllBet(1, sp,0,0,true);
		}
		
		private function onChipComplete(chip:Chip):void{
			chip.parent.removeChild(chip);
			PoolMgr.reclaim(chip);
		}
		
		private function split(evt:MouseEvent):void{ 
			if ( mgr.money < tableData.currentBet){
				Reminder.Instance.show("当前余额不足，不能分牌");
				Buttons.Instance.enable(true);
				return;
			}
			if ( mgr.requestedBaneker && mgr.started ) {
				Reminder.Instance.show('游戏结算中');
				return;
			}
			this.btn_split.visible = false;
			var obj:Object = {};
			obj.wayId = HttpComunicator.SPLIT;
			obj.stage = {};
			obj.stage[id] = {};
			obj.stage[id][HttpComunicator.SPLIT] = this.tableData.currentBet;
			HttpComunicator.Instance.send(HttpComunicator.SPLIT, obj, id);
			Buttons.Instance.enable(false);
		}
		
		private function insurrance(evt:MouseEvent):void{
			if ( PokerGameVars.TempInsureCost + tableData.currentBet * 0.5 > mgr.money){
				Reminder.Instance.show("当前余额不足，不能保险");
				return;
			}
			if ( mgr.requestedBaneker && mgr.started ) {
				Reminder.Instance.show('游戏结算中');
				return;
			}
			PokerGameVars.TempInsureCost += tableData.currentBet * 0.5
			tableData.insured = true;
			TableUtil.displayChipsToContainer(tableData.currentBet*0.5, this.insure_con);
			this.btn_insurrance.visible = false;
			Buttons.Instance.switchModel(Buttons.MODEL_INSRRURING);
		}
		
		private function onCloseBets(evt:MouseEvent):void{
			mgr.resetTable(id);
		}
		
		public function update(delta:int):void{
			if ( _selected && (poker_con.scale > 0.9) ){
				parent.setChildIndex(this,parent.numChildren - 1);
				FrameMgr.Instance.remove(this.name);
				btn_split.visible = tableData.canSplit;
			}else if ( !_selected && (poker_con.scale <= 0.9)){
				parent.setChildIndex(this,parent.numChildren - 2);
				FrameMgr.Instance.remove(this.name);
			}
		}
		
		public function end():void{
			GameUtils.assert(!tableData.actived ,'End Table '+this.id+' --> prize:'+tableData.prize+' bet:'+tableData.currentBet );
			if ( !tableData.actived) return;
			
			var gain:int = tableData.prize - tableData.currentBet ;
			
			var pos:Point = localToGlobal(new Point(40, 10));
			if ( gain < 0){
				comman.duke.NumDisplay.show( gain, pos.x,  pos.y);
				
				setTimeout(function():void{
					removeAllBet( -1, chips_con, 114, 96);
				}, 200);
				
				img_result_0.url = 'png.images.result_lose';
			}else if (gain > 0){
				comman.duke.NumDisplay.show( gain, pos.x, pos.y);
				var sp:Sprite = TableUtil.getChipStack(gain);
				pos = globalToLocal(PokerGameVars.ChipLostPos);
				sp.x = pos.x;
				sp.y = pos.y;
				addChild(sp);
				TweenLite.to(sp, dispenseTime+0.2, {x:50, y:50, onComplete:onGainComplete, onCompleteParams:[sp]});
				if ( !tableData.blackjack){
					img_result_0.url = 'png.images.result_win_1';
				}else{
					img_result_0.url = 'png.images.result_win';
				}
				
			}else{
				comman.duke.NumDisplay.show( 0, pos.x,  pos.y);
				
				setTimeout(function():void{
					removeAllBet(1, chips_con, 114, 96);
				}, 200);
				
				img_result_0.url = 'png.images.result_push';
			}
			bet_display.visible = false;
			showResultLab(true);
			tableData.actived = false;
		}
		
		private function showResultLab(flag:Boolean):void{
			if ( this.img_result_0.x == 165 && flag ){
				TweenLite.to(img_result_0, 0.2, {x:65});
			}else if ( this.img_result_0.x == 65 && !flag){
				TweenLite.to(img_result_0, 0.2, {x:165, onComplete:onFold});
			}
		}
		
		private function onFold():void{
			point_display.visible = false;
		}
		
		private function onGainComplete(sp:Sprite):void{
			removeAllBet(1, chips_con,114,96);
			removeAllBet(1, sp,0,0,true);
			
		}
		
		public function removeAllBet(type:int, con:DisplayObjectContainer, rawX:int, rawY:int, reclamContainer:Boolean = false):void{
			//GameUtils.log('Subtable.removeAllBet(): ',con == null, con.parent == null);
			var point:Point = con.parent.globalToLocal(type == -1 ? PokerGameVars.ChipLostPos : PokerGameVars.ChipGainPos );
			TweenLite.to(con, 1.0, {x:point.x, y:point.y, onComplete:removeAllChip, onCompleteParams:[con,rawX,rawY,reclamContainer]});
		}
		
		public function removeAllChip(con:DisplayObjectContainer,rawX:int,rawY:int,reclamContainer:Boolean):void{
			var chip:Chip;
			while ( con.numChildren != 0){
				chip = con.removeChildAt(0) as Chip;
				PoolMgr.reclaim(chip);
			}
			if ( !reclamContainer){
				con.x = rawX;
				con.y = rawY;
			}else{
				if ( con.parent ){
					con.parent.removeChild(con);
				}
				if( con is Sprite)
					PoolMgr.reclaim(con);
			}
			BalanceImpl.Instance.rockAndRoll();
		}
		
		public function reset():void 
		{
			secondRequest = false;
			var poker:Poker;
			var num:int = poker_con.numChildren - 1;
			while ( num >= 0){
				poker = poker_con.getChildAt(num) as Poker;
				poker.autoHide();
				num--;
			}
			
			var chip:Chip;
			while ( chips_con.numChildren != 0){
				chip = chips_con.removeChildAt(0) as Chip;
				PoolMgr.reclaim(chip);
			}
			
			while ( insure_con.numChildren != 0){
				chip = insure_con.removeChildAt(0) as Chip;
				PoolMgr.reclaim(chip);
			}
			this.lab_points.text =  "";
			btn_insurrance.visible = btn_split.visible = mark_blackjack.visible = bet_display.visible = false;
			this.visible = id <= 3;
			showResultLab(false);
		}
		private var secondRequest:Boolean = false;
		public function set selected(val:Boolean):void{
			var numCards:int = tableData.cards.length;
			if ( _selected == val ){
				if ( val ){
					if (numCards != 2){
						Buttons.Instance.switchModel(Buttons.MODEL_NORMAL);
					}else{
						Buttons.Instance.switchModel(Buttons.MODEL_DOUBLE);
					}
				}
				return;
			}
				
			_selected = val;
			this.chips_con.visible = !val;
			if ( val ){
				GameUtils.log('Check dispense on selected : ', numCards, secondRequest);
				Buttons.Instance.enable(true);
				if ( numCards == 1 && !secondRequest){
					Buttons.Instance.enable(false);
					secondRequest = true;
					var obj:Object = {};
					obj.wayId = HttpComunicator.HIT;
					obj.stage = {};
					obj.stage[id] = [];
					HttpComunicator.Instance.send(HttpComunicator.HIT, obj, id);
				}
				TweenLite.to(poker_con, 0.2, {scale:1.1, ease:Bounce.easeInOut, onComplete:onSelectComplete});
				if (numCards != 2){
					Buttons.Instance.switchModel(Buttons.MODEL_NORMAL);
				}else{
					Buttons.Instance.switchModel(Buttons.MODEL_DOUBLE);
				}
				this.poker_con.filters = [PokerGameVars.Drop_Shadow_Filter_LONGWAY];
			}else{
				this.btn_split.visible = false;
				TweenLite.to(poker_con, 0.2, {scale:0.8, ease:Bounce.easeInOut}); 
				Buttons.Instance.hideAll();
				this.poker_con.filters = [];
			}
			
			if ( id > 3 ){
				FrameMgr.Instance.add(this.frameItem);
			}
		}
		
		private function onSelectComplete():void{
			if ( tableData.cards.length == 1 || mgr.dispenseQueue.length != 0){
				return;
			}
			readPoints();
			this.btn_split.visible = tableData.canSplit;
		}
		
		private function readPoints():void{
			if( tableData.bust){
				SoundMgr.Instance.playVoice(Math.random() > 0.5 ? SoundsEnum.BUST_0 :  SoundsEnum.BUST_1);
			}else if ( tableData.points == 21 || tableData.numA > 0 && tableData.points == 11){
				SoundMgr.Instance.playVoice(Math.random() > 0.5 ? SoundsEnum.POINT_21_0 : SoundsEnum.POINT_21_1);
			}else if ( tableData.numA > 0 && tableData.points <= 11){
				SoundMgr.Instance.playVoice(SoundsEnum['POINT_' + (tableData.points+10)]);
			}else{
				SoundMgr.Instance.playVoice(SoundsEnum['POINT_' + tableData.points]);
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