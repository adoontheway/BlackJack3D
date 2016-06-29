package uiimpl 
{
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	import comman.duke.GameUtils;
	import comman.duke.GameVars;
	import comman.duke.PoolMgr;
	import consts.PokerGameVars;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import game.ui.mui.TableRightUI;
	import model.ProtocolClientEnum;
	import model.TableData;
	import morn.core.components.Box;
	import utils.TableUtil;
	
	/**
	 * ...
	 * @author jerry.d
	 */
	public class BaseTable extends TableRightUI  
	{
		public var tableData:TableData;
		public var splitTableData:TableData;
		public var _id:int = -1;
		
		public function BaseTable($id:int) 
		{
			super();
			this._id = $id;
			if ( $id == 1 ){
				this.x = 625;
				this.y = 290;
			}else if ( $id == 2 ){
				this.x = 270;
				this.y = 355;
				this.table.skin = "png.ui.btn_table_middle";
				this.pair.skin = "png.ui.btn_pair_center";
			}else if ( $id == 3 ){
				this.x = -85;
				this.y = 295;
				this.table.skin = "png.ui.btn_table_left";
				this.pair.skin = "png.ui.btn_pair_left";
			}
			
			this.name = 'table_' + $id;
			btn_insurrance.visible = btn_split.visible = mark_blackjack.visible = point_display.visible = bet_display.visible = false;
			GameMgr.Instance.registerTableDisplay(_id, this);
			table.addEventListener(MouseEvent.CLICK, this.betTable);
			pair.addEventListener(MouseEvent.CLICK, this.betPair);
			btn_insurrance.addEventListener(MouseEvent.CLICK, this.insurrance);
			btn_split.addEventListener(MouseEvent.CLICK, this.split);
			this.bet_display.btn_close.addEventListener(MouseEvent.CLICK, onCloseBets);
		}
		
		private function split(evt:MouseEvent):void{
			SocketMgr.Instance.send({proto:ProtocolClientEnum.PROTO_SPLIT, tabId:_id});
		}
		
		private function insurrance(evt:MouseEvent):void{
			SocketMgr.Instance.send({proto:ProtocolClientEnum.PROTO_INSURRANCE, tabId:_id});
		}
		
		private function onCloseBets(evt:MouseEvent):void{
			this.bet_display.visible = false;
		}
		
		private function betTable(evt:MouseEvent):void{
			var bet:int = ChipsViewUIImpl.Instance.currentValue;
			if ( bet != 0 ){
				var chip:Chip = PoolMgr.gain(Chip);
				chip.value = bet;
				addChip(chip, 0);
				GameMgr.Instance.betToTable(bet, _id);
				this.bet_display.visible = true;
				this.bet_display.lab.text = GameUtils.NumberToString(tableData.currentBet);
				this.tabelRemind(false);
			}
		}
		
		private function betPair(evt:MouseEvent):void{
			var bet:int = ChipsViewUIImpl.Instance.currentValue;
			if ( bet != 0 ){
				var result:Boolean = GameMgr.Instance.betPair(bet, _id);
				if ( result){
					var chip:Chip = PoolMgr.gain(Chip);
					chip.value = bet;
					addChip(chip, 1);
				}else{
					this.tabelRemind(true);
				}
			}
		}
		
		public function get id():int{
			return _id;
		}
		
		private var tweening:Boolean = false;
		private var tweenQueue:Array = [];
		public function addCardTo(poker:Poker, con:int=0):void 
		{
			if ( con == 0 ){
				tableData.addCard(poker);
				this.lab_points.size = 30;
				if ( !tableData.bust ){
					if ( !tableData.blackjack){
						if ( !tableData.hasA || (tableData.hasA && tableData.points > 11) ){
							if (tableData.points < 21 ){
								this.img_points_bg.url = 'png.images.green';
								this.lab_points.text =  tableData.points+"";
							}else{
								this.img_points_bg.url = 'png.images.full';
								this.lab_points.text =  tableData.points+"";
							}
						}else{
							this.img_points_bg.url = 'png.images.soft';
							this.lab_points.size = 20;
							this.lab_points.text =  tableData.points+"/"+(tableData.points+10);
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
				this.btn_split.visible = tableData.canSplit;
				mark_blackjack.visible = tableData.blackjack;
			}else if ( con == 1){
				splitTableData.addCard(poker);
			}
			
			if ( this.tweening ){
				this.tweenQueue.push( poker,con);
				return;
			}
			doTween(poker, con);
		}
		
		private function doTween(poker:Poker, con:int=0):void{
			if ( con == 0 ){
				this.poker_con_1.addChild(poker);
				poker.targetX = poker_con_1.x+poker_con_1.numChildren*20;
				poker.targetY = poker_con_1.y;
			}else if ( con == 1){
				this.poker_con_2.addChild(poker);
				poker.targetX = poker_con_2.x;
				poker.targetY = poker_con_2.y;
			}
			var startPos:Point = this.globalToLocal( PokerGameVars.DispensePostion);
			poker.x = startPos.x;
			poker.y = startPos.y;
			tweening = true;
			TweenLite.to(poker, 0.5, {x:poker.targetX, rotationX:0,y:poker.targetY, onComplete:this.onTweenComplete,onCompleteParams:[con == 0 ? poker_con_1 : poker_con_2]});
		}
		
		private function onTweenComplete(con:Sprite):void{
			tweening = false;
			if ( this.tweenQueue.length != 0){
				var temp:Poker = this.tweenQueue.shift();
				var type:int = this.tweenQueue.shift();
				this.doTween(temp,type);
			}else{
				TableUtil.reOrderContainer(con, 0, 200, 200);
			}
		}
		
		public function addChip(chip:Chip, type:int):void{
			var con:Box = type == 0 ? this.chips_con : this.pair_con;
			chip.y = con.numChildren * -8;
			chip.x = 0;
			chip.scaleX = chip.scaleY = 0.5;
			con.addChild(chip);
			TweenLite.to(chip, 0.4, {scaleX:1, scaleY:1, ease: Back.easeOut});
		}
		private var _referChipPos:Point;
		public function getChipReferPoint():Point{
			if ( _referChipPos == null ){
				_referChipPos = this.chips_con.localToGlobal(GameVars.Raw_Point);
			}
			return _referChipPos;
		}
		
		private var _referPairPos:Point;
		public function getPairReferPoint():Point{
			if ( _referPairPos == null ){
				_referPairPos = this.localToGlobal(new Point(222,22));
			}
			return _referPairPos;
		}
		public function reset():void 
		{
			if( tableData != null)
				tableData.reset();
			if( splitTableData != null)
				splitTableData.reset();
			var poker:Poker;
			while ( poker_con_1.numChildren != 0){
				poker = poker_con_1.removeChildAt(0) as Poker;
				poker.rotation = 0;
				PoolMgr.reclaim(poker);
			}
			while ( poker_con_2.numChildren != 0){
				poker = poker_con_2.removeChildAt(0) as Poker;
				poker.rotation = 0;
				PoolMgr.reclaim(poker);
			}
			
			var chip:Chip;
			while ( chips_con.numChildren != 0){
				chip = chips_con.removeChildAt(0) as Chip;
				PoolMgr.reclaim(chip);
			}
			while ( pair_con.numChildren != 0){
				chip = pair_con.removeChildAt(0) as Chip;
				PoolMgr.reclaim(chip);
			}
			btn_insurrance.visible = btn_split.visible = mark_blackjack.visible = point_display.visible = bet_display.visible = false;
			tweening = false;
		}
		
		public function tabelRemind(bool:Boolean):void 
		{
			if ( bool ){
				table.filters = [PokerGameVars.Glow_Filter];
			}else if(table.filters.length != 0){
				table.filters = [];
			}
		}
		
		public function setTableData(tableData:TableData, isMain:Boolean):void 
		{
			if ( isMain ){
				this.tableData = tableData;
			}else{
				this.splitTableData = tableData;
			}
		}
		
	}

}