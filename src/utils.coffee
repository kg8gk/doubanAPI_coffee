###
  @name utils.isDoubanOAuthObject
  @description
###
exports.isDoubanOAuthObject = (obj) ->
  for key in ["access_token", "douban_user_name", "douban_user_id", "expires_in", "refresh_token"]
    return false unless obj[key]
  true
