package uiimpl 
{
	import com.greensock.TweenLite;
	import comman.duke.GameVars;
	import comman.duke.PoolMgr;
	import consts.PokerGameVars;
	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import game.ui.mui.TableRightUI;
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
		}
		
		private function betTable(evt:MouseEvent):void{
			MainViewImpl.Instance.betTable(this);
		}
		
		private function betPair(evt:MouseEvent):void{
			MainViewImpl.Instance.betPair(this);
		}
		
		public function get id():int{
			return _id;
		}
		
		private var tweening:Boolean = false;
		private var tweenQueue:Array = [];
		/* INTERFACE ITable */
		
		public function addCardTo(poker:Poker, con:int=0):void 
		{
			if ( con == 0 ){
				tableData.addCard(poker);
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
							this.lab_points.text =  tableData.points+"/"+(tableData.points+10);
						}
						
					}else{
						this.img_points_bg.url = 'png.images.blackjack';
						this.lab_points.text =  "21";
					}
				}else{
					this.img_points_bg.url = 'png.images.bust';
					this.lab_points.text = tableData.points + "";
				}
				this.point_display.visible = true;
				this.btn_split.visible = tableData.canSplit;
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
				var startPos:Point = this.globalToLocal( PokerGameVars.DispensePostion);
				poker.x = startPos.x;
				poker.y = startPos.y;
				poker.targetX = poker_con_1.x+poker_con_1.numChildren*20;
				poker.targetY = poker_con_1.y;
				tweening = true;
				TweenLite.to(poker, 0.5, {x:poker.targetX, y:poker.targetY, onComplete:this.reOrderContainer1});
			}else if ( con == 1){
				this.poker_con_2.addChild(poker);
				poker.x = PokerGameVars.DispensePostion.x;
				poker.y = PokerGameVars.DispensePostion.y;
				poker.targetX = poker_con_2.x;
				poker.targetY = poker_con_2.y;
				tweening = true;
				TweenLite.to(poker, 0.5, {x:poker.targetX, y:poker.targetY, onComplete:this.reorderContainer2});
			}
		}
		
		private function reOrderContainer1():void{
			tweening = false;
			if ( this.tweenQueue.length){
				var temp:Poker = this.tweenQueue.shift();
				var con:int = this.tweenQueue.shift();
				this.doTween(temp,con);
			}else{
				TableUtil.reOrderContainer(poker_con_1, 0, 280, 250);
			}
		}
		
		private function reorderContainer2():void{
			if ( this.tweenQueue.length){
				var temp:Poker = this.tweenQueue.shift();
				var con:int = this.tweenQueue.shift();
				this.doTween(temp,con);
			}else{
				TableUtil.reOrderContainer(poker_con_2, 0, 200, 250);
			}
		}
		
		public function addChip(chip:Chip, type:int):void{
			var con:Box = type == 0 ? this.chips_con : this.pair_con;
			chip.y = con.numChildren * -8;
			chip.x = 0;
			con.addChild(chip);
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
		}
		
		public function update():void 
		{
			
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