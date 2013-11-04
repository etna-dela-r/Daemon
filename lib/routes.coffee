passport = require("passport")

##
# TODO : move Transmission and all in a torrentService
#

Transmission = require ('transmission')
tr = new Transmission({})

Status = [
    "STOPPED",
    "CHECK_WAIT",
    "CHECK",
    "DOWNLOAD_WAIT",
    "DOWNLOAD",
    "SEED_WAIT",
    "SEED",
    "ISOLATED"
]

Torrent = (torrent) ->
    @id = torrent.id
    @name = torrent.name
    @total_size = torrent.totalSize
    @dl_size = torrent.downloadedEver
    @dl_rate = torrent.rateDownload
    @status = Status[torrent.status]
    @added_date = torrent.addedDate


#
# Routes
#

module.exports = (app, auth) ->

    app.get '/torrents', auth, (req, res, next) ->
            tr.get (err, result) ->
                next(err) if err
                torrents = (new Torrent(result.torrents[id]) for id of result.torrents)
                res.send torrents

    app.post '/torrents', auth, (req, res, next) ->
            torrent = req.body.torrent
            tr.add torrent, (err, result) ->
                next(err) if err
                res.send 200
                    
    app.get '/torrents/:id', auth, (req, res, next) ->
            id = +req.params.id
            tr.get id, (err, result) ->
                next() unless result.torrents.length
                next(err) if err
                torrents = (new Torrent(result.torrents[id]) for id of result.torrents)
                res.send torrents[0]

    app.get '/torrents/:id/start', auth, (req, res, next) ->
            id = +req.params.id
            tr.start id, (err, result) ->
                next(err) if err
                res.send result.torrent

    app.get '/torrents/:id/startNow', auth, (req, res, next) ->
            id = +req.params.id
            tr.startNow id, (err, result) ->
                next(err) if err
                res.send result.torrent

    app.get '/torrents/:id/stop', auth, (req, res, next) ->
            id = +req.params.id
            tr.stop id, (err, result) ->
                next(err) if err
                res.send result.torrent

    app.delete '/torrents/:id', auth, (req, res, next) ->
            id = +req.params.id
            # do not remove local datas
            tr.remove id, false, (err, result) ->
                next(err) if err
                res.send 200
