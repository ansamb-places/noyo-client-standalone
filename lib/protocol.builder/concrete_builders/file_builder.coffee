#this protocol is used to manage file download by the kernel
_ = require 'underscore'
kernel_common = 
	ver:1
	protocol:'fs'
	src:'local'
	dst:'local'
module.exports = 
	name:'file'
	api:
		downloadRequest: (data) ->
			_.extend
				method: 'DOWNLOAD'
				content_id: data.content_id
				spl: data.place
				dpl: data.place
				data:
					ansamb_extras: data.ansamb_extras
					update: if data.update then 1 else 0
				args: data.args
				# to know if download have to be started from scratch
			,kernel_common

		getInfo: (data) ->
			_.extend
				method:'GET_INFO'
				spl:data.place
				dpl:data.place
				data:
					data.content_ids
			,kernel_common

		pause: (data) ->
			_.extend
				method:'PAUSE'
				spl:data.place
				dpl:data.place
				data:
					data.content_ids
			,kernel_common

		resume: (data) ->
			_.extend
				method:'RESUME'
				spl:data.place
				dpl:data.place
				data:
					data.content_ids
			,kernel_common

		updateUri: (data) ->
			_.extend
				method: 'UPDATE_URI'
				spl: data.place
				dpl: data.place
				data: data.refs
			,kernel_common