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
		
		private var cards:Vector.<PokerImpl>;
		public var points:int = 0;
		public var currentBet:int;
		/** 是否活跃 **/
		public var actived:Boolean;
		/** 是否本局已经结束：后续不结算，eg：五龙 **/
		public var endRound:Boolean;
		
		/*** switched ***/
		public var hasA:Boolean;//got a
		public var blackjack:Boolean;//got blackjack
		public var fiveDragon:Boolean;//got five dragon
		public var bust:Boolean;//bust
		public var doubled:Boolean;//already doubled
		public var standing:Boolean;//stand or not
		public var canSplit:Boolean;//can split
		public var _isSplited:Boolean;//already splited
		
		public function Table(tabId:int) 
		{
			this.cards = new Vector.<PokerImpl>();
			this.tableId = tabId;
		}
		private var startX:int;
		private var k:Number;
		private var b:Number;
		
		private var rawStartX:int;
		public var arrowX:int;
		public var arrowY:int;
		private var rotation:Number;
		private var rawK:Number;
		private var rawB:Number;
		
		private var splitedStartX:int
		private var splitedK:Number;
		private var splitedB:Number;
		public function setIndex(index:int):void{
			this.tableIndex = index;
			var pos:* = PokerGameVars.TABLE_POS[index];
			this.rawStartX = pos.x;
			this.rawK = pos.k;
			this.rawB = pos.b;
			this.splitedStartX = pos.sx;
			this.splitedK = pos.sk;
			this.splitedB = pos.sb;
			this.split = split;
		}
		
		/**
		 * @param card  compare value of card
		 * **/
		public function addCard(card:PokerImpl):void{
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
				}else if ( cards[0].compareValue == cards[1].compareValue && (!this._isSplited && this.tableIndex <= 3)){
					this.canSplit = true;
				}
			}else if ( this.cards.length == 5 && this.points <= 21){
				this.fiveDragon = true;
			}else if ( this.points > 21 ){
				this.bust = true;
			}
		}
		
		public function set split(val:Boolean):void{
			this._isSplited = val;
			if ( !this._isSplited){
				this.startX = rawStartX;
				this.k = rawK;
				this.b = rawB;
			}else{
				this.startX = splitedStartX;
				this.k = splitedK;
				this.b = splitedB;
			}
			this.arrowX = this.startX;
			this.arrowY = this.k *  this.startX + this.b;
			//this.rotation = Math.atan(this.k);
		}
		
		public function get split():Boolean{
			return _isSplited;
		}
		
		public function reset():void{
			this.points = 0;
			this.currentBet = 0;
			this.blackjack = false;
			this.canSplit = false;
			this.doubled = false;
			this.fiveDragon = false;
			this.bust = false;
			this.actived = false;
			this.hasA = false;
			if ( this.tableIndex <= 3){
				this.split = false;
			}
			while ( this.cards.length ){
				this.cards.pop();
			}
		}
		
	}

}