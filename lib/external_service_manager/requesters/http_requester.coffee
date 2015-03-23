_ = require 'underscore'
request = require 'request'

module.exports =
  protocol: 'HTTP'

  request: (uri, method, args, options, cb) ->
    [options, cb] = [{}, options] unless cb
    #TODO check all args are here
    req_options =
      uri: uri
      method: method
      strictSSL: false
    if _.isObject(options.auth)
      req_options.auth =
        user: options.auth?.login
        pass: options.auth?.password
        sendImmediately: true
    switch method
      when 'GET'
        req_options.qs = args
      when 'POST'
        req_options.json = args
    request req_options, (error, httpMessage, reply) ->
      return cb(error) if error?
      if httpMessage? then http_info = {http_code: httpMessage.statusCode}
      else return cb new Error('Request error (got no reply)')
      if Math.floor(httpMessage.statusCode / 100) == 2
        try
          if typeof reply == 'string' and reply.length > 0
            reply = JSON.parse reply
        catch e
          return cb new Error('Invalid JSON reply'), reply, http_info
      else if httpMessage.statusCode == 401
        return cb new Error('Unauthorized'), reply, http_info
      else
        return cb new Error("Request error (code #{httpMessage.statusCode})"), reply, http_info
      return cb null, reply, http_info
