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
		/** 前端使用的index，用来标示位置与显示信息 **/
		public var tableIndex:int;
		/** 前后端通用的id **/
		public var tableId:int;
		
		//public var playerId:int;
		//public var masterIndex:int;//
		//public var slaveIndex:int = -1;//
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
		
		public function Table(index:int=-1) 
		{
			this.cards = new Vector.<PokerImpl>();
			if( index != -1)
				this.setIndex(index);
		}
		
		private var startX:int;
		private var startY:int;
		private var rotation:Number;
		private var k:Number;
		private var b:Number;
		public function setIndex(index:int):void{
			this.tableIndex = index;
			var pos:* = PokerGameVars.TABLE_POS[index];
			this.startX = pos.x;
			this.startY = pos.y;
			this.k = pos.k;
			this.b = pos.b;
			this.rotation = Math.atan(this.k)
		}
		
		/**
		 * @param card  compare value of card
		 * **/
		public function addCard(card:PokerImpl):Boolean{
			this.cards.push(card);
			this.points += card.compareValue;
			card.targetX = this.startX + (this.cards.length - 1) * 20;
			card.targetY = this.k * card.targetX + this.b;
			card.targetRotate = this.rotation;
			if ( !this.hasA ){
				this.hasA = card.realValue == 1;
			}
			
			if ( this.cards.length == 2){
				if ( this.hasA && this.points == 11 ){
					this.blackjack = true;
					return true;
				}else if ( cards[0].compareValue == cards[1].compareValue && !this.isSplited){
					this.canSplit = true;
					return false;
				}
			}else if ( this.cards.length == 5 && this.points <= 21){
				this.fiveDragon = true;
				return true;
			}else if ( this.points > 21 ){
				this.bust = true;
				return true;
			}
			
			return false;
		}
		
		public function reset():void{
			this.tableId = -1;
			this.blackjack = false;
			this.canSplit = false;
			this.doubled = false;
			this.fiveDragon = false;
			this.bust = false;
			this.actived = false;
			while ( this.cards.length ){
				this.cards.pop();
			}
		}
		
	}

}