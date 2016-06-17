package uiimpl 
{
	import comman.duke.GameUtils;
	import consts.PokerGameVars;
	import flash.events.MouseEvent;
	import game.ui.mui.OperationViewUI;
	
	/**
	 * ...
	 * @author jerry.d
	 */
	public class OperationViewImpl extends OperationViewUI 
	{
		private var pokerMgr:PokerMgr;
		public function OperationViewImpl() 
		{
			super();
			this.y = 650;
			this.btn_clear.addEventListener(MouseEvent.CLICK, onClear);
			this.btn_double.addEventListener(MouseEvent.CLICK, onDouble);
			this.btn_submit.addEventListener(MouseEvent.CLICK, onSubmit);
			pokerMgr = PokerMgr.Instance;
		}
		
		private function onClear(evt:MouseEvent):void{
			
		}
		
		private function onDouble(evt:MouseEvent):void{
			
		}
		
		private function onSubmit(evt:MouseEvent):void{
			var chipValue:uint = ChipsViewUIImpl.Instance.currentValue;
			if ( chipValue == 0 ){
				return ;
			}else{
				pokerMgr.addBet(chipValue);
				pokerMgr.start();
			}
		}
		
		public function showBetMsg():void{
			this.lab_bet.text = GameUtils.NumberToString(pokerMgr.currentBet);
			this.label_balance.text = GameUtils.NumberToString(pokerMgr.myMoney);
		}
		public function showMsg(info:String):void{
			
		}
		
		public function resize():void{
			this.x = PokerGameVars.STAGE_WIDTH - width >> 1;
		}
		
		private static var _instance:OperationViewImpl;
		public static function get Instance():OperationViewImpl{
			if ( OperationViewImpl._instance == null){
				OperationViewImpl._instance = new OperationViewImpl();
			}
			return OperationViewImpl._instance;
		}
	}

}