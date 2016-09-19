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
	import comman.duke.SoundMgr;
	import consts.PokerGameVars;
	import consts.SoundsEnum;
	import flash.display.BlendMode;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.system.ApplicationDomain;
	import game.ui.mui.TableRightUI;
	import model.ProtocolClientEnum;
	import model.TableData;
	import morn.core.components.Box;
	import comman.duke.NumDisplay;
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
		private var reminder:MovieClip;
		
		public function BaseTable($id:int) 
		{
			super();
			this.id = $id;
			var claz:Class;
			if ( $id == 1 ){
				this.x = 1220;
				this.y = 330;
				//claz = ApplicationDomain.currentDomain.getDefinition('RightRing') as Class;
			}else if ( $id == 2 ){
				this.x = 875;
				this.y = 375;
				this.table.skin = "png.images.btn_table_middle";
				this.pair.skin = "png.images.btn_pair_center";
				//claz = ApplicationDomain.currentDomain.getDefinition('CenterRing') as Class;
			}else if ( $id == 3 ){
				this.x = 520;
				this.y = 330;
				this.table.skin = "png.images.btn_table_left";
				this.pair.skin = "png.images.btn_pair_left";
				//claz = ApplicationDomain.currentDomain.getDefinition('LeftRing') as Class;
			}
			/*
			if ( claz != null ){
				reminder = new claz() as MovieClip;
				reminder.x = 110;
				reminder.y = 110;
				reminder.mouseChildren = reminder.mouseEnabled = false;
				this.addChild(reminder);
			}
			*/
			
			this.name = 'table_' + $id;
			mgr = GameMgr.Instance;
			
			table.addEventListener(MouseEvent.CLICK, this.betTable);
			pair.addEventListener(MouseEvent.CLICK, this.betPair);
			pair_bet_display.bet_bg.sizeGrid = '20,18,22,20,1';
			pair_bet_display.visible = false;
			pair_bet_display.btn_close.addEventListener(MouseEvent.CLICK, this.cleanPairBet);
			mgr.registerTableDisplay(id, this);
			
			this.addChild(new SubTable(this.id + 3));
			this.addChild(new SubTable(this.id));
			pair_con.filters = [PokerGameVars.Drop_Shadow_Filter_SHORTWAY];
		}
		/**
		public function showReminder(flag:Boolean):void{
			if ( reminder == null ) return;
			if ( flag && !this.contains(this.reminder)){
				this.addChild(this.reminder);
			}else if(!flag && this.contains(this.reminder)){
				this.removeChild(this.reminder);
			}
		}
		*/
		
		private function cleanPairBet(evt:MouseEvent):void{
			if ( !mgr.started && !mgr.starting && !HttpComunicator.lock){
				reset(true);//remove pair chips
				var tableData:TableData = mgr.getTableDataById(id);
				tableData.pairBet = 0;
			}
		}
		
		private function betTable(evt:MouseEvent):void{
			mgr.refresh();
			mgr.betToTable(id,0,true);
		}
		
		private function betPair(evt:MouseEvent):void{
			mgr.refresh();
			mgr.betPair(id);
		}
		
		public function addPairBet(bet:int):void{
			var tableData:TableData = mgr.getTableDataById(id);
			SoundMgr.Instance.playEffect(SoundsEnum.CHIP_DOWN);
			TableUtil.displayChipsToContainer(tableData.pairBet, pair_con);
			updateBetinfo();
		}
		
		public function updateBetinfo():void{
			var tableData:TableData = mgr.getTableDataById(id);
			this.pair_bet_display.visible = true;
			this.pair_bet_display.lab.text = GameUtils.NumberToString(tableData.pairBet,',', 0);
			this.pair_bet_display.lab.width = this.pair_bet_display.lab.textField.textWidth + 10;
			this.pair_bet_display.bet_bg.width =  15 + this.pair_bet_display.lab.width;
			this.pair_bet_display.btn_close.x = this.pair_bet_display.bet_bg.width - 12;
		}
		
		public function onPairResult(gain:int):void{
			var pos:Point = getPairReferPoint();
			comman.duke.NumDisplay.show(gain, pos.x, pos.y);
			
			var chip:Chip;
			var num:int = pair_con.numChildren - 1;
			while ( num >= 0){
				chip = this.pair_con.getChildAt(num) as Chip;
				chip.autoHide(gain == 0 ? 0 : 1);
				num--;
			}
			this.pair_bet_display.visible = false;
		}
		
		private var _referPairPos:Point;
		public function getPairReferPoint():Point{
			if ( _referPairPos == null ){
				_referPairPos = this.localToGlobal(new Point(222,22));
			}
			return _referPairPos;
		}
		
		public function reset(force:Boolean=false):void 
		{
			var chip:Chip;
			
			if (!force){
				var num:int = pair_con.numChildren - 1;
				while (  num >= 0){
					chip = pair_con.getChildAt(num) as Chip;
					num--;
					chip.autoHide(0);
				}
			}else{
				while ( pair_con.numChildren != 0 ){
					chip = pair_con.removeChildAt(0) as Chip;
					PoolMgr.reclaim(chip);
				}
			}
			this.pair_bet_display.visible = false;
			
		}
	}

}