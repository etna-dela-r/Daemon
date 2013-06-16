var http = require('http');
var Transmission = require ('transmission')
var express = require('express');

var Torrent = require('./torrent.js');

var tr = new Transmission({});
 
// Torrent API
function get_all_torrent(req, res) {
    tr.get(function(err, arg) {
        if (err) {
            console.error(err);
        } else {
            var torrents = new Array();
            for (var id in arg.torrents) {
                torrents.push(new Torrent(arg.torrents[id]));
            }
            console.log("Total torrents found: ", torrents.length);
            console.log("Response: ", torrents);
            res.send(torrents);
        }
    });
}

function get_torrent(req, res) {
    var id = +req.params.id; // unary + coz id must be an integer
    tr.get(id, function(err, arg) {
        if (err) {
            console.error(err);
        } else {
            var torrents = new Array();
            for (var id in arg.torrents) {
                  torrents.push(new Torrent(arg.torrents[id]));
            }
            var torrent = torrents[0];
            console.log("Response: ", torrent);
            res.send(torrent);
        }
    });
}

var server = new express();

// routes
server.get('/torrents', get_all_torrent);
server.get('/torrents/:id', get_torrent);

server.listen(8080);
console.log("Starting server on port 8080...");
