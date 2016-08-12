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
				this.dispenseTime = 0.5;
			}else if ( $id % 3 == 0 ){
				this.dispenseTime = 0.6;
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
			this.lab_points.text = this.id+"";
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
			this.poker_con.addChild(poker);
			poker.targetX = poker_con.numChildren*20;
			poker.targetY = 0;
			
			if ( dispenseStartPoint == null ){
				dispenseStartPoint = this.globalToLocal( PokerGameVars.DispensePostion); 
			}
			
			poker.x = dispenseStartPoint.x;
			poker.y = dispenseStartPoint.y;
			SoundMgr.Instance.playEffect( SoundsEnum.CARD );
			TweenLite.to(poker, this.dispenseTime, {x:poker.targetX, rotationY:0,rotation:0,y:poker.targetY, onComplete:this.onTweenComplete});
		}
		
		private function onTweenComplete():void{
			TableUtil.reOrderContainer(poker_con, 0, 200, 200);
			mgr.dispenseComplete(id);
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
			//SocketMgr.Instance.send({proto:ProtocolClientEnum.PROTO_SPLIT, tabId:id});
			if ( mgr.money < tableData.currentBet){
				FloatHint.Instance.show("当前余额不足，不能分牌");
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
				FloatHint.Instance.show("当前余额不足，不能保险");
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
				btn_split.visible = !tableData.isSplited && tableData.canSplit;
			}else if ( !_selected && (poker_con.scale <= 0.9)){
				parent.setChildIndex(this,parent.numChildren - 2);
				FrameMgr.Instance.remove(this.name);
			}
		}
		
		public function end():void{
			if ( !tableData.actived && !tableData.blackjack ) return;
			var gain:int = tableData.prize - tableData.currentBet ;
			//GameUtils.log('Check Gain of ', this.id, ' --> ',tableData.prize, tableData.currentBet,tableData.actived);
			var pos:Point = localToGlobal(new Point(40, 10));
			if ( gain < 0){
				comman.duke.NumDisplay.show( gain, pos.x,  pos.y);
				removeAllBet( -1, chips_con, 114, 96);
				img_result_0.url = 'png.images.result_lose';
			}else if (gain > 0){
				comman.duke.NumDisplay.show( gain, pos.x, pos.y);
				var sp:Sprite = TableUtil.getChipStack(gain);
				pos = globalToLocal(PokerGameVars.ChipLostPos);
				sp.x = pos.x;
				sp.y = pos.y;
				addChild(sp);
				TweenLite.to(sp, 0.8, {x:50, y:50, onComplete:onGainComplete, onCompleteParams:[sp]});
				if ( !tableData.blackjack){
					img_result_0.url = 'png.images.result_win_1';
				}else{
					img_result_0.url = 'png.images.result_win';
				}
				
			}else{
				comman.duke.NumDisplay.show( 0, pos.x,  pos.y);
				removeAllBet(1, chips_con, 114, 96);
				img_result_0.url = 'png.images.result_push';
			}
			bet_display.visible = false;
			showResultLab(true);
			tableData.actived = false;
		}
		
		private function showResultLab(flag:Boolean):void{
			if ( this.img_result_0.x == 165 && flag ){
				TweenLite.to(img_result_0, 0.3, {x:65});
			}else if ( this.img_result_0.x == 65 && !flag){
				TweenLite.to(img_result_0, 0.3, {x:165, onComplete:onFold});
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
			_selected = val;
			this.chips_con.visible = !val;
			if ( val ){
				if ( this.tableData.numCards == 1 && !secondRequest){
					secondRequest = true;
					var obj:Object = {};
					obj.wayId = HttpComunicator.HIT;
					obj.stage = {};
					obj.stage[id] = [];
					HttpComunicator.Instance.send(HttpComunicator.HIT, obj, id);
			
					SocketMgr.Instance.send({proto:ProtocolClientEnum.PROTO_HIT,  tabId:id});
				}
				this.btn_split.visible = tableData.canSplit;
				TweenLite.to(poker_con, 0.2, {scale:1.1, ease:Bounce.easeInOut});
				if (tableData.numCards != 2){
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