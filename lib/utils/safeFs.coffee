fs = require 'fs'
_ = require 'underscore'

#clone the fs object (only functions)
new_object = {}
for name,f of fs
	new_object[name] = f

# redefine readdir and readdirSync to escape MAC .DS_Store special file
new_object.readdirSync = (path)->
	files = fs.readdirSync(path)
	if _.isArray(files)
		return _.without(files,'.DS_Store')
	else
		return files
new_object.readdir = (path,cb)->
	fs.readdir path,(err,files)->
		if _.isArray(files)
			files = _.without(files,'.DS_Store')
		cb err,files
module.exports = new_object