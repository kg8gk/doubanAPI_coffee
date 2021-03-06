BroadcastAPI = require './BroadcastAPI'
Request = require './Request'
###
  @name DoubanAPI
  @description A class that wraps all the api of Douban
  @author kg8gk
  @since 2013/11/21
###
class DoubanAPI

  constructor: (oauth) ->
    @_oauth = oauth
    @_apiCachePool = {}
    @_request = Request.getRequest(oauth)

  ###
    @name doubanAPI.getBroadcastAPI
    @description Get the broadcast api
    @returns {BroadcastAPI} Instance of BroadcastAPI
    @public
  ###
  getBroadcastAPI: ->
    api = @_apiCachePool['broadcast']
    return api if api
    @_apiCachePool['broadcast'] = api = new BroadcastAPI(@_oauth, )
    api

