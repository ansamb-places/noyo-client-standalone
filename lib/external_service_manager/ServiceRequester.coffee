_ = require 'underscore'
request = require 'request'
path = require 'path'
fs = require 'fs'

alias =
  'method': 'method'
  'params': 'params'
  'uri': 'uri'
  'return': 'return'
  'auth': 'auth'


# Load all protocol requester
requesters = {}
requesters_path = path.join __dirname, 'requesters'
files = fs.readdirSync requesters_path
_.each files, (file) ->
  ext = file.split('.').pop()
  return if ext != 'js'
  try
    m = require path.join(requesters_path,file)
    if _.isObject(m) and _.isString(m.protocol) and _.isFunction(m.request)
      requesters[m.protocol] = m.request
    else console.log 'INFO: invalid requester detected into external_service_manager'
  catch e
    console.log 'INFO: failed to load a service requester into external_service_manager'

# @service = object
# @auth = {user:login, password:string}
# @args = {key:value}
module.exports = (service, auth, args, cb) ->
  required_args = _.keys service[alias.params]

  # Check if all requirements are met to use the service
  if _.filter(_.keys(args), (item) -> required_args.indexOf(item) != -1)?.length != required_args.length
    return cb new Error('Bad arguments'), null
  if service[alias.auth] == 1 and auth == null
    return cb new Error('Missing credentials'), null

  # Define service parameters
  uri = service[alias.uri]
  method = service[alias.method]
  if method.indexOf ':'
    # Method is in fact protocol:method so we have to parse it
    parsed = method.split ':'
    if parsed.length == 2
      protocol = parsed[0]
      method = parsed[1]
    else
      return cb new Error('Wrong service method'), null
  else
    protocol = method
    method = null

  _r = requesters[protocol]
  if _.isFunction(_r) then _r uri, method, args, {auth: auth}, cb
  else return cb new Error('Protocol not supported'), null
