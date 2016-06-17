package model 
{
	import consts.PokerGameVars;
	import uiimpl.PokerImpl;
	/**
	 * ...
	 * @author jerry.d
	 */
	public class Table 
	{
		public var playerId:int;
		public var masterIndex:int;//
		public var slaveIndex:int = -1;//
		private var cards:Vector.<PokerImpl>;
		public var points:int = 0;
		public var currentBet:int;
		
		public var actived:Boolean;//can accept card or not
		
		/*** switched ***/
		public var hasA:Boolean;//got a
		public var blackjack:Boolean;//got blackjack
		public var fiveDragon:Boolean;//got five dragon
		public var bust:Boolean;//bust
		public var doubled:Boolean;//already doubled
		public var standing:Boolean;//stand or not
		public var canSplit:Boolean;//can split
		public var isSplited:Boolean;//already splited
		
		public function Table(master:int, slave:int=-1) 
		{
			this.cards = new Vector.<PokerImpl>();
			this.setIndex(master, slave);
		}
		
		private var posx:int;
		private var posy:int;
		public function setIndex(master:int, slave:int =-1):void{
			this.masterIndex = master;
			this.slaveIndex = slave;
			if ( this.slaveIndex == -1){
				var pos:* = PokerGameVars.TABLE_POS[master];
			}else{
				pos = PokerGameVars.TABLE_POS[master + '_' + slave];
			}
			this.posx = pos.x;
			this.posy = pos.y;
		}
		
		/**
		 * @param card  compare value of card
		 * **/
		public function addCard(card:PokerImpl):void{
			this.cards.push(card);
			this.points += card.compareValue;
			card.targetX = this.posx + (this.cards.length - 1) * 20;
			card.targetY = posy;
			if ( !this.hasA ){
				this.hasA = card.realValue == 1;
			}
			
			if ( this.cards.length == 2){
				if ( this.points == 21 ){
					this.blackjack = true;
				}else if ( cards[0].compareValue == cards[1].compareValue ){
					this.canSplit = true;
				}
			}else if ( this.cards.length == 5 && this.points <= 21){
				this.fiveDragon = true;
			}else if ( this.points > 21 ){
				this.bust = true;
			}
		}
		
		public function reset():void{
			this.blackjack = false;
			this.canSplit = false;
			this.doubled = false;
			this.fiveDragon = false;
			this.bust = false;
			while ( this.cards.length ){
				this.cards.pop();
			}
		}
		
	}

}