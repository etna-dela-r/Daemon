express = require("express")
passport = require("passport")
BasicStrategy = require("passport-http").BasicStrategy

#
# Real persistence is for another day
# 
users = [
  id: 1
  login: "shunt"
  password: "secret"
]

findUser = (login, cb) ->
  i = 0
  len = users.length

  while i < len
    u = users[i]
    return cb(null, u)  if u.login is login
    i++
  cb null, null

passport.use new BasicStrategy({}, (login, password, done) ->
  process.nextTick ->
    findUser login, (err, user) ->
      return done(err) if err
      return done(null, false) unless user
      return done(null, false) unless user.password is password
      done null, user
)

app = express()

app.configure ->
    app.use express.logger()
    app.use express.bodyParser()
    app.use passport.initialize()
    app.use app.router

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
 
on_error = (err, res, next) ->
    console.error err
    res.statusCode = 500
    next new Error(err)

not_found = (res) ->
    res.statusCode = 404
    res.send


app.get '/torrents',
    passport.authenticate("basic", session: false),
    (req, res, next) ->
        tr.get (err, result) ->
            on_error err, res, next if err
            torrents = (new Torrent(result.torrents[id]) for id of result.torrents)
            res.send torrents

app.post '/torrents/',
    passport.authenticate("basic", session: false),
    (req, res, next) ->
        torrent = req.body.torrent
        tr.add torrent, (err, result) ->
            error err, res, next if err
            tr.get id (_e, _r) ->
                on_error _e, next if _e
                torrents = (new Torrent(_r.torrents[id]) for id of _r.torrents)
                res.send torrents[0]
                

app.get '/torrents/:id',
    passport.authenticate("basic", session: false),
    (req, res, next) ->
        id = +req.params.id
        tr.get id, (err, result) ->
            on_error err, res, next if err
            not_found res unless result.torrents.length
            torrents = (new Torrent(result.torrents[id]) for id of result.torrents)
            res.send torrents[0]

app.delete '/torrents/:id',
    passport.authenticate("basic", session: false),
    (req, res, next) ->
        id = +req.params.id
        tr.remove id, (err, result) ->
            on_error err, res, next if err

#
# Start listening
#
http = require ('http')

server = http.createServer(app)
server.listen 8000
console.log "Express server listening on port ", server.address().port
