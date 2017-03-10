package localServer 
{
	/**
	 * ...
	 * @author jerry.d
	 */
	public class ServerTable 
	{
		public var tabId:int;
		public var cards:Array;
		public var compareValues:Array;
		public var realValues:Array;
		public var points:int;
		public var currentBet:int;
		public var hasA:Boolean;
		public var blackjack:Boolean;
		public var bust:Boolean;
		public var canSplit:Boolean;
		public var canDouble:Boolean;
		public var doubled:Boolean;
		public var isSplited:Boolean;
		public var next:ServerTable;
		public var child:ServerTable;
		public var parent:ServerTable;
		public var actived:Boolean;
		public var inSurrance:Boolean;
		public var isSurranceOpertated:Boolean;
		public var pairBet:int;
		public var isPair:Boolean;
		public function ServerTable(tabId:int) 
		{
			this.tabId = tabId;
			this.cards = [];
			this.compareValues = [];
			this.realValues = [];
			this.points = 0;
			this.currentBet = 0;
			this.hasA = false;
			this.blackjack = false;
			this.bust = false;
			this.canSplit = false;
			this.doubled = false;
			this.canDouble = false;
			this.isSplited = false;
			this.next = null;
			this.child = null;//split to
			this.parent = null;//slipt from
			this.actived = false;
			this.inSurrance = false;//是否保险
			this.isSurranceOpertated = false;//是否已经处理保险需求
			this.pairBet = 0;
			this.isPair = false;
		}
		
		public function addCard(card:int):void{
			if( !this.actived ){
				trace(this.tabId+'is not activated..');
				return;
			}
			this.cards.push(card);
			var realValue = (card%100 - 1)%13 + 1;
			this.realValues.push(realValue);
			var compareValue = 0;
			if( realValue < 10){
				compareValue = realValue;
			}else{
				compareValue = 10;
			}
			this.compareValues.push(compareValue);
			if( !this.hasA ){
				this.hasA = realValue == 1;
			}
			this.points += compareValue;
			this.isPair = !this.isSplited && this.cards.length == 2 && this.realValues[0] == this.realValues[1];
			if ( this.cards.length == 2){
				if ( this.points == 11 && this.hasA){
					this.blackjack = true;
					trace('[table-'+this.tabId+'] blackjack');
				}else if ( this.compareValues[0] == this.compareValues[1]){
					this.canSplit = !this.isSplited;
				}
			}else{
				this.blackjack = false;
				this.canSplit = false;
				this.bust = this.points > 21 ;
			} 
		}
		
		public function reset():void{
			this.hasA = false;
			this.blackjack = false;
			this.bust = false;
			this.canSplit = false;
			this.doubled = false;
			this.canDouble = false;
			this.isSplited = false;
			this.child = null;
			this.points = 0;
			this.currentBet = 0;
			this.cards = [];
			this.realValues = [];
			this.compareValues = [];
			this.child = null;
			this.next = null;
			this.parent = null;
			this.actived = false;
			this.inSurrance = false;
			this.isSurranceOpertated = false;
			this.pairBet = 0;
			this.isPair = false;
		}
	}

}