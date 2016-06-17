package 
{
	/**
	 * ...
	 * @author jerry.d
	 */
	public class Player 
	{
		public var id:int;//桌面玩家id： 如果和masterId不相等的话那么就是分牌
		public var masterId:int;//真正的玩家id
		public var xPos:int;
		public var yPos:int;
		public var xGap:int;
		
		public var isSpliting:Boolean;
		public var isBlackJack:Boolean;
		public var isDoubled:Boolean;
		public var hasAce:Boolean;
		
		public var currentCards:Vector.<Card> = new Vector.<Card>();
		private var _points:int;
		public function Player() 
		{
			
		}
		
		public function addCard(card:Card){
			if ( !this.hasAce && card.realValue == 1){
				this.hasAce = true;
			}
			_points += card.realValue;
		}
		
		public function get points():int{
			return this._points;
		}
		
		public function reset(){
			while (currentCards.length){
				currentCards.pop();
			}
		}
	}

}