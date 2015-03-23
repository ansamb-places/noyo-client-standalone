async = require 'async'
_ = require 'underscore'
_when = require 'when'
path = require 'path'
fs = require 'fs'
ServiceRequester = require './ServiceRequester'

services =
  "alias_search":
    "uri": "https://api.ansamb.com/alias/search/"
    "method": "HTTP:GET"
    "params":
      "a":
        "desc": "alias to search"
        "type": "string"
    "return":
      "desc": "results"
      "type": "object"
    "auth": 1
    
  "resend_code":
    "uri": "https://api.ansamb.com/service/_r/"
    "method": "HTTP:GET"
    "params":
      "a":
        "desc": "alias"
        "type": "string"
    "return":
      "desc": "true|false"
      "type": "object"
    "auth": 1

credentials = null

module.exports = api =

  setAuthCredentials: (login, password) ->
    credentials =
      login: login
      password: password

  getAuthCredentials: ->
    return credentials

  requestService: (name, args, options, cb) ->
    if _.isUndefined(cb)
      cb = options
      options = {}
    if services.hasOwnProperty(name)
      auth = options.auth || credentials || null
      if auth == null
        return cb "No auth credentials"
      ServiceRequester services[name],auth,args,cb
    else
      cb "Service not found"

  
