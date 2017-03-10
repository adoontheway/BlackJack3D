package localServer 
{
	/**
	 * ...
	 * @author jerry.d
	 */
	public class ServerPlayer 
	{
		public var doubled:Boolean;
		public var blackjack:Boolean;
		public var bust:Boolean;
		public var points:Boolean;
		public var splited:Boolean;
		public var canSplit:Boolean;
		public var cards:Array;
		public var player_id:int;
		public var hasA:Boolean;
		public function ServerPlayer(player_id:int) 
		{
			this.doubled = false;
			this.blackjack = false;
			this.bust = false;
			this.points = 0;
			this.splited = false;
			this.canSplit = false;
			this.cards = [];
			this.player_id = player_id;
			this.hasA = false;
		}
		
		public function addCard(card:int):Boolean{
			if(this.cards.indexOf(card) == -1){
				this.cards.push(card);
				var tempValue = (card - 1)%13 + 1;
				this.hasA = this.hasA || tempValue == 1;
				this.points += tempValue;
				this.canSplit = false;

				if( this.cards.length == 2 && (this.cards[0]-1)%13 == tempValue){
					this.canSplit = true;
				}else if(this.points == 21 && this.cards.length == 2){
					this.blackjack = true;
					return false;
				}else if(this.points > 21){
					this.bust = true;
					return false;
				}else{
					return true;
				}
			}else{ 
				throw new Error('already dispensed...');//when 1 poker
			}
			return false;
		}
		
		public function reset():void{
			this.doubled = false;
			this.blackjack = false;
			this.bust = false;
			this.points = 0;
			this.splited = false;
			this.cards = [];
			this.player_id = 0;
			this.hasA = false;
			this.canSplit = false;
		}
	}

}