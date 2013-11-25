BroadcastAPI = require '../src/BroadcastAPI'
{oauth2} = require '../douban_oauth'
{expect} = require 'chai'
_ = require 'underscore'
Request = require '../src/Request'
Q = require 'q'

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

      describe "Arguments", ->

        it "first argument can accept undefined", ->
          fn = ->
            broadcastAPI.getHomeTimeline(undefined)
          expect(fn).to.not.throw TypeError

        it "first argument can accept plain object", ->
          fn = ->
            broadcastAPI.getHomeTimeline({})
          expect(fn).to.not.throw TypeError

        it "first argument can not accept other types ", ->
          fn = ->
            broadcastAPI.getHomeTimeline([])
          expect(fn).to.throw TypeError

        it "second argument can accept undefined", ->
          fn = ->
            broadcastAPI.getHomeTimeline(undefined, undefined)
          expect(fn).to.not.throw TypeError

        it "second argument can accept functions", ->
          fn = ->
            broadcastAPI.getHomeTimeline(undefined, ->)
          expect(fn).to.not.throw TypeError

        it "second argument can't accept other types", ->
          fn = ->
            broadcastAPI.getHomeTimeline(undefined, [])
          expect(fn).to.throw TypeError

      describe "return values", ->

        it "should return undefined when a callback offered", ->
          expect(broadcastAPI.getHomeTimeline(undefined, ->)).to.be.undefined

        it "should return Promise when no callback offered", ->
          expect(Q.isPromise broadcastAPI.getHomeTimeline()).to.be.true

      describe "Callback style", ->
        dataToBeCompared = null
        it 'should return 20 items with empty request argument', (done) ->
          handleData = (err, data) ->
            expect(JSON.parse data).to.have.length 20
            done()
          broadcastAPI.getHomeTimeline undefined, handleData

        it 'should return 2 items with {count: 2}', (done) ->
          handleData = (err, data) ->
            expect(JSON.parse data).to.have.length 2
            dataToBeCompared =(JSON.parse data).map((data) -> data.id)
            done()
          broadcastAPI.getHomeTimeline count: 2, handleData

        it "should return different data when offset sets", (done) ->
          args =
            count: 2
            start: 1
          handleData = (err, data) ->
            if err
              throw new Error(err)
            # 只比较ID
            parsedData = JSON.parse(data).map((data) -> data.id)
            unionedData = _.union(parsedData, dataToBeCompared)
            expect(unionedData).to.have.length 3
            done()
          broadcastAPI.getHomeTimeline(args, handleData)


      describe "Promise style", ->
        it "should return 20 items with empty request arguments", (done) ->
          broadcastAPI.getHomeTimeline().then (data) ->
            expect(JSON.parse data).to.have.length 20
            done()
          .catch (err) ->
            throw new Error(err)

        it "should return 5 items with {count: 5}", (done) ->
          broadcastAPI.getHomeTimeline(count: 5).then (data) ->
            expect(JSON.parse data).to.have.length 5
            done()
          .catch (err) ->
            throw new Error(err)


#  it 'postStatus', (done) ->
#    broadcast.postStatus "Hello, world", (data) ->
#      data.text.should.equal "Hello, world"
