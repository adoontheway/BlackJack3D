package localServer 
{
	import flash.utils.*;
	import utils.TableUtil;
	/**
	 * ...
	 * @author jerry.d
	 */
	public class Server 
	{
		private var pokers:Array = [];
		public function Server() 
		{
			
		}
		private var currentPokerIndex:int;
		private var currentTurn:int;
		private var playerId:int;
		private var player:ServerPlayer;
		private var mycards:Array;
		private var total:int;
		private var currentBet:int;
		private var money:int;
		private var user:String;
		private var tables:Object;
		private var currentTables:Array;
		private var overTables:Array;
		private var bankerTable:ServerTable;
		private var dispenseObj:Object;
		private var fakeCard:int;
		private function init():void{
			for(var i:int = 100; i <= 400; i+=100){
				for(var j:int = 1; j <= 13; j++){
					this.pokers.push(i+j);
				}
			}
			
			this.currentPokerIndex = 0;
			this.currentTurn = 0;
			this.playerId = playerId;
			this.player = new ServerPlayer(playerId);
			this.mycards = [];
			this.total = 52;
			this.currentBet = 0;
			this.money = 10000;

			this.user = '';
			this.tables = {};//todo 如何保证有序循环
			this.currentTables = [];//本局使用中的桌子id， 未处理
			this.overTables = [];//本局已经结束id 待结算
			this.bankerTable = this.generateTable(0);
			//this.dispenseObj = {proto:Config.S_B_DISPENSE};
			dispenseObj['proto'] = ServerConfig.S_B_DISPENSE;
			this.fakeCard = -1;
		}
		
		public function start():void{
			var tabId;
			var len = this.currentTables.length - 1;

			for( var i = 0; i <= len; i++){
				tabId = parseInt(this.currentTables[i]);
				if( tabId != 0){
					this.dispense(tabId);
				}
			}

			this.dispense(0);
			
			for( var i = 0; i <= len; i++){
				tabId = parseInt(this.currentTables[i]);
				if( tabId != 0){
					this.dispense(tabId);
				}
			}
			var table;
			var gain;
			var pool = [];
			for(var i = len; i >= 0; i--){
				table = this.tables[this.currentTables[i]];
				//console.log("after start check: "+i+" blackjack"+table.blackjack+" pair:"+table.pairBet);
				if( table.pairBet != 0){
					gain = table.isPair ? table.pairBet * ServerConfig.PAIR : -table.pairBet;
					this.money += gain;
					pool.push(this.currentTables[i], gain);
					
				}
				if( table.blackjack ){
					this.putToEnd(this.currentTables[i]);
				}
			}

			this.send({code:0, proto:ServerConfig.S_B_PAIR_RESULT,result:pool, money:this.money});
			
			this.dispense(0,true);
			//console.log(this.bankerTable.compareValues[0]+" "+this.bankerTable.blackjack);
			if( this.bankerTable.compareValues[0] == 10 && this.bankerTable.blackjack){//第一张是10并且是blackjack的话直接结算
				this.overTables = this.currentTables;
				this.currentTables = [];
				this.serverTurn();
			}
		}
		
		public function dispense(tabId:int,fake:Boolean=false):void{
			this.dispenseObj.table = tabId;
			trace('try dispense '+tabId  );
			if( tabId != 0 ){
				var table = this.tables[tabId];
				if( !table.actived ) return;
				table.addCard(this.pokers[this.currentPokerIndex]);
			}else{
				this.bankerTable.addCard(this.pokers[this.currentPokerIndex]);
			}
			if( !fake){
				this.dispenseObj.card = this.pokers[this.currentPokerIndex];
			}else{
				this.fakeCard = this.pokers[this.currentPokerIndex];
				this.dispenseObj.card = -1;
			}
			this.dispenseObj.code = 0;
			this.currentPokerIndex++;
			this.send(this.dispenseObj);
		}
		
		public function generateTable(tableId):ServerTable{
			var table = this.tables[tableId];
			if( table != null) {
				table.reset();
				table.actived = true;
				//console.log('Get exsit table: '+tableId);
				return table;
			}
			var table = new ServerTable(tableId);
			this.tables[tableId] = table;
			//console.log('Get exsit table: '+tableId);
			table.actived = true;
			return table;
		}
		
		public function serverTurn():void{
			trace('server\'s turn:');
			if( this.fakeCard != -1){
				this.send({code:0,proto:ServerConfig.S_B_FAKE_CARD,card:this.fakeCard});
				this.fakeCard = -1;
			}
			if( this.overTables.length == 0) {
				this.send({code:0,proto:ServerConfig.S_B_ROUND_END});
				return;
			}
			
			var num = 0;
			if( !this.bankerTable.blackjack){
				if( !this.bankerTable.hasA){
					while( this.bankerTable.points < 17 ){
						this.bankerTable.addCard(this.pokers[this.currentPokerIndex]);
						this.dispenseObj.table = 0;
						this.dispenseObj.card = this.pokers[this.currentPokerIndex];
						this.currentPokerIndex++;
						this.send(this.dispenseObj);
						num++;
					}
				}else{
					while( this.bankerTable.points + 10 < 17 || (this.bankerTable.points > 11 && this.bankerTable.points < 17)){
						this.bankerTable.addCard(this.pokers[this.currentPokerIndex]);
						this.dispenseObj.table = 0;
						this.dispenseObj.card = this.pokers[this.currentPokerIndex];
						this.currentPokerIndex++;
						this.send(this.dispenseObj);
						num++;
					}
				}
				
			}else{
				var table:ServerTable;
				trace('banker blackjack:'+this.overTables.join('.'));
				var len = this.overTables.length-1;
				for (var i = len; i >=0; i--){
					table = this.tables[this.overTables[i]];
					if( table.blackjack ){
						this.send({code:0,proto:ServerConfig.S_B_END,result:ServerConfig.RESULT_DRAW, tabId:this.overTables[i]});
						this.overTables.splice(i,1);
						trace('end 1:'+table.tabId+', rest:'+this.overTables.join('.'));
					}else{
						money = table.currentBet;
						this.money += money;
						this.send({code:0,proto:ServerConfig.S_B_END,result:ServerConfig.RESULT_LOSE,money:this.money, gain:money,tabId:this.overTables[i] });
						this.overTables.splice(i,1);
						trace('end 2:'+table.tabId+', rest:'+this.overTables.join('.'));
					}
				}
			}
			
			if( this.overTables.length != 0){
				setTimeout(function(){
					endRound();
				},num*500);
			}else{
				setTimeout(function(){
					send({code:0,proto:ServerConfig.S_B_ROUND_END});
				},2000);
				//console.log("something is wrong in serverturn, still got overtables:"+this.overTables.join(","));
			}
		}
		
		public function endRound():void{
			trace('final check:'+this.overTables.join('.'));
			var bankerPoints:int = 0;
			var tablePoints:int = 0;
			var tabId:int = 0;
			var gain:int = 0;
			var table:ServerTable;
			while( this.overTables.length != 0){
				tabId = this.overTables.pop();
				table = this.tables[tabId];
				trace( 'judging : '+ tabId );
				if( this.bankerTable.bust){
					if(table.bust){
						trace('bust draw');
						this.send({code:0,proto:ServerConfig.S_B_END,result:ServerConfig.RESULT_DRAW,tabId:tabId});
					}else{
						trace('banker bust u win');
						gain = !table.blackjack ? table.currentBet : table.currentBet*ServerConfig.BLACKJACK;
						this.money += gain;
						this.send({code:0,proto:ServerConfig.S_B_END,result:ServerConfig.RESULT_WIN,money:this.money, gain:gain,tabId:tabId});
					}
				}else{
					bankerPoints = this.bankerTable.points;
					
					if( this.bankerTable.blackjack && !table.blackjack){
						this.money -= table.currentBet;
						this.send({code:0,proto:ServerConfig.S_B_END,result:ServerConfig.RESULT_LOSE,money:this.money, gain:table.currentBet,tabId:tabId});
						continue;
					}

					if( table.blackjack && !this.bankerTable.blackjack){
						this.money += table.currentBet*ServerConfig.BLACKJACK;
						this.send({code:0,proto:ServerConfig.S_B_END,result:ServerConfig.RESULT_WIN,money:this.money, gain:table.currentBet*ServerConfig.BLACKJACK,tabId:tabId});
						continue;
					}

					if( this.bankerTable.hasA && this.bankerTable.points + 10 <= 21){
						bankerPoints += 10;
					}
					tablePoints = table.points;
					if( table.hasA && table.points + 10 <= 21){
						tablePoints += 10;
					}
					if( table.bust || bankerPoints > tablePoints){
						trace('lose [me]'+tablePoints+'<--->[banker]'+bankerPoints);
						this.money -= table.currentBet;
						this.send({code:0,proto:ServerConfig.S_B_END,result:ServerConfig.RESULT_LOSE,money:this.money, gain:table.currentBet,tabId:tabId});
					}else if( bankerPoints == tablePoints){
						trace('draw');
						this.send({code:0,proto:ServerConfig.S_B_END,result:ServerConfig.RESULT_DRAW,tabId:tabId});
					}else{
						trace('win [me]'+tablePoints+'<--->[banker]'+bankerPoints);
						this.money += table.currentBet;
						this.send({code:0,proto:ServerConfig.S_B_END,result:ServerConfig.RESULT_WIN,money:this.money, gain:table.currentBet,tabId:tabId});
					}
				}
			}
			/**
			var self = this;
			schemas.User.findOneAndUpdate({name:this.user},{money:this.money}, function(err){
				if( err ){
					console.error(err);
					return;
				}
				console.log('Success update money to '+self.money);
			});
			*/
			this.send({code:0,proto:ServerConfig.S_B_ROUND_END});
		}
		
		public function handle(data:Object):void{
			var proto = data.proto;
			var protoObj = {code:0};
			switch(proto){
				case ServerConfig.C_START://start	
					if( this.currentPokerIndex >= 26){
						TableUtil.shuffle(this.pokers,15,5);
						this.currentPokerIndex = 0;
					}
					var bets = data.bet;
					var pair = data.pair;
					this.currentBet = 0;
					this.currentTables = [];
					this.overTables = [];
					for( var i in bets){
						this.currentBet += bets[i];
					}

					if( this.currentBet > this.money){
						this.send({proto:ServerConfig.S_R_START,code:ErrorCode.ErrorLackBalance});
					}else if( this.currentBet == 0){
						this.send({proto:ServerConfig.S_R_START,code:ErrorCode.ErrorNoBet});
					}else{
						var table ;
						for(var i in this.tables){
							table = this.tables[i];
							table.reset();
							table.actived = false;
						}
						var tableId;
						for( var i in bets){
							tableId = parseInt(i);
							if( tableId != 0 ){
								table = this.generateTable(tableId);
								table.currentBet = bets[i];
								this.currentTables.push(tableId);
							}
						}
						if( pair != undefined){
							for( var i in pair){
								tableId = parseInt(i);
								if( tableId != 0 ){
									table = this.tables[tableId];
									table.pairBet = pair[i];
								}
							}
						}
						this.currentTables.sort();
						trace('Current Tables :'+ this.currentTables.join(','))
						this.send({proto:ServerConfig.S_R_START,code:0,tables:this.currentTables, money:this.money});
						this.bankerTable.reset();
						this.bankerTable.actived = true;
						this.start();
					}
				break;
				case ServerConfig.C_ADD_BET://add bet
					this.currentBet += data.bet;
					protoObj.proto = ServerConfig.S_R_BET;
					protoObj.bet = this.currentBet;
					this.send(protoObj);
					break;
				case ServerConfig.C_HIT://hit
					var tabId = data.tabId;
					var table = this.tables[tabId];
					if( table == null){
						return;
					}
					trace('hit ' + tabId+" "+table.points+ ' '+table.bust);
					if( !table.bust){
						this.dispense(tabId);
						if( table.bust ){
							this.money -= table.currentBet;
							var gain = table.currentBet;
							table.reset();
							this.send({code:0,proto:ServerConfig.S_B_END,result:ServerConfig.RESULT_LOSE,money:this.money,tabId:tabId,gain:gain});
							//access time problem
							var index = this.currentTables.indexOf(tabId);
							if( index != -1){
								this.currentTables.splice(index, 1);
							}
							if( this.currentTables.length == 0){
								this.serverTurn();
							}
							//this.putToEnd(tabId);
						}else if(table.points == 21 ||(table.hasA && table.points == 11)){
							this.putToEnd(tabId);
						}
					}else{
						this.send({code:ErrorCode.ErrorAlreadyBust,proto:ServerConfig.S_R_HIT});
						this.putToEnd(tabId);
					}
					
				break;
				case ServerConfig.C_DOUBLE://double
					protoObj.proto = ServerConfig.S_R_DOUBLE;
					var tabId = data.tabId;
					var table = this.tables[tabId];
					this.currentBet += table.currentBet;
					table.currentBet = table.currentBet << 1;
					protoObj.bet = table.currentBet;
					protoObj.tabId = tabId;
					this.dispense(tabId);
					this.send(protoObj);
					this.putToEnd(tabId);
				break;
				case ServerConfig.C_STAND://stand		
					var tabId = data.tabId;
					var table = this.tables[tabId];
					if( table != null){
						table.actived = false;
					}
					this.send({code:0,proto:ServerConfig.S_R_STAND, tabId:tabId});
					this.putToEnd(tabId);
				break;
				case ServerConfig.C_LOGIN://double
					var user = data.user;
					var pass = data.pass;
					this.user = user;
					ServerConfig.Games[user] = this;
					
					
					send({code:0, proto:ServerConfig.S_R_LOGIN,money:10000});
							
					break;
				case ServerConfig.C_SPLIT://split
					var tabId = data.tabId;
					var rtable = this.tables[tabId];
					trace('Can Split:'+rtable.canSplit);
					if( rtable.canSplit){
						var tempBet = rtable.currentBet;
						this.currentBet += rtable.currentBet;
						var table = this.generateTable(tabId+3);
						this.currentTables.push(tabId+3);
						var tables = {};
						tables[table.tabId] = rtable.cards[1];
						tables[tabId] = rtable.cards[0];
						rtable.reset();
						rtable.currentBet = tempBet;
						rtable.actived = true;
						rtable.isSplited = true;
						rtable.addCard(tables[tabId]);
						table.actived = true;
						table.canSplit = false;
						table.addCard(tables[table.tabId]);
						table.currentBet = tempBet;
						this.send({code:0, proto:ServerConfig.S_R_SPLIT,tabId:tabId,tables:tables, bet:rtable.currentBet});
					}
					this.dispense(tabId);
					//this.dispense(tabId+3);
					if( rtable.blackjack){
						this.putToEnd(tabId);
					}
					/**
					if( table.blackjack ){
						this.putToEnd(tabId+3);
					}
					*/
				break;
				case ServerConfig.C_INSURRANCE://insurrance
					var tables = data.tables;
					if(this.bankerTable.cards.length == 2 && (this.bankerTable. cards[0] - 1)%13 + 1 == 1){
						var result = {};
						var total = 0;
						for (var i in tables){
							table = this.tables[tables[i]];
							var need = table.currentBet*0.5;
							if( this.bankerTable.blackjack ){
								total += need * 2;
								result[tables[i]] = need * 2;
							}else{
								total -= need;
								result[tables[i]] = -need;
							}
						}
						this.money += need;
						if( this.bankerTable.blackjack ){
							this.send({code:0, proto:ServerConfig.S_R_INSURE,result:result,isbj:true,card:this.fakeCard, money:this.money});
							this.fakeCard = -1;
							if( this.bankerTable.blackjack){
								while(this.currentTables.length != 0){
									this.putToEnd(this.currentTables.pop());
								}
								this.serverTurn();
							}
								
						}else{
							this.send({code:0, proto:ServerConfig.S_R_INSURE,result:result,isbj:false, money:this.money});
						}
						
					}else{
						this.send({code:ErrorCode.ErrorNoNeedInsure, proto:ServerConfig.S_R_INSURE});
					}
				break;
				case ServerConfig.C_SKIP_INSURRANCE:
					if( this.bankerTable.blackjack){
						while(this.currentTables.length != 0){
							this.putToEnd(this.currentTables.pop());
						}
						this.send({code:0, proto:ServerConfig.S_R_INSURE,result:null,isbj:true, card:this.fakeCard, money:this.money});
						this.fakeCard = -1;
						this.serverTurn();
					}else{
						this.send({code:0, proto:ServerConfig.S_R_INSURE,result:null,isbj:false, money:this.money});
					}
				break;
				default:
				trace('unknow operation from player : ', proto);
				break;
			}
		}
		public function putToEnd(tabId:int):void{
			var index = this.currentTables.indexOf(tabId);
			if( this.overTables.indexOf(tabId) == -1){
				this.overTables.push(tabId);
			}else{
				trace('already overed:'+tabId);
			}
			
			if( index != -1){
				this.currentTables.splice(index,1);
				trace('after end :'+tabId+" rest:"+this.currentTables.join(','));
			}else{
				trace('not in current :'+tabId);
			}
			
			if( this.currentTables.length == 0){
				this.serverTurn();
			}
		}
		
		public function send(data:Object):void{
			data.time = new Date().getTime();
			SocketMgr.Instance.accept(data);
			//this.client.send(JSON.stringify(data));
		}
	}

}