https = require 'https'
qs = require 'querystring'
_ = require 'underscore'
Q = require 'q'

###
  Helper functions begin
###

###
  @name _getDefaultArgs
  @description It's used to get common requests arguments
  @param oauth2 {Object} An object that contains the oauth2 token information
  @returns {Object} Common request arguments object
  @private
###
_getDefaultArgs = (oauth2) ->
  hostname: "api.douban.com"
  headers:
    "Authorization": "Bearer #{oauth2.access_token}"

###
  @name _receiveResponseData
  @description It is used to receive the data, and use callback to handle the data
  @param {Object} A object that contains two methods to handle the 'end' event and
      'error' event respectively
  @returns {Function} A partialy function that take the Reponse object as its argument
  @private
###
_receiveResponseData = (handlerObj) ->
  (res) ->
    data = ""
    res.on 'data', (chunk) ->
      data += chunk
    res.on 'end', ->
      if Q.isPromise(handlerObj.promise)
        handlerObj.resolve data
        return
      handlerObj.resolve undefined, data
    res.on 'error', ->
      handlerObj.reject "Response error"
      return

###
  @name makeGetRequest
  @description It wraps the common logic about sending the get request of https
  @param handlerObj {Object} It's a object that contains two methods to deal with the 'end'
      event and 'error' event, named resolve and reject respectively.
  @param oauth2 {Object} An object that contains the oauth2 token information
  @returns {Function} A funciton that takes two arguments, 'path' is the request path, and
      'extraArgs' is an object that contains extra request arguments to be appended on the path
###
_makeGetRequest = (handlerObj, oauth2) ->
  (path, extraArgs) ->
    responseHandler = _receiveResponseData(handlerObj)
    # Append the query string if extra arguments provided
    path = "#{path}?#{qs.stringify(extraArgs)}" if extraArgs
    args = _.extend(_getDefaultArgs(oauth2), { path: path })
    req = https.get args, responseHandler
    req.on 'error', (e) ->
      handlerObj.reject e
    req.end(null)

###
  Request class is used to wrap the https requests to douban.com
###
class Request
  ###
    @name Request.cache
    @description Cache object, it's used to cached the request
    @private
  ###
  @cache = {}

  ###
    @param {Object} oauth2 OAuth2 token object from douban
    @returns a newly created Request instance
    @private
  ###
  constructor: (@oauth2) ->

  ###
    @name Reqeust.getRequest
    @description It's used to get a cached request if related user information exists or
      return a new request for non-exist users
    @param {Object} oauth2 OAuth2 object
    @returns an instance of Request class
    @public
  ###
  @getRequest: (oauth2) ->
    cacheObj = @cache[oauth2.douban_user_id] || {}

    # It same token exist, just return the cached request
    if cacheObj.token is oauth2.access_token
      return cacheObj.request
    # Else update the token information and build a new request instance
    cacheObj.token = oauth2.access_token
    cacheObj.request = new Request(oauth2)
    @cache[oauth2.douban_user_id] = cacheObj
    return cacheObj.request

  ###
    @name request.get
    @description Async get method send https requests
    @param {String} path Request path. Defaults to '/'. Should not include any query strings.
    @param {Function} callback Callback function to handle the data or error
    @param {Object} extraArgs Extra request arguments
    @public
  ###
  get: (path, callback, extraArgs) ->
    handlerObj =
      resolve: callback
      reject: callback
    _makeGetRequest(handlerObj, @oauth2)(path, extraArgs)

  ###
    @name request.qGet
    @description Asynchronously GET mothod that wrapped in promise
    @param {String} path Request path. Defaults to '/'. Should not include any query strings.
    @param {Object} extraArgs Extra request arguments
    @returns {Promise} Q promise
    @private
  ###
  qGet: (path, extraArgs) ->
    deferred = Q.defer()
    _makeGetRequest(deferred, @oauth2)(path, extraArgs)
    deferred.promise

exports = module.exports = Request