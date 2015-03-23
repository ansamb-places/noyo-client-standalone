path = require 'path'
fs = require 'fs'

HOME = if process.platform == 'win32' then process.env.USERPROFILE else process.env.HOME
utils =
  HOME: HOME
  getPlacesProfileDir: (profileName) ->
    profileName ?= 'default'
    return path.join HOME, '.places', profileName

  getLocalSettings: (profileName) ->
    profileName ?= 'default'
    p = path.join HOME, '.places', profileName, 'local_settings.json'
    try
      data = fs.readFileSync p, {encoding: 'utf8'}
      data = JSON.parse(data)
      return data
    catch e
      throw e
  parsePlaceId: (place_id) ->
    uuid_separator_index = place_id.indexOf('@')
    return null if uuid_separator_index <= 0
    obj = {
      id: null
      owner_uid: null
    }
    if uuid_separator_index != -1
      obj.id = place_id.substr(0,uuid_separator_index)
      obj.owner_uid = place_id.substr(uuid_separator_index + 1)
    else
      obj.id = place_id
    return obj

module.exports = utils