package uiimpl 
{
	import comman.duke.FloatHint;
	import comman.duke.GameUtils;
	import comman.duke.ImageClickCenter;
	import comman.duke.PoolMgr;
	import comman.duke.SoundMgr;
	import consts.SoundsEnum;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import game.ui.mui.ButtonGroupUI;
	import model.ProtocolClientEnum;
	import model.TableData;
	import morn.core.components.Image;
	
	/**
	 * ...
	 * @author jerry.d
	 */
	public class Buttons extends ButtonGroupUI 
	{
		private var mgr:GameMgr;
		private var socketMgr:SocketMgr;
		private static const POS_INFO:Array = [{x:0, y:50}, {x:99, y:25}, {x:198, y: -5}, {x:297, y: -46}];
		private static const BUTTON_INFO:Object = {
			"clean":3,
			"double":0,
			"hit":1,
			"insurrance":3,
			"ok":3,
			"rebet":2,
			"skip":3,
			"split":3,
			"stand":3,
			"start":0,
			"x2":2,
			"repeat":1,
			"dispense":2
		};
		public static const MODEL_START:uint = 1 ;//hit rebet double
		public static const MODEL_INSRRUREABLE:uint = 2;//skip --> table insurrance
		public static const MODEL_INSRRURING:uint = 3;//done 
		public static const MODEL_NORMAL:uint = 4;//hit stand double
		public static const MODEL_END:uint = 5;//hit stand double
		public static const MODEL_CLEAN:uint = 6;//hit stand double
		public static const MODEL_DOUBLE:uint = 7;//hit stand double
		public static const MODEL_HIDE:uint = 0;
		private var models:Array;
		private var buttons:Vector.<BJButton>;
		public function Buttons() 
		{
			super();
			this.x = 650;
			this.y = 515;
			models = [
			0,
			["start", "clean"],
			["skip"],
			["ok"],
			["hit", "stand"],
			["rebet","double", "clean"],//btn_clean clean the table btn_rebet rebet and start
			[ "start", "repeat", "x2", "clean"],
			["hit", "stand","double"],
			];
			
			buttons = new Vector.<BJButton>();
			var button:BJButton;
			var posInfo:Object;
			for (var i:int = 0; i < 4; i++){
				posInfo = POS_INFO[i];
				button = new BJButton();
				button.x = posInfo.x;
				button.y = posInfo.y;
				this.addChild(button);
				buttons.push(button);
				button.addEventListener(MouseEvent.CLICK, onButton);
				ImageClickCenter.Instance.add(button);
			}
			
			mgr = GameMgr.Instance;
			mgr.buttons = this;
			socketMgr = SocketMgr.Instance;
		}
		
		private function onButton(evt:MouseEvent):void{
			if ( mgr.requestedBaneker && mgr.started ) {//已经请求了庄家要牌并且正在游戏中
				Reminder.Instance.show('游戏结算中');
				return;
			}
			var bname:String = evt.target.name;
			mgr.refresh();
			enable(false);
			switch(bname){
				case "start":
					this.start();
					break;
				case "clean":
					this.clean();
					enable(true);
					break;
				case "skip":
					this.skip();
					mgr.unvisAllInsureBtn();
					break;
				case "ok":
					this.ok();
					mgr.unvisAllInsureBtn();
					break;
				case "hit":
					this.hit();
					break;
				case "stand":
					this.stand();
					break;
				case "double":
					this.double();
					break;
				case "rebet":
					this.rebet();
					break;
				case "x2":
					this.x2();
					enable(true);
					break;
				case "repeat":
					this.repeat();
					enable(true);
					break;
			}
		}
		
		private var currentModel:uint = 999;
		public function switchModel(model:uint):void{
			this.currentModel = model;
			this.hideAll();
			if ( model == 0 ) return;
			var btns:Array = this.models[currentModel];
			var len:uint = btns.length;
			var index:uint = 0;
			var pos:Object;
			var bname:String;
			var button:BJButton;
			while (index < len){
				bname = btns[index];
				button = buttons[index];
				button.visible = true;
				button.setup(bname, BUTTON_INFO[bname]);
				index++;
			}
		}

		
		public function hideAll():void{
			var button:BJButton;
			for (var i:int = 0; i < 4; i++){
				button = buttons[i];
				//button.enable = true;
				button.visible = false;
			}
		}
		
		public function enable(value:Boolean):void{
			var button:BJButton;
			for (var i:int = 0; i < 4; i++){
				button = buttons[i];
				button.enable = value;
			}
		}
		
		public function x2():void{
			mgr.x2Bet();
		}
		
		
		public function repeat():void{
			mgr.repeatBet();
		}
		
		public function rebet():void{
			if (  mgr.lastBetData != null){
				betAndStart();
			}else{
				clean();
			}
		}
		
		public function betAndStart(double:Boolean = false):void{
			mgr.reset();
			var betData:Object  = mgr.lastBetData;
			var pairBetData:Object = mgr.lastPairBetData;
			if ( betData == null ){
				enable(true);
				Reminder.Instance.show('无上局下注记录');
				return;
			}
			var chip:Chip;
			var table:TableData;
			for (var i in betData){
				mgr.betToTable(i,!double ? betData[i] : betData[i] * 2);
			}
			if ( pairBetData != null ){
				for ( i in pairBetData){
					mgr.betPair(i,!double ? pairBetData[i] : pairBetData[i] * 2);
				}
			}
			
			start();
		}
		
		public function skip():void{
			if (mgr.getTableDataById(0).insured) return;
			var obj:Object = {};
			obj.wayId = HttpComunicator.INSURE;
			obj.stage = {};
			HttpComunicator.Instance.send(HttpComunicator.INSURE, obj,0);
		}
		
		public function ok():void{
			if (mgr.getTableDataById(0).insured) return;
			mgr.getInsuredTables();
		}
		
		private function start():void{
			var result:Boolean = mgr.start();	
			if ( result ){
				enable(false);
				MainViewImpl.Instance.tween(true);
			}else{
				clean();
				enable(true);
			}
		}
		
		private function hit():void{ 
			if (mgr.currentTable != null && mgr.currentTable.display.btn_split.visible ){
				mgr.currentTable.display.btn_split.visible = false;
			}
			var obj:Object = {};
			obj.wayId = HttpComunicator.HIT;
			obj.stage = {};
			obj.stage[mgr.currentTable.tableId] = [];
			HttpComunicator.Instance.send(HttpComunicator.HIT,obj,mgr.currentTable.tableId);
		}

		private function clean():void{
			mgr.reset();
			MainViewImpl.Instance.tween(false);
			if ( mgr.lastBetData != null ){
				switchModel(MODEL_CLEAN);
			}
		}
		private function double():void{
			if ( mgr.started ){
				//GameUtils.log('double 0 : ',mgr.started,mgr.currentTable)
				if ( mgr.currentTable == null) return;
				
				if (mgr.currentTable.display.btn_split.visible ){
					mgr.currentTable.display.btn_split.visible = false;
				}
			
				if ( mgr.currentTable.currentBet > mgr.money){
					Reminder.Instance.show("当前余额不足，不能加倍");
					enable(true);
					return;
				}
				var obj:Object = {};
				obj.wayId = HttpComunicator.DOUBLE;
				obj.stage = {};
				obj.stage[mgr.currentTable.tableId] = {};
				obj.stage[mgr.currentTable.tableId][HttpComunicator.DOUBLE] = mgr.currentTable.currentBet*2;
				HttpComunicator.Instance.send(HttpComunicator.DOUBLE, obj, mgr.currentTable.tableId);
			}else{
				betAndStart(true);
			}
		}
		
		private function stand():void{
			if (mgr.currentTable.display.btn_split.visible ){
				mgr.currentTable.display.btn_split.visible = false;
			}
			var obj:Object = {};
			obj.wayId = HttpComunicator.STOP;
			obj.stage = {};
			obj.stage[mgr.currentTable.tableId] = [];
			HttpComunicator.Instance.send(HttpComunicator.STOP, obj,mgr.currentTable.tableId);
		}
		
		private static var _instance:Buttons;
		public static function get Instance():Buttons{
			if ( Buttons._instance == null){
				Buttons._instance = new Buttons();
			}
			return Buttons._instance;
		}
		
	}

}