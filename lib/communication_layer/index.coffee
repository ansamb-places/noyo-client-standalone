SocketManager = require './SocketManager'
_ = require 'underscore'
_when = require 'when'


# conditions management
conditions = ['server_link:connected']
conditions_status = {}
conditions_queue = []
_.each conditions,(requirement)->
	conditions_status[requirement] = false

condition_check = (conditions)->
	return _.every(conditions,(cond)->conditions_status[cond])
conditions_change = ->
	to_remove = []
	_.each conditions_queue,(item,index)->
		conds = item.options._conditions
		if condition_check(conds) == true
			api.send item.message,item.options,item.cb
			to_remove.push index
	for index in to_remove
		conditions_queue.splice(index,1)

# readyToReceive lock
# while this var is not set to true, all incoming message will be queued
readyToReceive = false
incoming_queue = []
outgoing_queue = []
handleIncomingQueue = ->
	_.each incoming_queue,(message)->
		onIncomingMessage message
	incoming_queue = []
handleOutgoingQueue = ->
	_.each outgoing_queue,(item)->
		api.send item.message, item.options, item.cb
	outgoing_queue = []

### Private helpers ###
validateMessage = (message)->
	return _.isObject(message)
	#TODO implement message validation
	#return message.dpl and message.spl

incomingMessageHandler = null
onIncomingMessage = (m)->
	#TODO implement message validation
	unless validateMessage(m)
		return console.log "websocket:received an invalid message"
	
	if readyToReceive == false
		console.log "[INFO] Queue incoming message"
		return incoming_queue.push(m)

	throw new Error("No message handler defined") if incomingMessageHandler==null
	incomingMessageHandler(m)


socketManager = null
onConnectedCbs = []

api =
	connect:(options)->
		if !socketManager
			socketManager = new SocketManager(options)
			#listen to events
			socketManager.on 'incoming_message', onIncomingMessage
			socketManager.on 'connected',->
				api.readyToReceive()
				handleOutgoingQueue()
				if onConnectedCbs.length > 0
					cb() for cb in onConnectedCbs
					onConnectedCbs = []
			socketManager.on 'error',(error)->
				console.log 'Websocket error:',error
			return socketManager.init()
		else
			return socketManager.ready.promise
	onceConnected: (cb) ->
		if socketManager? and socketManager.connected == true
			cb()
		else
			onConnectedCbs.push cb
	setIncomingMessageHandler:(handler)->
		incomingMessageHandler = handler
	setOutgoingMessageHandler:(handler)->
		outgoingMessageHandler = handler
	getStatus:->
		return if socketManager.connected then "connected" else "disconnected"
	disconnect:->
		socketManager.close()
	send:(message,options,cb)->
		if _.isUndefined(cb) and _.isFunction(options)
			cb = options
			options = {}
		if socketManager == null or not socketManager.connected
			return outgoing_queue.push {message, options, cb}
		# check if conditions are met before sending packet to socket_manager
		if options._conditions == null or condition_check(options._conditions)
			socketManager.req_res_send message,options,cb
		else
			return cb?(new Error('conditions not met'), null) if options.queue == false
			console.log "[INFO] conditions to send packet are not met, queue the packet"
			conditions_queue.push({message:message,options:options,cb:cb})
	inject:(message)->
		onIncomingMessage message
	setConditionStatus:(name,status)->
		if conditions.indexOf(name) != -1
			unless _.isBoolean(status)
				return false
			if conditions_status[name] != status
				conditions_status[name] = status
				console.log "[INFO] Condition #{name} is now set to #{status}"
				conditions_change()
			return true
		else
			console.log "[INFO] Condition #{name} not found for com_layer"
			return false
	readyToReceive:->
		readyToReceive = true
		handleIncomingQueue()
	getSocketManager:->
		return socketManager

module.exports = api
