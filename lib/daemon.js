var Transmission = require ('transmission')
var Torrent = require('./torrent.js');

tr = new Transmission({});

tr.get(function(err, arg) {
    for (var id in arg.torrents) {
        var torrent = new Torrent(arg.torrents[id]);
    console.log("torrent: ", torrent);
    }
});
