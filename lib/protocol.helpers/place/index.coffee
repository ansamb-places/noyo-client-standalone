_ = require 'underscore'
uuid = require 'node-uuid'
accountHelper = require '../account'
protoBuilder = require '../../protocol.builder'

module.exports = api =
  type:
    SHARE: 'share'
    CONVERSATION: 'conversation'
  code:
    ok: 200

  ###
  @placeOptions =
    name: string
    desc: string
    type: string
    owner_uid: string
    [id: string] Optional
  ###
  create: (placeOptions, cb) ->
    _execWithUid = (uid) ->
      placeData = _.clone placeOptions
      placeId = placeOptions.id || uuid.v4()
      owner_uid = uid
      placeUid = "#{placeId}@#{owner_uid}"
      gen_content = if placeOptions.gen_content? then placeOptions.gen_content else true

      _.extend placeData,
        creation_date: +new Date
        owner_uid: owner_uid
        id: placeId
        uid: placeUid
        gen_content: gen_content

      networkObject = protoBuilder.place.placeCreateRequest(placeData)
      networkObject.send()
      
      cb null, networkObject.message

    if placeOptions.owner_uid
      _execWithUid placeOptions.owner_uid
    else
      accountHelper.getUidAsync (uid) ->
        _execWithUid uid

  createConversationPlaceForContact: (contact_uid, options, cb) ->
    throw new Error 'Callback is not a function' unless _.isFunction(cb)
    accountHelper.getUidAsync (account_uid) =>
      convPlaceInfo = @getConvPlaceInfoWithoutCreate account_uid, contact_uid

      place_data =
        id: convPlaceInfo.id
        name: convPlaceInfo.uid
        desc: "unique #{api.type.CONVERSATION} place between #{account_uid} and #{contact_uid}"
        type: api.type.CONVERSATION
        owner_uid: convPlaceInfo.owner_uid
        # TODO check with kernel expert if options.isInvited == true and owner_uid == account_uid
        gen_content: options.isInvited == true or convPlaceInfo.owner_uid != account_uid

      api.create place_data, cb

  delete: (placeUid, cb) ->
    protoBuilder.place.deletePlace({place: placeUid}).send (err, reply) ->
      return cb(err, false) if err?
      code = reply.code
      if code == api.code.ok
        err = null
      else
        err = reply.desc || 'Unknown error'
      cb err, code == api.code.ok

  rename: (place_id, new_name, cb) ->
    protoBuilder.place.renamePlace({
      place: place_id
      name: new_name
    }).send (err, reply) ->
      return cb(err, false) if err?
      code = reply.code
      if code == api.code.ok
        cb null, true
      else
        message = "Unkown error"
        switch code
          when 403 then message = "Renamed not allowed"
          when 404 then message = "Place not found"
          when 500 then message = "Malformed request"
        cb message, false

  leave: (placeUid, cb) ->
    protoBuilder.place.leavePlace({place: placeUid}).send (err, reply) ->
      return cb(err, false) if err?
      code = reply.code
      if code == api.code.ok
        err = null
      else
        err = reply.desc || 'Unknown error'
      cb err, code == api.code.ok

  getBasicsDocuments: (place_id, owner_uid, cb) ->
    data =
      owner: owner_uid
      place: place_id
    protoBuilder.place.getBasicsDocuments(data).send (err, reply) ->
      cb err if err?
      code = reply.code
      if code == 202
        cb null, true
      else
        message = "Unkown error"
        switch code
          when 204 then message = "Documents already exist"
        cb message, false

  computeUid: (contactUid) ->
    accountUid = accountHelper.getUid()
    if accountUid
      return @getConvPlaceInfoWithoutCreate(accountUid, contactUid).uid
    else
      return null

  getConvPlaceInfoWithoutCreate: (myUid, contactUid) ->
    info =
      desc: "conversation place between #{myUid} and #{contactUid}"

    if myUid < contactUid
      id = "#{myUid},#{contactUid}"
      owner_uid = myUid
    else
      id = "#{contactUid},#{myUid}"
      owner_uid = contactUid

    info = _.extend info,
      uid: "#{id}@#{owner_uid}"
      id: id
      owner_uid: owner_uid
    return info


