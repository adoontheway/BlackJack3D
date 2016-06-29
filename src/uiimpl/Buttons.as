package uiimpl 
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import game.ui.mui.ButtonGroupUI;
	import model.ProtocolClientEnum;
	
	/**
	 * ...
	 * @author jerry.d
	 */
	public class Buttons extends ButtonGroupUI 
	{
		private var mgr:GameMgr;
		private var socketMgr:SocketMgr;
		private var poses:Array = [{x:0, y:47}, {x:107, y:25}, {x:213, y: -7}, {x:320, y: -54}];
		public static const MODEL_START:uint = 1 ;//hit rebet double
		public static const MODEL_INSRRURE:uint = 2;//skip --> table insurrance
		public static const MODEL_INSRRURE_COMPLETE:uint = 3;//done 
		public static const MODEL_NORMAL:uint = 4;//hit stand double
		public static const MODEL_HIDE:uint = 0;
		private var models:Array;
		public function Buttons() 
		{
			super();
			this.x = 640;
			this.y = 515;
			this.btn_double.addEventListener(MouseEvent.CLICK, this.double);
			this.btn_hit.addEventListener(MouseEvent.CLICK, this.hit);
			this.btn_stand.addEventListener(MouseEvent.CLICK, this.stand);
			this.btn_rebet.addEventListener(MouseEvent.CLICK, this.rebet);
			models = [
			0,
			[btn_hit, btn_rebet, btn_double],
			['btn_skip'],
			['btn_done'],
			[btn_hit, btn_double, btn_stand]
			];
			mgr = GameMgr.Instance;
			socketMgr = SocketMgr.Instance;
			hideAll();
		}
		private var currentModel:uint = 999;
		public function switchModel(model:uint):void{
			if ( currentModel == model) return;
			this.currentModel = model;
			this.hideAll();
			if ( model == 0 ) return;
			var btns:Array = this.models[model];
			var len:uint = btns.length;
			var index:uint = 0;
			var pos:Object;
			var button:DisplayObject;
			while (index < len){
				button = btns[index];
				pos = poses[index];
				button.visible = true;
				button.x = pos.x;
				button.y = pos.y;
				index++;
			}
		}
		
		public function hideAll():void{
			this.btn_double.visible = this.btn_hit.visible = this.btn_rebet.visible = this.btn_stand.visible = false;
		}
		
		private function hit(evt:MouseEvent):void{ 
			if (mgr.started){
				socketMgr.send({proto:ProtocolClientEnum.PROTO_HIT,  tabId:mgr.currentTable.tableId});
			}else{
				var result:Boolean = mgr.start();	
				if ( !result ){
					
				}
			}
		}

		private function rebet(evt:MouseEvent):void{
			//this.hideAllBtns();
			mgr.cleanTables();
		}
		private function double(evt:MouseEvent):void{
			//this.hideAllBtns();
			socketMgr.send({proto:ProtocolClientEnum.PROTO_DOUBLE, tabId:mgr.currentTable.tableId});
		}
		private function stand(evt:MouseEvent):void{
			//this.hideAllBtns();
			if( mgr.started && mgr.currentTable)
				socketMgr.send({proto:ProtocolClientEnum.PROTO_STAND, tabId:mgr.currentTable.tableId});
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