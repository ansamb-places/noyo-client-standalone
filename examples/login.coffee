api = require '../index'

PASSWORD = 'coucoucmoi'

module.exports = ->
	api.protoHelpers.account.login PASSWORD, (err, logged)->
		console.log err, logged