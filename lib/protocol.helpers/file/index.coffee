_ = require 'underscore'
protoBuilder = require '../../protocol.builder'

module.exports = api =
	code:
		ok: 202

	###
	@content =
		id: string
		ansamb_extras:
			crypto: string
			access_key: string
			enc_hash_algorithm: int
			uri: string
			enc_filesize: int
	@abs_file_path : string absolute file path
	###
	download: (place_id, content, abs_file_path, update, cb) ->
		dl_obj =
			place: place_id
			content_id: content.id
			args:
				local_uri: "file://#{abs_file_path}"
			ansamb_extras: content.ansamb_extras
			update: update
		protoBuilder.file.downloadRequest(dl_obj).send (err,reply) ->
			if reply.code != api.code.ok
				cb "Error on starting download", false
			else
				cb null, true
	###
	@renameOptions =
		old_content_id: string
		data : 
			new_content_id: string
			relative_path: string
			name: string
			ref_content: string
			rev: string
	###
	rename: (place_id, renameOptions, cb) ->
		data =
			place: place_id
			old_content_id: renameOptions.old_content_id
			content_type: 'file'
			data: renameOptions.data
		protoBuilder.content.renameRequest(data).send (err, reply) ->
			return cb err if err?
			if reply.code == 200
				cb null, true
			else
				cb((reply.desc || "Unknwon error (code #{reply.code})"), false)

	getInfo: (place_id, content_ids, cb) ->
		data =
			place: place_id
			content_ids: content_ids

		protoBuilder.file.getInfo(data).send (err, reply) ->
			cb err, reply?.data

	pause: (place_id, content_ids, cb) ->
		data =
			place: place_id
			content_ids: content_ids

		protoBuilder.file.pause(data).send (err, reply) ->
			cb err, reply?.data

	resume: (place_id, content_ids, cb) ->
		data =
			place: place_id
			content_ids: content_ids

		protoBuilder.file.resume(data).send (err, reply) ->
			cb err, reply?.data
