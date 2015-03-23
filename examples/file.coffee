api = require '../index'

module.exports = ->
	place_id = '897e814f-d21d-42b7-b9ac-d7367daaa652@ansamb_CgU_2DunXB6zW9k9ccbXfw'
	content = 
		id: 'ab211233b6576dbb0f8b5826447eeac61e2a833a99ac5d788fbc1a174c3c6ce5'
		ansamb_extras: 
			crypto: 'YAAAABBlbmNfYWxnb3JpdGhtAAEAAAAFa2V5ACAAAAAASwqtxN5m52cgLkhvoc58aVxF9OOvD/T5E9EhFUUatTgFb3B0aW9ucwAQAAAAAF943zBDnu4Xg2oDbbHSERUA'
			access_key: '1215e3ff-8b8b-4601-ba4f-a601c452520f'
			enc_hash_algorithm: 1
			enc_filesize: 14112
			uri: 'https://api.ansamb.com/fs/897e814f-d21d-42b7-b9ac-d7367daaa652@ansamb_CgU_2DunXB6zW9k9ccbXfw/ab211233b6576dbb0f8b5826447eeac61e2a833a99ac5d788fbc1a174c3c6ce5'
	content_id = ['ab211233b6576dbb0f8b5826447eeac61e2a833a99ac5d788fbc1a174c3c6ce5']
	file_path = '/Users/dgrondin/Desktop/AAAAAAAAA.png'
	api.protoHelpers.file.download place_id, content, file_path, (err, deleted) ->
		console.log err, deleted

	api.protoHelpers.file.getInfo place_id, content_id, (err, reply) ->
		console.log err, reply
