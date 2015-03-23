_ = require 'underscore'
ZSchema = require 'z-schema'
validator = new ZSchema sync: true
#encapsulate the message to provide a network object
uuid = require 'node-uuid'
class NetworkDecorator
  constructor: (@communication_layer, @builder, @name, @message, @_conditions) ->
    @message.message_id = uuid.v4()
  send: (options, cb) ->
    if _.isUndefined(cb) and _.isFunction(options)
      cb = options
      options = {}
    options ?= {}
    options = _.extend options, {_conditions: @_conditions ? null}
    if @builder?.schema? and @builder.schema[@name] and not validator.validate @message,@builder.schema[@name]
      return cb 'Invalid JSON schema',null
    @communication_layer.send @message,options,cb
  getMessageId: ->
    return @message.message_id
  addCondResp: (filter, actions) ->
    if typeof @message.cond_resp == 'undefined'
      @message.cond_resp = []
    # turn actions from an array to an object indexed by messageId
    if _.isArray actions
      _actions = {}
      _actions[a.message_id] = a for a in actions
      actions = _actions
    @message.cond_resp.push {
      filter
      actions
    }
    return this
  getMessage: ->
    return @message
#this function will encapsulate all methods of the given object
#and call the NetworkDecorator
module.exports = (communication_layer, builder) ->
  new_object = {}
  for name,f of builder.api
    ((name,f) ->
      new_object[name] = ->
        obj = f.apply(null,arguments)
        if obj.message and obj._conditions
          message = obj.message
          _conditions = obj._conditions
        else
          message = obj
          _conditions = null
        new NetworkDecorator(
          communication_layer,
          builder,
          name,
          message,
          _conditions
        )
    )(name,f)
  return new_object