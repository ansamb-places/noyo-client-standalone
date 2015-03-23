_ = require 'underscore'
accountHelper = require '../account'
protoBuilder = require '../../protocol.builder'
external_service_manager = require '../../external_service_manager'

module.exports = api =
  code:
    ok: 202

  ###
  @alias =
    alias: string
    type: string
  ###
  searchContactOnServer: (alias, cb) ->
    return cb 'Invalid alias object' if not _.isObject(alias)
    key = "#{alias.type}/#{alias.alias}"
    args = {a: key}

    try
      service_option =
        auth:
          login: accountHelper.getUid()
          password: accountHelper.getHashedPassword()
    catch e
      return cb e

    external_service_manager.requestService 'alias_search',args, service_option, (err,reply) ->
      return cb err if err?
      c = reply?.data
      cb null, c || null

  ###
  @requestOptions =
    uid: string
    message: string
  ###
  sendRequest: (requestOptions, cb) ->
    protoBuilder.contact.addContactRequest(requestOptions).send (err, reply) ->
      return cb err, false if err?
      code = reply.code
      if code == code.ok
        err = null
      else
        err = reply.desc || 'Unknown error'
      cb err, code == api.code.ok

  addRequestWithCondResp: (requestOptions, convAddAnsamberRequest, cb) ->
    protoBuilder.contact.addContactRequest(requestOptions).addCondResp {code: 200}, [convAddAnsamberRequest]
    .send (err, reply) ->
      return cb err, false if err?
      code = reply.code
      if code == code.ok
        err = null
      else
        err = reply.desc || 'Unknown error'
      cb err, code == api.code.ok

  ###
  @replyOptions =
    uid: string
    message: string
    ref_id: string
    accepted: bool
  ###
  sendReply: (replyOptions, cb) ->
    protoBuilder.contact.addContactReply(replyOptions).send (err, reply) ->
      ### NEVER EXECUTE
      return cb err, false if err?
      code = reply.code
      if code == code.ok
        err = null
      else
        err = reply.desc || 'Unknown error'
      cb err, code == api.code.ok
      ###
    cb null, true

  ###
  @uid: string
  ###
  removeContactByUid: (uid, cb) ->
    protoBuilder.contact.removeContact({uid: uid}).send (err,reply) ->
      return cb err if err?
      if reply?
        if reply.code == 200
          cb null, reply.code
        else
          cb reply.desc || "Unknwon error (code #{reply.code})"
      else
        cb "No reply"

  syncContactStatus: ->
    protoBuilder.contact.syncStatus().send()
    
