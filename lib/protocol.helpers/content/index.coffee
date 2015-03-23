_ = require 'underscore'
protoBuilder = require '../../protocol.builder'
uuid = require 'node-uuid'

module.exports = api =
	code:
		ok: 202
	###
	@addContent =
		place: string
		data: Json Object
		content_type: string

		[content_id: string] Optional
		[date: date]
		[rev: string]
		[ref_content: string]
		[application_tag: string]
	###
	addContent: (content_options, cb) ->
		content_options = _.extend {
			dst: '*'
			content_id: uuid.v4()
			rev: uuid.v4()
		}, content_options
		protoBuilder.content.putRequest(content_options).send (err, reply) ->
			return cb err, false if err?
			_code = reply.code
			extra = null
			if _code == api.code.ok
				err = null
			else
				err = reply.desc || 'Unknown error'
			if reply?.data?.ansamb_extras
				extra = reply?.data?.ansamb_extras
				try
					extra = JSON.stringify(extra)
				catch e
					return cb e if _.isFunction cb
			cb err, extra

	deleteContent: (place_id, content_id, content_rev, cb) ->
		protoBuilder.content.deleteRequest({
			place: place_id
			content_id: content_id
			rev: content_rev
		}).send (err, reply) ->
			return cb(err, false) if err?
			_code = reply.code
			if _code == 200
				err = null
			else
				err = reply.desc || 'Unknown error'
			cb err, _code == 200
