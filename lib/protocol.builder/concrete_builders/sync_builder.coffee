_ = require 'underscore'
# the sync protocol allow to retrieve modifications made on a place while we were disconnecting
# and to send modifications made while we were offline
common =
	protocol:"sync"
	ver:"1"
module.exports =
	name:'sync'
	api:
		enableSyncForPlace:(data)->
			_.defaults data,{reset:false}
			data.reset = !!data.reset
			message:
				_.extend {
					method:"ENABLE_RT_RCPT"
					spl:data.place_id
					dpl:data.place_id
					data:
						channel:data.channel||"default"
						reset:data.reset
				},common
			_conditions:['server_link:connected'] #theses conditions have to be satisfied before sending the message
		disableSyncForPlace:(data)->
			_.extend {
				method:"DISABLE_RT_RCPT"
				spl:data?.place_id||"*"
				dpl:data?.place_id||"*"
			},common
		get:(data)->
			msg = _.extend {
				method:"GET"
				spl:data.place_id
				dpl:data.place_id
				data:
					content_id:data.content_id
			},common
			msg.data.max_contents_per_msg = data.max_contents_per_msg if not _.isUndefined data.max_contents_per_msg
			return msg
		put:(data)->
			_.extend {
				method:"PUT"
				data:
					content:data.content||null
					base_version:data.base_version||null
			},common
		delete:(data)->
			_.extend {
				method:"DELETE"
				data:
					content:data.content_id||null
					base_version:data.base_version|null
			},common