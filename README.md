Daemon
======

Small POC, only working on localhost currently, on port 8000.
Using Basic auth for authentication.

Routes
------
2 routes available :

GET /torrents List torrents

POST /torrents Add a new torrent (torrent: url of the torrent)

GET /torrents/:id Get torrent current state

GET /torrents/:id/start Start the torrent

GET /torrents/:id/startNow Byoass the download queue and start the torrent immediatly

GET /torrents/:id/stop Stop the torrent

DELETE /torrents/:id Delete the torrent

Responses Format
----------------
Exemple:
```json
{
	"id": 1,
	"name": "A very cool name for a very cool file",
	"total_size": 4108725845,
	"dl_size": 4109155750,
	"dl_rate": 0,
	"status": "SEED",
	"added_date": 1371333730
}
```


Installation
------------
	git clone https://github.com/etna-bertra-n/Daemon
	cd Daemon
	npm install

Running it
----------
	cd Daemon
	node .
