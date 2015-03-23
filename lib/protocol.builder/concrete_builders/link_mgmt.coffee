#this protocol is used to manage the link with the server (through noyo)
_ = require 'underscore'
common = 
	ver:1
	protocol:'link_mgmt'
	src:'local'
	dst:'local'
	spl:'local'
	dpl:'local'
module.exports = 
	name:'link_mgmt'
	api:
		getStatus:->
			_.extend
				method:'STATUS_GET'
			,common
		connect:(data)->
			_.extend
				method:'CONNECT'
				data:
					timeout:data?.timeout||0
			,common