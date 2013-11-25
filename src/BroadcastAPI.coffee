http = require 'http'
https = require 'https'
Request = require './Request'
utils = require './utils'
Q = require 'q'
_ = require 'underscore'

###
  API URLs begin
###
HOME_TIMELINE = "/shuo/v2/statuses/home_timeline"

###
  Main class begins
###
class BroadcastAPI
	constructor: (request) ->
    unless request instanceof Request
      throw new TypeError("Argument Error: A Request object required")
    @_request = request

  ###
    @name broadcastAPI.getHomeTimeline
    @description Get the timeline of douban status
    @param paramObj {undefined | Object} Sets to undefined to get default behavior, otherwise passes
        a douban broadcast request object that contains the properties below to get
        customized behavior:
      + count:
      + offset:
      + since_id
      + until_id
    @param callback {undefined | Function} When it sets to undefined, it will return a Promise/A+
        style promise that wrapped the getHomeTimeline functionality and when it sets to a node-style
        callback function, then it will handle the data received with the following parameters:
      + err: it exists since an error occured
      + data: data received from the server
    @returns {Promise | undefined} Return a promise if no callback exists, otherwise return undefined
    @public
  ###
  getHomeTimeline: (paramObj, callback) ->
    unless _.isUndefined(paramObj) or utils.isPlainObject(paramObj)
      throw new TypeError("undefined or plain object required for the first parameter")

    if _.isFunction(callback)

      # Callback style strategy
      return @_getHomeTimelineByCallback(paramObj, callback)
    else if _.isUndefined(callback)

      # Promise style strategy
      return @_getHomeTimelineByPromise(paramObj)
    else

      # Can not accept parameters that are not funciton or undefined
      throw new TypeError("undefined or Function required for the second parameter")


  ###
    Helper functions
  ###
  _getHomeTimelineByCallback: (paramObj, callback) ->
    @_request.get HOME_TIMELINE, callback, paramObj

  _getHomeTimelineByPromise: (paramObj) ->
    return @_request.qGet HOME_TIMELINE, paramObj


exports = module.exports = BroadcastAPI
