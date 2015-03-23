# this file demonstrate how to use the provided API

api = require '../index'
profileName = api.profileName = process.env.PROFILE
localSettings = api.localSettings = api.utils.getLocalSettings(profileName)

socketOptions =
	host: 'localhost'
	port: localSettings.gui_port
	uri: '/connection/gui/'
	token: localSettings.gui_auth_token

PASSWORD = 'coucoucmoi'

onSocketReady = ->
	# HERE YOU CAN INTERACT WITH THE KERNEL
	###
	Examples:
		login:
			login = require './login'
			login()
		# Need timeout fo be sure you are logged when using function
		setTimeout ->
			#Your function to test here
		,5000
	###

	login = require './login'
	login()

messageHandler = (message) ->
	console.log 'Received message -----> ', message

api.comLayer.setMessageHandler messageHandler
api.comLayer.connect(socketOptions).done onSocketReady