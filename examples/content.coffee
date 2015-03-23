api = require '../index'

module.exports = ->
	###
	contentOptions=
		place: 'd0b5d2e3-cea7-4471-9911-f87c8fdc663d@ansamb_CgU_2DunXB6zW9k9ccbXfw'
		data: {
			post: ' un post'
		}
		content_type: 'post'

	api.protoHelpers.content.addContent contentOptions, (err, extra) ->
		console.log err, extra
	###
	###
	place = 'd0b5d2e3-cea7-4471-9911-f87c8fdc663d@ansamb_CgU_2DunXB6zW9k9ccbXfw'
	content = '5fefc8c8-26cf-4011-83b9-23a295bb441a'
	rev = 'c328376e-97c9-4ba7-a27e-e47e5b21dde5'
	api.protoHelpers.content.deleteContent place, content, rev, (err, deleted)->
		console.log err, deleted
	###
	###
	contentOptions=
		place: 'd0b5d2e3-cea7-4471-9911-f87c8fdc663d@ansamb_CgU_2DunXB6zW9k9ccbXfw'
		data: {
			post: ' un post'
		}
		content_type: 'post'

	api.protoHelpers.content.addContent contentOptions, (err, extra) ->
		console.log err, extra
	###

	place = 'd0b5d2e3-cea7-4471-9911-f87c8fdc663d@ansamb_CgU_2DunXB6zW9k9ccbXfw'
	contentOptions =
		place: 'd0b5d2e3-cea7-4471-9911-f87c8fdc663d@ansamb_CgU_2DunXB6zW9k9ccbXfw'
		content_type: 'post'
	finalData = {
		post: ' un post'
	}
	api.protoHelpers.content.updateContent place, contentOptions, finalData, (err, updated)->
		console.log err, updated
	###
		