#this protocol is used to retrieve a specific document from the kernel
#ex: profile
_ = require 'underscore'
general_content_common = 
	ver:1
	protocol:'content'

#headers specific to kernel messages
kernel_common = _.extend
	dst:'local'
	spl:'ansamb.account'
	dpl:'ansamb.account'
,general_content_common

module.exports = 
	name:'content'
	api:
		getRequest:(data)->
			return _.extend
				method:'GET'
				content_id:data.content_id
			,kernel_common
		putRequest:(data)->
			ret = _.extend 
				dst:data.dst #TODO, finally we are going to use '*' here and the kernel will manage the rest
				method:'PUT'
				content_id:data.content_id
				content_type:data.content_type
				date:+new Date(data.date) || null
				mergeable:false #TODO manage mergeable and non mergeable content
				rev:data.rev||null
				ref_content:data.ref_content||null
				application_tag:data.application_tag||null
				spl:data.place
				dpl:data.place
				data:data.data
			,general_content_common
			if data.ansamb_extras?
				ret.data.ansamb_extras = data.ansamb_extras
			if data.args?
				ret.args = data.args
			return ret
		deleteRequest:(data)->
			_.extend
				dst:"*"
				method:"DELETE"
				spl:data.place
				dpl:data.place
				content_id:data.content_id
				rev:data.rev
			,general_content_common
		renameRequest:(data)->
			_.extend
				dst:"*"
				method:"RENAME"
				spl:data.place
				dpl:data.place
				content_id:data.old_content_id
				content_type:data.content_type
				data:data.data
			,general_content_common
