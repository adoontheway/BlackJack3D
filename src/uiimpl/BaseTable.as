package uiimpl 
{
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	import comman.duke.FloatHint;
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
	import utils.NumDisplay;
	import utils.TableUtil;
	
	/**
	 * ...
	 * @author jerry.d
	 */
	public class BaseTable extends TableRightUI  
	{
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
				this.table.skin = "png.images.btn_table_middle";
				this.pair.skin = "png.images.btn_pair_center";
			}else if ( $id == 3 ){
				this.x = -85;
				this.y = 295;
				this.table.skin = "png.images.btn_table_left";
				this.pair.skin = "png.images.btn_pair_left";
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
			var tableData:TableData = mgr.getTableDataById(id);
			if ( pair_con.numChildren > 1){
				//todo merge chips
				TableUtil.displayChipsToContainer(tableData.pairBet,pair_con);
			}else{
				var chip:Chip = PoolMgr.gain(Chip);
				chip.value = bet;
				chip.scale = 0.2;
				pair_con.addChild(chip);
				chip.y = 0;
				chip.x = 0;
				chip.mouseChildren = chip.mouseEnabled = false;
				TweenLite.to(chip, 0.2, {scale:1, ease: Back.easeOut}); 
			}
		}
		
		public function onPairResult(gain:int):void{

			var pos:Point = getPairReferPoint();
			NumDisplay.show(gain, pos.x, pos.y);
			
			var chip:Chip;
			var num:int = pair_con.numChildren - 1;
			while ( num >= 0){
				chip = this.pair_con.getChildAt(num) as Chip;
				chip.autoHide(gain < 0 ? 0 : 1);
				num--;
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
			var num:int = pair_con.numChildren - 1;
			while (  num >= 0){
				chip = pair_con.getChildAt(num) as Chip;
				num--;
				chip.autoHide(0);
			}
		}
	}

}