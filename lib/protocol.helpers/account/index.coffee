passwordHash = require './passwordHash'
protoBuilder = require '../../protocol.builder'
external_service_manager = require '../../external_service_manager'
_ = require 'underscore'

hashedPassword = null
uid = null
waitingCbForUid = []
logged = false

code =
  accepted: 202
  bad_request: 400
  conflict: 409 #account already exists
  pending: 460 #account already created and awaiting validation
  ok: 200
  not_found: 404
messages =
  '202': 'Account created'
  '400': 'Bad request'
  '409': 'An account already exists'
  '460': 'The request for this account is waiting for validation'
  '200': 'Account validated'
  '404': 'The registration request was not found'

module.exports = api =
  isLogged: ->
    return logged
  getAccount: (cb) ->
    #profile is the content_id which refers to the user profile document
    protoBuilder.account.getRequest().send (err,reply) =>
      if err == null
        if reply.data.content != null and reply.data.content != 'undefined'
          account = reply.data.content
          @setUid account.data.uid
        else
          account = null
      cb(err,account)
  setHashedPassword: (p) ->
    hashedPassword = p
  getHashedPassword: ->
    return hashedPassword
  getUid: ->
    throw new Error 'Uid is not defined' unless uid?
    return uid
  getUidAsync: (cb) ->
    return unless _.isFunction(cb)
    if uid?
      cb(uid)
    else
      waitingCbForUid.push cb
  setUid: (_uid) ->
    uid = _uid
    if waitingCbForUid.length > 0
      cb uid for cb in waitingCbForUid when _.isFunction cb
      waitingCbForUid = []
  register: (data, alias_options, cb) ->
    if _.isUndefined cb
      cb = alias_options
      alias_options = null
    # hashed password used to request services and remote APIs
    local_pwd_obj = passwordHash.generateSaltAndHashPasswordSync(data.password)
    remote_pwd_obj = passwordHash.generateSaltAndHashPasswordSync(data.password)
    #we save the hashed password intended for the accout hoster in order to use remote APIs later
    @setHashedPassword remote_pwd_obj.value
    #hash the password twice, once for the kernel and once for the server
    data.password =
      local: local_pwd_obj
      remote: remote_pwd_obj
    if not alias_options or not alias_options.field_name or not alias_options.type
      return cb 'Alias options are missing'
    if data[alias_options.field_name] and typeof data[alias_options.field_name] == 'string'
      alias = data[alias_options.field_name]
      type = alias_options.type
      delete data[alias_options.field_name]
      data.aliases = [{
        alias: alias
        type: type
      }]
    else
      return cb 'Wrong alias'
    protoBuilder.account.registerRequest(data).send {timeout:15000}, (err,reply) =>
      if err?
        console.error err
        return cb err
      _code = reply.code
      if _code == code.accepted
        account = reply.data.account
        @setUid account.data.uid
        cb null, account
      else
        console.error "Error:receive code #{reply.code}"
        errorMessage = reply?.data?.desc || messages[''+_code] || "Unknwon error (code #{_code})"
        cb(errorMessage, null)
  login: (clearPassword, cb) ->
    @getAccount (err,account) =>
      return cb err if err?
      return cb 'No account' if account == null
      local_password = passwordHash.hashPassword(clearPassword,account.data.password.local.salt)
      ah_password = passwordHash.hashPassword(clearPassword,account.data.password.ah.salt)
      protoBuilder.account.authRequest({local:local_password,ah:ah_password}).send (err,reply) =>
        return cb err if err?
        reply_code = reply.code
        if reply_code == code.ok
          logged = true
          @setUid account.data.uid
          @setHashedPassword ah_password
          cb null,true
        else
          cb null,false
  resendCode: (cb) ->
    @getAccount (err, account) =>
      return cb err if err
      return cb 'No account' if account == null or _.isUndefined account

      if account.data.aliases
        allAliases = _.values account.data.aliases
      else
        allAliases = []
      if _.isArray(allAliases) && allAliases.length > 0
        firstAlias = allAliases[0]
        key = "#{firstAlias.type}/#{firstAlias.alias}"
        args = {a: key}
        service_options =
          auth:
            login: @getUid()
            password: @getHashedPassword()
        external_service_manager.requestService 'resend_code', args, service_options, (err,reply) ->
          return cb err if err
          return cb null, reply

      else
        return cb 'Invalid alias or no alias found'
  reset: (cb) ->
    protoBuilder.account.accountReset().send (err,reply) ->
      if err?
        cb err, null
      else
        if reply.code == code.ok
          logged = false
          api.setHashedPassword null
          cb null, {code:reply.code}
        else
          cb reply.desc || "Unknown error", {code:reply.code}
  registrationRetry: (cb) ->
    protoBuilder.account.registrationRetry().send {timeout:10000}, (err, reply) =>
      return cb err if err?
      _code = reply.code
      if _code == code.accepted
        account = reply.data.account
        @setUid account.data.uid
        cb null, account
      else
        errorMessage = reply?.data?.desc || messages[''+_code] || "Unknwon error (code #{_code})"
        cb errorMessage, null

