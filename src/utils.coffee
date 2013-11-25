###
  Utility module for DoubanAPI
###

###
  @name utils.isDoubanOAuthObject
  @description Test if the argument is a douban oauth object
  @param obj {Object} Object to be tested
  @return {Boolean} Returns true that it is a douban oauth object, otherwise false
  @public
###
exports.isDoubanOAuthObject = (obj) ->
  for key in ["access_token", "douban_user_name", "douban_user_id", "expires_in", "refresh_token"]
    return false unless obj[key]
  true

###
  @name utils.isPlainObject
  @desription Test if the argument is a plain object(No functions)
  @param obj {Object} Argument to be tested
  @return {Boolean} Returns true if it is a plain object otherwise false
  @public
###
exports.isPlainObject = (obj) ->
  Object.prototype.toString.apply(obj) is '[object Object]'
