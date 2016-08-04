var game;
var w;
var h;
function run(){
	game = new Phaser.Game('100','100', Phaser.AUTO, '',{
		preload : function(){
		  	console.log('game preload');
		  	game.load.image("bg","resource/bg/bg.jpg");
		  	game.load.image("desk","resource/bg/desk.png");
		},
		create : function(){
			console.log('game create');
			var w = game.world.width;
			var h = game.world.height;
			var bg = game.add.sprite(0,0,'bg');
			bg.x = w - bg.width >> 1;
			var desk = game.add.sprite(0,0,'desk');
			desk.x = w - desk.width >> 1;
		},
		update : function(){
			console.log('game update');
		}
	});
}