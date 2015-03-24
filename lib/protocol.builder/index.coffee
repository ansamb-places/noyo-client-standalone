fs = require '../utils/safeFs'
path = require 'path'
NetworkDecorator = require './NetworkDecorator'
communication_layer = require '../communication_layer'
concrete_builders_dir = path.join(__dirname,"concrete_builders")

builders = {}
#load all builders
files = fs.readdirSync concrete_builders_dir
if files?
  for file in files
    ext = file.split('.').pop()
    continue if ext != 'js'

    try
      builder = require path.join(concrete_builders_dir,file)
      builders[builder.name] = NetworkDecorator(communication_layer,builder)
    catch e
      console.log "Unable to load one protocol builder"

module.exports = builders