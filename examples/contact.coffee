api = require '../index'

module.exports = ->
	
	alias = 
		alias: 'email2@ok.com'
		type: 'email'
	api.protoHelpers.contact.searchContactOnServer alias, (err, contact) ->
		console.log err, contact
	
	# call this only after a successful register or login
	api.protoHelpers.contact.sendRequest {
		uid: 'ansamb_cArQHhT8UNyyXmrlErb4CA'
		message: 'do you want to build a snowman ?'
	}, (err, sent) ->
		console.log err, sent
	
	api.protoHelpers.contact.sendReply {
		uid: 'ansamb_cArQHhT8UNyyXmrlErb4CA'
		message: 'do you want to build a snowman ?'
		accepted: true
		ref_id: 'a2ff44d2-d4cd-4768-b333-9548ac8e9733'
	}, (err, sent) ->
		console.log err, sent
	
	api.protoHelpers.contact.removeContactByUid 'ansamb_cArQHhT8UNyyXmrlErb4CA', (err, sent) ->
		console.log err, sent
	

