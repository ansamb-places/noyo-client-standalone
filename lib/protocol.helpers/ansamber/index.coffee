protoBuilder = require '../../protocol.builder'

module.exports = api =
  parsePlaceId: (place_id) ->
      uuid_separator_index = place_id.indexOf('@')
      return null if uuid_separator_index<=0
      obj =
        uuid:null
        owner_uid:null
      if uuid_separator_index!=-1
        obj.uuid = place_id.substr(0,uuid_separator_index) 
        obj.owner_uid = place_id.substr(uuid_separator_index+1)
      else
        obj.uuid = place_id
      return obj

  ###
  @place =
    uid: string
    name: string
    type: string
    desc: string
    owner_uid: string
    creation_date: timestamp
  @uid: string
  ###
  sendAnsamberRequestForPlace: (place, uid, cb) ->
    parsed_id = api.parsePlaceId(place.uid)
    protoBuilder.place.addAnsamberRequest({
      place_id: parsed_id.uuid
      user_uid: uid
      name: place.name || ""
      type: place.type
      desc: place.desc
      creation_date: + new Date(place.creation_date)
      place_uid: place.uid
      owner_uid: place.owner_uid
    }).send {timeout: 2000}, (err,reply) ->
      return cb(err) if err?
      if reply.code!=202
        console.error("Received a non-202 reply (#{reply.code}")
      cb err, reply.code

  buildAddAnsamberMessage: (place, ansamber) ->
    parsed_id = api.parsePlaceId(place.uid)
    d = place.creation_date || new Date
    return protoBuilder.place.addAnsamberRequest({
      place_id: parsed_id.uuid
      user_uid: ansamber.uid
      name: place.name || place.uid
      type: place.type
      desc: place.desc
      creation_date: +new Date(d)
      place_uid: place.uid
      owner_uid: place.owner_uid
      ansamber_info: 
        firstname: ansamber.firstname
        lastname: ansamber.lastname

    }).getMessage()

  ###
  @replyOptions =
    place_id: string
    owner_uid: string
    add_request_id: string (referenced either messageid of the request or the ref id of the request)
    accepted: bool
  ###
  sendAnsamberReplyForPlace: (replyOptions, cb) ->
    protoBuilder.place.addAnsamberReply({
      place: replyOptions.place_id
      user_uid: replyOptions.owner_uid
      request_id: replyOptions.add_request_id
      accepted: replyOptions.accepted
    }).send (err,reply)->
      ### NEVER EXECUTE
      if reply.code!=202
        console.error("Received a non-202 reply (#{reply.code})")
      cb err, reply.code
      ###
    cb null, true

  removeAnsamberFromPlace: (placeUid, uid, cb) ->
    msg =
      place: placeUid,
      user_uid: uid
    protoBuilder.place.removeAnsamberRequest(msg).send {timeout: 2000}, (err,reply) ->
      return cb(err, false) if err?
      if reply.code == 200
        cb null, true
      else if reply.code == 403
        cb "You're not allowed !", false
      else
        cb "Kernel didn't deleted the ansamber of place #{placeUid}, reply (#{reply.code}) ", false