protoBuilder = require '../../protocol.builder'

module.exports = api =
  ###
  @data =
    place_id: string
    [channel: string] Optional
    [reset: string]
  ###
  enableSyncForPlace: (data) ->
    protoBuilder.sync.enableSyncForPlace(data).send()

  ###
  @data =
    place_id: string
    content_id: string
    [max_contents_per_msg: int]
  ###
  get: (data, cb) ->
    protoBuilder.sync.get(data).send (err, reply) ->
      # if the code is 204, we don't handle the doc because it's not the last content revision
      # the case could be encoutered for contents which have been deleted or removed
      return cb err if err
      return cb reply.desc || 'Bad reply code' if reply.code != 200
      cb null, reply.data.content
      