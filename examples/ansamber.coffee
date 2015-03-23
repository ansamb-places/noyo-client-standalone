api = require '../index'

module.exports = ->
	###
	# call this only after a successful register or login
	place =
		id: 'ec1b6b86-e6ed-4d9b-9683-59eb0422c794@ansamb_CgU_2DunXB6zW9k9ccbXfw'
		name: 'my place'
		type: 'share'
		desc: 'a simple test'
		owner_uid: 'ansamb_CgU_2DunXB6zW9k9ccbXfw'
		creation_date: 1421304560511
	uid = 'ansamb_cArQHhT8UNyyXmrlErb4CA'

	api.protoHelpers.ansamber.sendAnsamberRequestForPlace place, uid, (err, code) ->
		console.log err, code
		
	replyOptions =
		place_id:
			owner_uid: 'ansamb_CgU_2DunXB6zW9k9ccbXfw'
			add_request_id: '78236115-a38c-4afc-ac9f-095547743fb2'
			accepted: true
	api.protoHelpers.ansamber.sendAnsamberReplyForPlace replyOptions, (err, code) ->
		console.log err, code
	###