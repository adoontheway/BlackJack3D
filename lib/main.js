var game;
var w;
var h;
var bet_group;
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

  	game.load.image("chip1","resource/chips/chip-1.png");
  	game.load.image("chip2","resource/chips/chip-2.png");
  	game.load.image("chip5","resource/chips/chip-5.png");
  	game.load.image("chip10","resource/chips/chip-10.png");
  	game.load.image("chip50","resource/chips/chip-50.png");
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

	var startX = w - 5*75 >> 1;
	bet_group = game.add.group();
	var image = game.add.button(startX,625,'chip1',this.onChips1, this);
	bet_group.add(image);
	startX += 75;
	image = game.add.button(startX,625,'chip2', this.onChips2, this);
	bet_group.add(image);
	startX += 75;
	image = game.add.button(startX,625,'chip5', this.onChips5, this);
	bet_group.add(image);
	startX += 75;
	image = game.add.button(startX,625,'chip10', this.onChips10, this);
	bet_group.add(image);
	startX += 75;
	image = game.add.button(startX,625,'chip50', this.onChips50, this);
	bet_group.add(image);
}

function update(){
	console.log('game update');
}
function onChips1(){

}
function onChips2(){

}
function onChips5(){

}
function onChips10(){

}
function onChips50(){

}