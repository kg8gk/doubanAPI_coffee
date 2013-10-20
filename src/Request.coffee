'use strict'

https = require 'https'
qs = require 'querystring'
{extend} = require 'jquery'

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
    @private
    @param {Object} oauth2 OAuth2 token object from douban
    @returns a newly created Request instance
  ###
  constructor: (oauth2) ->
    @oauth2 = oauth2

  ###
    @name Reqeust.getRequest
    @public

    @description It's used to get a cached request if related user information exists or
      return a new request for non-exist users
    @public
    @param {Object} oauth2 OAuth2 object
    @returns an instance of Request class
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
    @name request._defaultArgs
    @private

    @description It's used to get common requests arguments
    @private
    @returns {Object} Common request arguments object
  ###
  _defaultArgs: ->
    hostname: "api.douban.com"
    headers:
      "Authorization": "Bearer #{@oauth2.access_token}"

  ###
    @name request._handleResponse
    @private

    @description It is used to receive the data, and use callback to handle the data
    @param {Funciton} callback A callback to handle the ultimate data or error
  ###
  _handleResponse: (callback) ->
    (res) ->
      data = ""
      res.on 'data', (chunk) ->
        data += chunk
      res.on 'end', ->
        callback JSON.parse(data.toString())
      res.on 'error', ->
        callback (new Error("Something wrong with request"))

  ###
    @name request.get
    @public

    @description Async get method send https requests
    @param {String} path Request path. Defaults to '/'. Should not include any query strings.
    @param {Function} callback Callback function to handle the data or error
    @param {Object} extraArgs Extra request arguments
  ###
  get: (path, callback, extraArgs) ->
    # Append the query string if extra arguments provided
    path = "#{path}?#{qs.stringify(extraArgs)}" if extraArgs

    args = extend(@_defaultArgs(), { path: path })
    req = https.get args, @_handleResponse(callback)
    req.on 'error', (e) ->
      console.log "Problem with request: #{e.message}"
    req.end(null)

exports = module.exports = Request