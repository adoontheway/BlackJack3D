var game;
var w;
var h;
var pokers = [];
var dealer;
var me;
var dealerBoard;
var myBoard;
var playerMap = {};
var playing = false;
function run(){
	game = new Phaser.Game('100','100', Phaser.AUTO, '',{preload:preload, create:create, update:update});
}

function preload(){
  	console.log('game preload');
  	game.load.image("bg","resource/bg/bg.jpg");
  	game.load.image("desk","resource/bg/desk.png");

  	game.load.image("dispenser","resource/images/dispenser.png");
  	game.load.image("recycler","resource/images/recycle-bin.png");
  	game.load.image("chipBox","resource/images/chip-box.png");
  	game.load.image("table","resource/images/table-middle-over.png");

	game.load.image("btnDouble","resource/images/btn-double.png");
  	game.load.image("btnHit","resource/images/btn-hit.png");
  	game.load.image("btnRepeat","resource/images/btn-repeat.png");
  	game.load.image("btnSkip","resource/images/btn-skip.png");

  	game.load.image("chip1","resource/chips/chip-1.png");
  	game.load.image("chip2","resource/chips/chip-2.png");
  	game.load.image("chip5","resource/chips/chip-5.png");
  	game.load.image("chip10","resource/chips/chip-10.png");
  	game.load.image("chip50","resource/chips/chip-50.png");
  	var t_name;
  	var t_url;
  	for(var i = 100; i <= 400; i+=100){
  		for(var j = 1; j <=13; j++){
  			t_name =""+(i+j);
  			pokers.push(i+j);
  			t_url = "resource/pokers/"+t_name+".png"
  			game.load.image(t_name,t_url);
  		}
  	}
  	game.load.image("chip50","resource/pokers/back.png");
  	playerMap[0] = dealer = new Player(0);
  	playerMap[1] = me = new Player(1);
}
	
function create(){
	console.log('game create');
	var w = game.world.width;
	var h = game.world.height;
	var bg = game.add.sprite(0,0,'bg');
	bg.x = w - bg.width >> 1;
	var desk = game.add.sprite(0,0,'desk');
	desk.x = w - desk.width >> 1;
	
	var dispenser = game.add.image(w-200,-65,'dispenser');
	var recycler = game.add.image(0,-65,'recycler');
	var chipBox = game.add.image((w-200)*0.5,-10,'chipBox');

	var startX = w - 5*80 >> 1;
	var image = game.add.button(startX,625,'chip1',onChips1);
	startX += 80;
	image = game.add.button(startX,630,'chip2', onChips2);
	startX += 80;
	image = game.add.button(startX,635,'chip5', onChips5);
	startX += 80;
	image = game.add.button(startX,630,'chip10', onChips10);
	startX += 80;
	image = game.add.button(startX,625,'chip50', onChips50);

	var table = game.add.button(0,0,'table', onTable);
	table.x = w - table.width >> 1;
	table.y = ( h - table.height >> 1 )- 50;
	betChipY = table.y + 100;
	betChipX = table.x + 10;

	startX = w - 3*100 >> 1;
	var btnDouble = game.add.button(startX,500,'btnDouble', onDouble);
	startX+=100;
	var btnHit = game.add.button(startX,500,'btnHit', onHit);
	startX+=100;
	var btnSkip = game.add.button(startX,500,'btnSkip', onSkip);


	var style = { font: "36px Arial", fill: "#ffffff", align: "center" };
    dealerBoard = game.add.text(100, 120, "DEALER:0", style);
    myBoard = game.add.text(game.world.centerX, game.world.height-200, "PLAYER:0", style);

	shuffle();
	//var btnRepeat = game.add.button(0,0,'btnRepeat', this.onRepeat, this);
}

var currentPokerIndex = 0;
var pokerMap = {};

function update(){
	//console.log('game update');
}

function onDouble(){
	console.log('onDouble');
}

function onHit(){
	if( currentBet == 0){
		alert('Bet first please.');
		return;
	}
	if( me.stand || me.blackjack || me.bust){
		alert('You are in standing status');
		return;
	}
	
	playing = true;

	dispenseTo(1);

	if( me.bust || me.points == 21 || me.blackjack ){
		me.stand = true;
		dealerTurn();
	}
}

function onSkip(){
	console.log('onSkip');
	if( playing ){
		me.stand = true;
		dealerTurn();
	}else{
		cleanTheTable();
	}
}

function cleanTheTable(){
	//todo
	dealer.reset();
	me.reset();
}

function dispenseTo(playerId){
	var player = playerMap[playerId];
	var card = this.pokers[currentPokerIndex];
	player.addCard(card);
	currentPokerIndex++;
}

function dealerTurn(){
	while(dealer.points < 17){
		dispenseTo(0);
	}
	theEnd();
}

function theEnd(){
	playing = false;
}

function onTable(){
	if( chosenChip == 0){
		alert('no chip chosen');
		return;
	}
	currentBet += chosenChip;
	var ty = betChipY - betChips.length * 10;
	var chip = game.add.image(betChipX,ty,'chip'+chosenChip);
	betChips.push(chip);
}

var betChipX;
var betChipY;
var betChips = [];
var chosenChip = 0;
var currentBet = 0;

function onChips1(){
	chosenChip = 1;
}

function onChips2(){
	chosenChip = 2;
}

function onChips5(){
	chosenChip = 5;
}

function onChips10(){
	chosenChip = 10;
}

function onChips50(){
	chosenChip = 50;
}

function shuffle(times,scope) {
    times = times == undefined ? 15 : times;
    scope = scope == undefined ? 5 : scope;
    
    var index0;
    var index1;
    var len = pokers.length;
    var i = 0;
    var temp;
    var r0;
    var r1;
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
    //console.log('shuffle complete:'+pokers.join('.'));
};


var Player = function(id){
	this.id = id;
	this.cardStartX = game.world.centerX;
	this.cardY = id == 0 ? 300 : 550;
	this.cards = [];
	this.reset();
}

var radius10 = Math.PI / 18;
Player.prototype.addCard = function(card){
	var value = card%100;
	value = value <= 10 ? value : 10;
	this.hasA = this.hasA || value == 1;
	this.points += value;
	this.bust = this.points > 21;

	var poker = pokerMap[card];
	var tx = this.cardStartX ;
	var ty = this.cardY - 100 ;
	if( !poker){
		poker = game.add.image(tx, ty,''+card);
		poker.anchor.set(0,1);
		pokerMap[card] = poker;
	}else{
		poker.x = tx;
		poker.y = ty;
		game.world.add(poker);
	}

	this.cards.push(card);
	poker.rotation = 0;

	if( this.cards.length > 1){
		this.reOrderPokers();
	}

	this.blackjack = this.cards.length == 2 && this.points == 11; 
	this.stand = false;
	var board = this.id == 0 ? dealerBoard : myBoard;
	var prefixStr = this.id == 0 ? 'DEALER:' : 'PLAYER:';
	if( this.hasA && this.points < 11){
		board.text = prefixStr+this.points+'/'+(this.points+10);
	}else{
		if( !this.hasA || (this.hasA && this.points + 10 > 21) )
			board.text = prefixStr+this.points;
		else
			board.text = prefixStr+(this.points + 10);
	}
}

Player.prototype.reOrderPokers = function(){
	var card;
	var poker;
	var angel;
	var tx;
	var ty;
	var len = this.cards.length;
	var startAngel = len * -5;
	var radius;
	for(var i = 0; i < len; i++){
		card = this.cards[i];
		radius = startAngel*Math.PI/180;
		poker = pokerMap[card];
		angel = radius;
		poker.x = this.cardStartX + 100 * Math.sin(angel);
		poker.y = this.cardY - 100 * Math.cos(angel);
		poker.rotation = radius;
		startAngel+=10;
	}
}

Player.prototype.reset = function(){
	this.points = 0;
	this.bust = false;
	this.blackjack = false;
	this.hasA = false;
	this.stand = false;
	var card;
	var poker;
	while(this.cards.length != 0){
		var card = this.cards.pop();
		var poker = pokerMap[card];
		game.world.remove(poker);
	}
}