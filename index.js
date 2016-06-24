var express = require('express');
var app = express();

app.use('/',express.static('./bin/'));

app.listen(process.env.PORT || 3001);
/**
var users = {};
app.use('/login', function(req, res){
	var user = req.query('user');
	var pass = req.query('pass');
	if( users[user] !== undefined && users[user] === pass){
		res.write({code:0, time:new Date().time});
	}else{
		res.write({code:1, time:new Date().time});
	}
});
*/