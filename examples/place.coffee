api = require '../index'

module.exports = ->

	###
	# call this only after a successful register or login
	api.protoHelpers.place.create {
		name: 'my place'
		desc: 'a simple test'
		type: api.protoHelpers.place.type.CONVERSATION
	}, (err, created) ->
		console.log err, created
	###

	api.protoHelpers.place.rename 'b8b69754-9cf9-46a6-a82c-963e362927a9@ansamb_CgU_2DunXB6zW9k9ccbXfw', 'toto the new name', (err, renamed) ->
		console.log err, renamed
