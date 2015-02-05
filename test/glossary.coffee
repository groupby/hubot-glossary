chai = require 'chai'
sinon = require 'sinon'
path = require("path")
fs = require 'fs'
chai.use require 'sinon-chai'
nock = require 'nock'
expect = chai.expect
helper = require 'hubot-mock-adapter-helper'
TextMessage = require("hubot/src/message").TextMessage
process.env.HUBOT_LOG_LEVEL = 'debug'
process.env.GOOGLE_SPREADSHEET_KEY = '17giPrYrlt54tqgHTQcAwOa4C6Pg0bqBPqQ38TgkaPOI'

describe 'quote', ->
  {robot, user, adapter} = {}
  nockScope = null

  beforeEach (done)->

    # disable real http requests
    nock.disableNetConnect()

    nock('https://spreadsheets.google.com/feeds/list/17giPrYrlt54tqgHTQcAwOa4C6Pg0bqBPqQ38TgkaPOI/1/')
          .get('/public/values')
          .replyWithFile(200, __dirname +  '/fixtures/result.xml')

    nock.enableNetConnect '127.0.0.1'

    helper.setupRobot (ret) ->
      {robot, user, adapter} = ret
      robot.loadFile path.resolve('.', 'src'), 'glossary.coffee'

      # load help scripts to test help messages
      hubotScripts = path.resolve 'node_modules', 'hubot-help', 'src'
      robot.loadFile hubotScripts, 'help.coffee'

      done()

  afterEach ->
    do robot.shutdown
    nock.cleanAll()
    process.removeAllListeners 'uncaughtException'


  describe 'help', ->
    it 'has help message', ->
      commands = robot.helpCommands()
      expect(commands).to.eql [
        "hubot help - Displays all of the help commands that Hubot knows about.",
        "hubot help <query> - Displays all help commands that match <query>.",
        "hubot what is ? - Glossary of GroupBy technical terms"
      ]

  describe 'robot response with 200', ->

    it 'retrieve glossary description for bindle', ->
      adapter.on 'send', (envelope, strings) ->
        expect(strings).to.deep.equal [
          [
            "Super cool name for the project. This is just to test my hubot script. please don't remove just yet"
          ]
        ]
      adapter.receive new TextMessage(user, "hubot what is Bindle ?")

    it 'retrieve glossary description for congo ', ->
      adapter.on 'send', (envelope, strings) ->
        expect(strings).to.deep.equal [
          [ "Congo is the database data access object (dao) layer that stores domain logic objects in the " +
            "elastic search engine. All DB logic should go here.  " +
            "https://github.com/groupby/bindle/blob/develop/congo/README.md"
          ]
        ]
      adapter.receive new TextMessage(user, "hubot what is Congo ?")

    it 'retrieve glossary description for congo with excess white space', ->
      adapter.on 'send', (envelope, strings) ->
        expect(strings).to.deep.equal [
          [ "Congo is the database data access object (dao) layer that stores domain logic objects in the " +
              "elastic search engine. All DB logic should go here.  " +
              "https://github.com/groupby/bindle/blob/develop/congo/README.md"
          ]
        ]
      adapter.receive new TextMessage(user, "hubot what is         Congo                ?")

    it 'retrieve glossary description for congo with excess white space and no question mark', ->
      adapter.on 'send', (envelope, strings) ->
        expect(strings).to.deep.equal [
          [ "Congo is the database data access object (dao) layer that stores domain logic objects in the " +
              "elastic search engine. All DB logic should go here.  " +
              "https://github.com/groupby/bindle/blob/develop/congo/README.md"
          ]
        ]
      adapter.receive new TextMessage(user, "hubot what is         Congo                ")

    it 'search for phrase that does not exist with glossary ', ->
      adapter.on 'send', (envelope, strings) ->

        expect(strings).to.deep.equal [
          "we don't know what that is.  Consider adding this term to the glossary document here:" +
          "\n      https://docs.google.com/a/groupbyinc.com/spreadsheets/d/17giPrYrlt54tqgHTQcAwOa4C6Pg0bqBPqQ38TgkaPOI/edit" +
          "\n      Alternatively have a look in the Tribal knowledge folder here: " +
          "https://drive.google.com/drive/#folders/0B4knkCGNsFR-R1V4aEdmZnJBeXc/0B4knkCGNsFR-U1RVWTdUenNQczQ"
        ]
      adapter.receive new TextMessage(user, "hubot what is stream ?")

  xdescribe 'robot performing alternative search, results 200', ->
    beforeEach ->
      nock("https://glosbe.com/gapi/translate")
      .get("?from=eng&dest=eng&format=json&phrase=stream")
      .replyWithFile(200, __dirname + '/fixtures/result.json')


    it 'search for phrase that does not exist with glossary ', ->
      adapter.on 'send', (envelope, strings) ->
        expect(strings).to.deep.equal [
          "\n1. good (in moral judgement only) (judgment)\n"
        ]
      adapter.receive new TextMessage(user, "hubot what is stream ?")

  xdescribe 'robot performing alternative search, no results 400', ->
    beforeEach ->
      nock("https://glosbe.com/gapi/translate")
      .get("?from=eng&dest=eng&format=json&phrase=stream")
      .reply(400)

    it 'search for phrase that does not exist in glossary', ->
      adapter.on 'send', (envelope, strings) ->
        expect(strings).to.deep.equal [
          "Oops I couldn't find anything :-("
        ]
      adapter.receive new TextMessage(user, "hubot what is stream ?")


