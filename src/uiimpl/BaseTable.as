package uiimpl 
{
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	import comman.duke.FrameItem;
	import comman.duke.FrameMgr;
	import comman.duke.GameUtils;
	import comman.duke.GameVars;
	import comman.duke.ImageClickCenter;
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
		public var id:int = -1;
		//private var frameItem:FrameItem;
		private var mgr:GameMgr;
		public function BaseTable($id:int) 
		{
			super();
			this.id = $id;
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
			mgr = GameMgr.Instance;
			
			table.addEventListener(MouseEvent.CLICK, this.betTable);
			pair.addEventListener(MouseEvent.CLICK, this.betPair);
			
			mgr.registerTableDisplay(id, this);
			
			this.addChild(new SubTable(this.id + 3));
			this.addChild(new SubTable(this.id));
		}
		
		private function betTable(evt:MouseEvent):void{
			mgr.betToTable(id);
		}
		
		private function betPair(evt:MouseEvent):void{
			mgr.betPair(id);
		}
		
		public function addPairBet(bet:int):void{
			var chip:Chip = PoolMgr.gain(Chip);
			chip.y = pair_con.numChildren * -8;
			chip.x = 0;
			chip.value = bet;
			chip.scaleX = chip.scaleY = 0.5;
			pair_con.addChild(chip);
			TweenLite.to(chip, 0.4, {scaleX:1, scaleY:1, ease: Back.easeOut});
			if ( pair_con.numChildren > 1){
				//todo merge chips
			}
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
			var chip:Chip;
			while ( pair_con.numChildren != 0){
				chip = pair_con.removeChildAt(0) as Chip;
				PoolMgr.reclaim(chip);
			}
		}
	}

}