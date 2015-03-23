api = require '../index'

PASSWORD = 'myPassw0rd'

module.exports = ->
	api.protoHelpers.account.register {
		firstname: 'my firstname'
		lastname: 'my lastname'
		email: 'emailazertyuiop@ok.com'
		lang: 'en'
		password: PASSWORD
	},{type:'email', field_name:'email'}, (err, account) ->
		console.log err, account