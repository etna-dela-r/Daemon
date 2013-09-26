Daemon
======

Small POC, only working on localhost currently, on port 8000.
Using Basic auth for authentication.

Routes
------
2 routes available :

GET /torrents

POST /torrents (torrent: url of the torrent)

GET /torrents/:id

DELETE /torrents/:id

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
