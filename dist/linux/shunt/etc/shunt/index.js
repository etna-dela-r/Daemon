require("coffee-script")

var app = require('./lib/main.coffee');
var http = require('http');
var server = http.createServer(app);

server.listen(8000, function() {
    console.log("Express server listening on port ", server.address().port);
});
