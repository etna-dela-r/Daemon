express = require("express")
passport = require("passport")
BasicStrategy = require("passport-http").BasicStrategy

#
# User persistence
# 
Datastore = require('nedb')
db = 
    users: new Datastore
        filename:"users.db"
        autoload: true
    servers: new Datastore
        filename:"servers.db"
        autoload: true

# Create a user if none exists
db.users.findOne { _id: { $exists: true } }, (err, doc) ->
    unless doc
        db.users.insert 
            login: "shunt"
            password: "secret",

#
# Auth (using Basic for the time being)
#
passport.use new BasicStrategy({}, (login, password, done) ->
    process.nextTick ->
        db.users.findOne login: login, (err, user) ->
            return done(err) if err
            return done(null, false) unless user
            return done(null, false) unless user.password is password
            done null, user
)

#
# utils and middleware
#

# used as a route middleware
ensureAuthentication = passport.authenticate("basic" , session: false)

# last non-error-handling middleware used, we assume 404
notFound = (req, res, next) ->
    res.send 404
    
logErrors = (err, req, res, next) ->
    console.error err
    next err

errorHandler = (err, req, res, next) ->
    code = err.status || 500
    code = 500 if code < 400
    res.send code,
        error: err

#
# middleware uses
#
app = express()

app.configure ->
    app.use express.logger()
    app.use express.methodOverride()
    app.use express.bodyParser()
    app.use passport.initialize()
    app.use app.router
    app.use notFound
    app.use logErrors
    app.use errorHandler

#
# Tr daemon
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
app.get '/torrents', ensureAuthentication, (req, res, next) ->
        tr.get (err, result) ->
            next(err) if err
            torrents = (new Torrent(result.torrents[id]) for id of result.torrents)
            res.send torrents

app.post '/torrents', ensureAuthentication, (req, res, next) ->
        torrent = req.body.torrent
        tr.add torrent, (err, result) ->
            next(err) if err
            res.send 200
                
app.get '/torrents/:id', ensureAuthentication, (req, res, next) ->
        id = +req.params.id
        tr.get id, (err, result) ->
            next() unless result.torrents.length
            next(err) if err
            torrents = (new Torrent(result.torrents[id]) for id of result.torrents)
            res.send torrents[0]

app.get '/torrents/:id/start', ensureAuthentication, (req, res, next) ->
        id = +req.params.id
        tr.start id, (err, result) ->
            next(err) if err
            res.send result.torrent

app.get '/torrents/:id/startNow', ensureAuthentication, (req, res, next) ->
        id = +req.params.id
        tr.startNow id, (err, result) ->
            next(err) if err
            res.send result.torrent

app.get '/torrents/:id/stop', ensureAuthentication, (req, res, next) ->
        id = +req.params.id
        tr.stop id, (err, result) ->
            next(err) if err
            res.send result.torrent

app.delete '/torrents/:id', ensureAuthentication, (req, res, next) ->
        id = +req.params.id
        # do not remove local datas
        tr.remove id, false, (err, result) ->
            next(err) if err
            res.send 200

#
# Start listening
#
http = require('http')

server = http.createServer(app)
server.listen 8000, () ->
    console.log "Express server listening on port ", server.address().port
