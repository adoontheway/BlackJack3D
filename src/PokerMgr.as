package  
{
	import com.greensock.easing.BackInOut;
	import comman.duke.GameUtils;
	import consts.PokerGameVars;
	import uiimpl.OperationViewImpl;
	import flash.utils.*;
	import com.greensock.*;
	/**
	 * ...
	 * @author jerry.d
	 */
	public class PokerMgr 
	{
		private var pokers:Vector.<uint>;
		public var myId:uint=1;
		public var masterId:uint=0;
		
		public var model:uint=1;
		public var desk:uint;
		public var currentChips:Array;
		public function PokerMgr() 
		{
			this.init();
		}
		
		//private var playerMap:Object;
		public function addPlayers():void{
			//this.playerMap[player.id] = player;
			this.playerCard[0] = [];
			this.playerCard[1] = [];
			this.pokerMap = {};
		}
		
		private function init():void{
			this.pokePool = new Vector.<Poker>();
			this.playerCard = {};
			//this.playerMap = {};
			//this.endAnimMap = {};
			this.pokers = new Vector.<uint>();
			this.pokers.push(
				1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,
				14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26,
				27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39,
				40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52
			);
			this.total = pokers.length;
			this.shuffle();
		}

		public function shuffle(times:uint = 50,scope:uint=5 ):void{
			var index0:uint;
			var index1:uint;
			var len:uint = pokers.length;
			var i:uint = 0;
			var temp:uint;
			var r0:uint;
			var r1:uint;
			while (times > 0){
				index0 = Math.floor(Math.random() * len);
				index1 = Math.floor(Math.random() * len);
				while (index0 == index1 ){
					index1 = Math.floor(Math.random() * len);
				}
				for (i = 0; i < scope; i++){
					r0 = index0 % len;
					r1 = index1 % len;
					temp = pokers[r0];
					pokers[r0] = pokers[r1];
					pokers[r1] = temp;
					index0++;
					index1++;
				}
				times--;
			}
			GameUtils.log('shuffle',pokers.join(","));
		}
		private var startInterval:uint;
		public function start():void{
			if ( this.startInterval != 0) return;
			startInterval = setInterval(
			function():void{
				if ( playerCard[masterId].length < 2){
					dispenseTo(masterId,true);
				}else if ( playerCard[myId].length < 2){
					dispenseTo(myId,true);
				}else{
					clearInterval(startInterval);
					startInterval = 0;
				}
			}, 
			1000);
			currentBet = 10;
			OperationViewImpl.Instance.showBetMsg();
		}
		
		public function masterTurn():void{
			var currentPoint:uint = this.caculate(this.playerCard[masterId]);
			if ( currentPoint < 21 ){
				var next:uint = pokers[this.currentDispense];
				var nextRefer:uint;
				if ( next == 1){
					if (currentPoint + 11 <= 21){
						nextRefer = currentPoint + 11;
					}else {
						nextRefer = currentPoint + 1;
					}
				}else if (next >= 10){
					nextRefer = currentPoint + 10;
				}else{
					nextRefer = currentPoint + next;
				}
				if ( nextRefer <= 21){
					dispenseTo(masterId);
					setTimeout(function():void{
						masterTurn();
					}, 1000);
				}else{
					endRound();
				}
			}else{
				this.endRound();
			}
		}
		
		private function endRound():void{
			var myPoint:uint = this.caculate(this.playerCard[myId]);
			var masterPoint:uint = this.caculate(this.playerCard[masterId]);
			if ( myPoint > 21){
				OperationViewImpl.Instance.showMsg("YOU BURST: " + myPoint + " VS " + masterPoint);
				myMoney -= currentBet;
			}else if(masterPoint > 21){
				OperationViewImpl.Instance.showMsg("YOU WIN: " + myPoint + " VS " + masterPoint);
				myMoney += currentBet;
			}else if (myPoint > masterPoint){
				OperationViewImpl.Instance.showMsg("YOU WIN: " + myPoint + " VS " + masterPoint);
				myMoney += currentBet;
			}else if ( myPoint < masterPoint){
				OperationViewImpl.Instance.showMsg("YOU LOSE: " + myPoint + " VS " + masterPoint);
				myMoney -= currentBet;
			}else{
				OperationViewImpl.Instance.showMsg("DRAW ROUND: "+myPoint+ " VS "+ masterPoint);
			}
			OperationViewImpl.Instance.showBetMsg();
			canOperate = false;
			setTimeout(function():void{
				restart();
			}, 2000);
		}
		
		private function caculate(card:Array):uint{
			var hasA:Boolean = false;//todo multi A
			var index:uint = 0;
			var len:uint = card.length;
			var points:uint = 0;
			var point:uint = 0;
			while ( index < len){
				point = (card[index] - 1) % 13 + 1;
				if ( point == 1){
					hasA = true;
				}else if ( point >= 10){
					points += 10;
				}else{
					points += point;
				}
				index++;
			}
			if ( hasA ){
				if ( points + 11 <= 21 ){
					return points + 11;
				}else{
					return points + 1;
				}
			}
			return points;
		}
		
		private var playerCard:Object;//the cards player hole
		private var currentDispense:uint = 0;//current poker index
		private var total:uint ;//total pokers
		private var currentCallId:uint;//current call player
		private var pokerMap:Object;
		public var canOperate:Boolean = true;
		public function dispenseTo(playerId:uint, isFirst:Boolean = false,needPlayAnim:Boolean=false):void{
			if ( this.currentDispense >= this.pokers.length - 1){
				return;
			}
			var poker:Poker = this.getCard(this.pokers[this.currentDispense]);//new Card(this.pokers[this.currentDispense]);
			poker.x = 1560;
			poker.y = 20;
			poker.rotationX = 180;
			pokerMap[poker.value] = poker;
			
			var ownCnt:uint = this.playerCard[playerId].length + 1;
			
			if ( ownCnt == 1 && playerId == masterId){
				poker.rotationX = 210;
			}
			
			this.playerCard[playerId].push(poker.value);
			canOperate = false;
			if( playerId == masterId)
				TweenLite.to(poker, 0.5, {x:800 + 80 * ownCnt, y:100, rotationX:0, onComplete:onComplete});
			else
				TweenLite.to(poker, 0.5, {x:800 + 80 * ownCnt, y:350, rotationX:0, onComplete:onComplete});
			PokerGameVars.STAGE.addChild(poker);
			this.currentDispense++;
			if ( !isFirst){
				var points:uint = caculate(this.playerCard[playerId]);
				if ( points > 21 ){
					endRound();
				}
			}
		}
		
		
		private function onComplete():void{
			canOperate = true;
		}
		
		private var chip_cnt:uint = 0;
		public function addBet(value:uint):void{
			chip_cnt++;
			currentBet += value;
			OperationViewImpl.Instance.showBetMsg();
			var chip:Chip = new Chip();
			chip.value = value;
			
			chip.name = "chip_" + chip_cnt;
			chip.x = PokerGameVars.STAGE_WIDTH *0.5 - 150;
			chip.y = PokerGameVars.STAGE_HEIGHT;
			chip.rotationX = 0;
			chip.mouseEnabled = false;
			PokerGameVars.STAGE.addChild(chip);
			TweenLite.to(chip, 0.5, {x: chip.x +int((Math.random()-0.5)*100),y:200+Math.random()*100,rotationX:20, ease:new BackInOut()});
		}
		
		
		public var myMoney:uint = 10000;
		public var currentBet:uint = 0;
		public function doubleBet():void{
			currentBet = currentBet << 1;
			OperationViewImpl.Instance.showBetMsg();
		}
		
		public function quit():void{
			myMoney -= currentBet >> 1;
			OperationViewImpl.Instance.showBetMsg();
			restart();
		}
		
		public function restart():void{
			var card:Poker;
			for (var key:String in this.pokerMap){
				card = this.pokerMap[key];
				PokerGameVars.STAGE.removeChild(card);
				TweenLite.killTweensOf(card);
				this.reclaim(card);
				delete this.pokerMap[key];
			}
			for (key in this.playerCard){
				 this.playerCard[key] = [];
			}
			
			if ( currentDispense >= (this.total >> 1)){
				this.currentDispense = 0;
				shuffle();
			}
			
			start();
		}
		private var pokePool:Vector.<Poker>;
		public function getCard(value:uint = 0):Poker{
			if ( this.pokePool.length){
				var card:Poker = this.pokePool.pop();
				card.value = value;
				return card;
			}
			return new Poker(value);
		}
		
		public function reclaim(card:Poker):void{
			if ( this.pokers.indexOf(card) != -1){
				this.pokers.push(card);
			}
		}
		
		private static var _instance:PokerMgr;
		public static function get Instance():PokerMgr{
			if ( PokerMgr._instance == null ){
				PokerMgr._instance = new PokerMgr();
			}
			return PokerMgr._instance;
		}
		
	}
}