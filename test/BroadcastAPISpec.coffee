BroadcastAPI = require '../src/BroadcastAPI'
{oauth2} = require '../douban_oauth'
{expect} = require 'chai'
_ = require 'underscore'
Request = require '../src/Request'

describe 'BroadcastAPI', ->

  request = Request.getRequest oauth2

  describe "Initialzation", ->
    it "should not accept no arguments invocation", ->
      fn = -> new BroadcastAPI()
      expect(fn).to.throw TypeError, "Argument Error: A Request object required"

    it 'should not be instantiate when error object passed in and should thrown error', ->
      fn = ->
        new BroadcastAPI({})
      expect(fn).to.throw TypeError, "Argument Error: A Request object required"

  describe "APIs testing", ->

    broadcastAPI = new BroadcastAPI(request)

    describe "getHomeTimeLine", ->

      describe "Callback style", ->
        dataToBeCompared = null
        it 'should return 20 items with empty request argument', (done) ->
          handleData = (err, data) ->
            expect(JSON.parse data).to.have.length 20
            done()
          broadcastAPI.getHomeTimeline handleData

        it 'should return 5 items with {count: 5}', (done) ->
          handleData = (err, data) ->
            expect(JSON.parse data).to.have.length 5
            dataToBeCompared = JSON.parse data
            done()
          broadcastAPI.getHomeTimeline count: 5, handleData

        it "should return different data when offset sets", (done) ->
          args =
            count: 5
            offset: 1
          handleData = (err, data) ->
            unionedData = _.union(JSON.parse(data), data)
            expect(unionedData).to.have.length 4
            done()
          broadcastAPI.getHomeTimeline(args, handleData)


      describe "Promise style", ->
        it "should return 20 items with empty request arguments", (done) ->
          broadcastAPI.getHomeTimeline().then (data) ->
            expect(data).to.have.length 20
            done()
          .catch (err) ->
            console.log err
            throw new Error(err)

        it "should return 5 items with {count: 5}", (done) ->
          broadcastAPI.getHomeTimeline(count: 5).then (data) ->
            expect(data).to.have.length 5
            done()
          .catch (err) ->
            console.log err
            throw new Error(err)


#  it 'postStatus', (done) ->
#    broadcast.postStatus "Hello, world", (data) ->
#      data.text.should.equal "Hello, world"
