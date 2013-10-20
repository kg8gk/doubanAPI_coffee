Request = require '../src/Request'
{oauth2} = require '../douban_oauth'
chai = require 'chai'
expect = chai.expect

describe 'Request', ->

  anotherOAuth =
    access_token: "2c926201f2ec32f385b72605d8c498d9"
    douban_user_name: "阿渺同学纠结地"
    douban_user_id: "51890723"
    expires_in: 604800
    refresh_token: "67ba52d727aad69c372ef885770083d4"


  describe "Initialzation", ->

    request = Request.getRequest(oauth2)

    it 'should return an instance of Request class', ->
      expect(request).to.be.an.instanceof Request

    it 'should return same request when same oauth2 object passed in', ->
      expect(Request.getRequest(oauth2)).to.equal request

    it 'should return different request when different oauth2 object passed in', ->
      expect(Request.getRequest(anotherOAuth)).to.not.equal request

  describe 'GET', ->
    request = Request.getRequest(anotherOAuth)
    path = "/shuo/v2/statuses/home_timeline"

    it 'should send correct GET request', (done) ->
      request.get path, (data) ->
        expect(JSON.parse(data)).to.have.length 20
        done()

    it 'should send correct GET request with parameters', (done) ->
      request.get path
        , (data) ->
            expect(JSON.parse(data)).to.have.length 1
            done()
        , {count: 1}

#    it 'should raise an exception when error occurs', (done) ->
#      oldRequest = Request.getRequest(oauth2)
#      oldRequest.get path
#        , (data) ->
#            expect(JSON.parse(data)).to.have.property "error"
#        , {count: 1}

#	describe 'POST method', ->
#		path = "/shuo/v2/statuses/"
#
#		it 'should send correct POST request', (done) ->
#			message = "test api"
#			httpsRequests.post path
#				, (data) ->
#					JSON.parse(data).text.should.equal message
#				, { source: "072036b8c450ae9a1560a42a4cf20bce", text: message }
