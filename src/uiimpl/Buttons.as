package uiimpl 
{
	import comman.duke.FloatHint;
	import comman.duke.ImageClickCenter;
	import comman.duke.PoolMgr;
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
		private var poses:Array = [{x:0, y:50}, {x:99, y:25}, {x:198, y: -5}, {x:297, y: -46}];
		public static const MODEL_START:uint = 1 ;//hit rebet double
		public static const MODEL_INSRRUREABLE:uint = 2;//skip --> table insurrance
		public static const MODEL_INSRRURING:uint = 3;//done 
		public static const MODEL_NORMAL:uint = 4;//hit stand double
		public static const MODEL_END:uint = 5;//hit stand double
		public static const MODEL_CLEAN:uint = 6;//hit stand double
		public static const MODEL_HIDE:uint = 0;
		private var models:Array;
		public function Buttons() 
		{
			super();
			this.x = 650;
			this.y = 515;
			this.btn_double.addEventListener(MouseEvent.CLICK, this.double);
			this.btn_hit.addEventListener(MouseEvent.CLICK, this.hit);
			this.btn_stand.addEventListener(MouseEvent.CLICK, this.stand);
			this.btn_rebet.addEventListener(MouseEvent.CLICK, this.rebet);
			this.btn_clean.addEventListener(MouseEvent.CLICK, this.clean);
			this.btn_skip.addEventListener(MouseEvent.CLICK, this.skip);
			this.btn_ok.addEventListener(MouseEvent.CLICK, this.ok);
			models = [
			0,
			[btn_hit, btn_clean],
			[btn_skip],
			[btn_ok],
			[btn_hit, btn_stand,btn_double],
			[btn_rebet,btn_double, btn_clean],//btn_clean clean the table btn_rebet rebet and start
			[btn_rebet, btn_hit, btn_double,btn_clean],
			];
			mgr = GameMgr.Instance;
			socketMgr = SocketMgr.Instance;
		}
		private var currentModel:uint = 999;
		public function switchModel(model:uint):void{
			//if ( currentModel == model) return;
			this.currentModel = model;
			this.hideAll();
			if ( model == 0 ) return;
			var btns:Array = this.models[currentModel];
			var len:uint = btns.length;
			var index:uint = 0;
			var pos:Object;
			var button:Image;
			while (index < len){
				button = btns[index];
				pos = poses[index];
				button.visible = true;
				button.x = pos.x;
				button.y = pos.y;
				index++;
				ImageClickCenter.Instance.add(button);
			}
		}

		
		public function hideAll():void{
			btn_clean.visible = btn_skip.visible = btn_ok.visible = this.btn_double.visible = this.btn_hit.visible = this.btn_rebet.visible = this.btn_stand.visible = false;
			ImageClickCenter.Instance.remove(btn_clean);
			ImageClickCenter.Instance.remove(btn_skip);
			ImageClickCenter.Instance.remove(btn_ok);
			ImageClickCenter.Instance.remove(btn_double);
			ImageClickCenter.Instance.remove(btn_hit);
			ImageClickCenter.Instance.remove(btn_rebet);
			ImageClickCenter.Instance.remove(btn_stand);
		}
		
		public function rebet(evt:MouseEvent):void{
			betAndStart();
		}
		
		public function betAndStart(double:Boolean = false):void{
			hideAll();
			mgr.reset();
			var betData:Object  = mgr.lastBetData;
			var pairBetData:Object = mgr.lastPairBetData;
			if ( betData == null ){
				FloatHint.Instance.show('no bet record');
				return;
			}
			var chip:Chip;
			var table:TableData;
			for (var i in betData){
				mgr.betToTable(i,!double ? betData[i] : betData[i] * 2);
			}
			if ( pairBetData != null ){
				for ( i in pairBetData){
					mgr.betPair(i,!double ? betData[i] : betData[i] * 2);
				}
			}
			
			mgr.start();
			/**
			if (mgr.lastPairBetData == null){
				socketMgr.send({proto:ProtocolClientEnum.PROTO_START, bet:mgr.lastBetData });
			}else{
				socketMgr.send({proto:ProtocolClientEnum.PROTO_START, bet:mgr.lastBetData, pair:mgr.lastPairBetData });
			}
			*/
		}
		
		public function skip(evt:MouseEvent):void{
			socketMgr.send({proto:ProtocolClientEnum.PROTO_SKIP_INSURRANCE});
		}
		
		public function ok(evt:MouseEvent):void{
			this.hideAll();
			var tables:Array = mgr.getInsuredTables();
			if ( tables.length > 0){
				SocketMgr.Instance.send({proto:ProtocolClientEnum.PROTO_INSURRANCE, tables:tables});
			}else{
				SocketMgr.Instance.send({proto:ProtocolClientEnum.PROTO_SKIP_INSURRANCE});
			}
			
		}
		private function hit(evt:MouseEvent):void{ 
			if (mgr.started){
				//hideAll();
				socketMgr.send({proto:ProtocolClientEnum.PROTO_HIT,  tabId:mgr.currentTable.tableId});
			}else{
				var result:Boolean = mgr.start();	
				if ( result ){
					hideAll();
					MainViewImpl.Instance.tween(true);
				}
				
			}
		}

		private function clean(evt:MouseEvent):void{
			mgr.reset();
			MainViewImpl.Instance.tween(false);
			switchModel(MODEL_CLEAN);
		}
		private function double(evt:MouseEvent):void{
			//this.hideAllBtns();
			if ( mgr.started){
				socketMgr.send({proto:ProtocolClientEnum.PROTO_DOUBLE, tabId:mgr.currentTable.tableId});
			}else{
				betAndStart(true);
			}
			
		}
		private function stand(evt:MouseEvent):void{
			if( mgr.started && mgr.currentTable){
				socketMgr.send({proto:ProtocolClientEnum.PROTO_STAND, tabId:mgr.currentTable.tableId});
			}
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