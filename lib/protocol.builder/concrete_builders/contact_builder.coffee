_ = require 'underscore'
fs = require 'fs'
common =
	ver:1
	protocol:'contact'
	spl:'ansamb.contact'
	dpl:'ansamb.contact'
module.exports =
	name:'contact'
	api:
		addContactRequest:(data)->
			message = _.extend
				method:'ADD'
				content_type:'message'
				dst:data.uid
				data:
					message:data.message
					public_key:data.public_key
			,common
			return message
		addContactReply:(data)->
			message = _.extend
				method:'ADD'
				content_type:'message'
				dst:data.uid
				ref_id:data.ref_id
				code:if data.accepted==true then 200 else 470
				data:
					message:data.message
			,common
		removeContact:(data)->
			_.extend
				method:'REMOVE'
				dst:data.uid
			,common
		checkContact:(data)->
			_.extend
				method:'EXISTS'
				dst:'ansamb'
				data:
					uid:data.uid
			,common
		syncStatus:->
			_.extend
				method:'SYNC_STATUS'
				dst:'ansamb'
			,common
		getNoyoContacts:(data)->
			_.extend
				method:'LIST'
				dst:'ansamb'
			,common
