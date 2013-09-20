
###
Module dependencies
###

express 	= require 'express'
app 		= module.exports = express.createServer()

RedisStore 	= require('connect-redis')(express)

csrf       	= require 'express-csrf'

couchdb    	= require 'felix-couchdb'
client    	= couchdb.createClient 5984, 'localhost'
db		= client.db 'blahblahblah-devel'

hash		= require 'node-hash'
###
Configuration
###

app.dynamicHelpers({
	csrf: csrf.token
})
app.dynamicHelpers({
	flash: (req) ->
		flash = req.flash()
		return flash
})
app.dynamicHelpers({
	current_user: (req) -> req.session.user
})

app.configure(() ->
  app.set 'views', "#{__dirname}/views"
  app.use express.logger()
  app.use express.bodyParser()
  app.use express.cookieParser()
  app.use express.session({
    store: new RedisStore({
      maxAge: 24 * 60 * 60 * 1000
    })
    secret: "superblahblah"
  })
  app.use csrf.check()
  app.use app.router
  app.use express.methodOverride()
  app.use express.static("#{__dirname}/public")
)

app.configure 'development', () ->
	app.use express.errorHandler({
		dumpExceptions: true
		showStack     : true
	})
	
app.configure 'production', () ->
	app.use express.errorHandler()
###
ROUTE: ROOT '/' (GET)
###
app.get '/', (req, res) ->
	if req.session.user
		req.flash 'success', "Authenticated as #{req.session.user.name}"
		res.redirect '/dashboard'

	res.render 'index.jade',
		locals:
			title: 'Home'
###
ROUTE: DASHBOARD '/dashboard' (GET, POST)
###
app.get '/dashboard', (req, res) ->
	if req.session.user
		res.render 'dashboard/index.jade',
			locals:
				title: 'Dashboard'
	else
		res.redirect '/login'

app.post '/dashboard', (req, res) ->
	params = req.body
	if req.session.user
		user = req.session.user
		console.log params
	else
		res.redirect '/login'
###
ROUTE: LOGIN '/login' (GET, POST)
###
app.get '/login', (req, res) ->
	if req.session.user
		req.flash 'success', "Authenticated as #{req.session.user.name}"
		res.redirect '/dashboard'

	res.render 'index.jade',
		locals:
			title: 'Login'
			
app.post '/login', (req, res) ->
	params = req.body
	if params.commit.login
		db.getDoc params.user.name, (e, doc) ->
			if e
				req.flash 'error', 'User does not exist!'
				res.redirect '/login'
			if doc
				salt = "superblahblah--#{params.user.password}"
				salted_password = hash.sha1 params.user.password, salt
				
				if doc.password is salted_password
					req.session.regenerate(() ->
						req.session.user = params.user
						res.redirect '/dashboard'
					)
				else
					res.redirect '404'
	else if params.commit.signup
		res.redirect '/signup'
###
ROUTE: LOGOUT '/logout' (GET)
###
app.get '/logout', (req, res) ->
	req.session.destroy(() ->
		res.redirect '/'
	)
	
###
ROUTE: SIGNUP '/signup' (GET, POST)
###
app.get '/signup', (req, res) ->
	if req.session.user
		req.flash 'success', "Autenticated as #{req.session.user.name}"
		res.redirect '/dashboard'
		
	res.render 'users/signup.jade',
		locals:
			title: 'Signup'
			username: ''
			password: ''
			password_confirmation: ''
			email: ''

app.post '/signup', (req, res) ->
	params = req.body
	errors = []
	salt 	 = "superblahblah--#{params.user.password}"
	salted_password = hash.sha1 params.user.password, salt
	salted_confirm_password = hash.sha1 params.user.password_confirmation, salt
	
	user =
		name: params.user.name
		password: salted_password
		email: params.user.email
	confirm_password = salted_confirm_password

	create_user = () ->
		db.exists (e,c) ->
			if c is true
				db.saveDoc user.name, couchdb.toJSON(user), (e,c) ->
					if e
						req.flash 'error', "Document update conflict. This user exists!"
						res.redirect 'back'
					if c
						req.flash 'success', "SUCCESS"
						req.session.regenerate(() ->
							req.session.user = params.user
							res.redirect '/dashboard'
						)
	if errors.length > 0
		errors.forEach (err) ->
			req.flash 'error', err
		res.render 'users/signup.jade',
			locals:
				title: "Signup"
				username: user.name
				password: ""
				password_confirmation: ""
				email: user.email
	else
		create_user()




###
NOW THIS IS UGLY
###

Transmission = require ('transmission')
tr = new Transmission({})

Status = ->
    @get = [
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
    @id = torrent.id;
    @name = torrent.name;
    @total_size = torrent.totalSize;
    @dl_size = torrent.downloadedEver;
    @dl_rate = torrent.rateDownload;
    @status = new Status().get[torrent.status];
    @added_date = torrent.addedDate;
 
app.get '/torrents', (req, res) ->
    tr.get (err, arg) ->
        if err
            console.error err
        else
            torrents = new Array()
            for id of arg.torrents
                torrents.push new Torrent(arg.torrents[id])
            console.log "Total torrents found: ", torrents.length
            console.log "Response: ", torrents
            res.send torrents

app.get '/torrents/:id', (req, res) ->
    id = +req.params.id
    tr.get id, (err, arg) ->
        if err
            console.error err
        else
            torrents = new Array()
            for id of arg.torrents
                  torrents.push new Torrent(arg.torrents[id])
            torrent = torrents[0]
            console.log "Response: ", torrent
            res.send torrent

app.listen 8000
console.log "Express server listening on port #{app.address().port}"
