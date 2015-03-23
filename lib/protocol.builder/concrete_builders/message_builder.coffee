_ = require 'underscore'

common =
	protocol:"message"
	version:"1"
module.exports =
	name:'message'
	api:
		buildMessage:(data)->
			_.extend {
				method:"PUT"
				spl:data.place
				dpl:data.place
				dst:data.dst
				data:data.payload
				content_type:data.content_type
			},common