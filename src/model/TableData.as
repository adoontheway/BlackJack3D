package model 
{
	import consts.PokerGameVars;
	import uiimpl.SubTable;
	/**
	 * ...
	 * @author jerry.d
	 */
	public class TableData 
	{
		/** 前后端通用的id **/
		public var tableId:int;
		public var display:SubTable;
		public var cards:Vector.<Poker>;
		public var numCards:int = 0;
		public var points:int = 0;
		public var currentBet:int;
		/** 是否活跃:游戏中与否的标示，跟stop应该不能有关系 **/
		public var actived:Boolean;
		/** 是否本局已经结束：后续不结算，eg：五龙 **/
		public var endRound:Boolean;
		
		/*** switched ***/
		public var numA:int;//how many A do i have
		public var blackjack:Boolean;//got blackjack
		public var bust:Boolean;//bust
		public var doubled:Boolean;//already doubled
		public var standing:Boolean;//stand or not
		public var canSplit:Boolean;//can split
		public var isSplited:Boolean;//already splited
		/** 是否保险过 **/
		public var insured:Boolean;
		/** 赌对子 */
		public var pairBet:int;
		/** 保险花费 */
		public var insureBet:int;
		public var prize:int;
		public function TableData(tabId:int) 
		{
			this.cards = new Vector.<Poker>();
			this.tableId = tabId;
		}
		
		/**
		 * @param card  compare value of card
		 * 
		 * **/
		public function addCard(card:Poker):void{
			this.cards.push(card);
			numCards = this.cards.length;
			this.points += card.compareValue;
			if ( this.tableId == 0 ){
				GameMgr.Instance.needShowInsure = this.cards.length == 1 && this.points == 1;
			}
			if ( card.realValue == 1){
				this.numA++;
			}
			if ( this.numA > 0 && this.points == 11) this.points = 21;
			
			this.canSplit = !this.isSplited && this.tableId <= 3 && numCards == 2 && cards[0].compareValue == cards[1].compareValue;
			this.blackjack =  numCards == 2 && this.numA != 0 && this.points == 21 && !isSplited  && this.tableId <= 3;
			this.bust = points > 21;
		}

		public function getCard(value:int):Poker{
			for each(var card:Poker in cards){
				if ( card.value == value){
					return card;
				}
			}
			return null;
		}
		
		public function removeCard(poker:Poker):void{
			var index:int = this.cards.indexOf(poker);
			this.points -= poker.compareValue;
			if ( poker.realValue == 1) this.numA--;
			if ( index != -1){
				this.cards.splice(index, 1);
			}
		}
		
		public function reset():void{
			this.points = 0;
			this.currentBet = 0;
			this.blackjack = false;
			this.canSplit = false;
			this.doubled = false;
			this.bust = false;
			this.actived = false;
			this.numA = 0;
			this.pairBet = 0;
			this.insureBet = 0;
			this.prize = 0;
			this.insured = false;
			if ( this.tableId <= 3){
				this.isSplited = false;
			}
			while ( this.cards.length ){
				this.cards.pop();
			}
		}
		
	}

}