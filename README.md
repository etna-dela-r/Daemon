Daemon
======

Small POC, only working on localhost currently, on port 8080.

Routes
------
2 routes available :
GET /torrents (get all torrents)
GET /torrents/:id

Responses Format
----------------
Exemple:
  {
    "id": 1,
    "name": "A very cool name for a very cool file",
    "total_size": 4108725845,
    "dl_size": 4109155750,
    "dl_rate": 0,
    "status": "SEED",
    "added_date": 1371333730
  }


Installation
------------
  git clone https://github.com/etna-bertra-n/Daemon
  cd Daemon
  npm install

Running it
----------
  cd Daemon
  node .
