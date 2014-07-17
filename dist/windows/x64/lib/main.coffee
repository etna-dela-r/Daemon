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
auth = passport.authenticate("basic" , session: false)

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
# Routes
#
routes = require './routes'
routes app, auth

module.exports = app
