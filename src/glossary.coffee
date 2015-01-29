# Description:
#   Messing around with reading technical glossary from a spreadsheet!
#   the module uses fuzzy search to find the best match, hopefully no two terms
#   has the same key
#
# Dependencies:
#   "fuzzy": "^0.1.0"
#   "google-spreadsheet": "^0.2.8"
#
# Configuration:
#   GOOGLE_USER_NAME
#   GOOGLE_PASSWORD
#
# Commands:
#   hubot what is ? - Glossary of GroupBy technical terms
#
# Author:
#   ferronrsmith

GoogleSpreadsheet = require "google-spreadsheet"
fuzzy = require 'fuzzy'

module.exports = (robot) ->
  robot.respond /what is (.*) \?$/i, (msg) ->
    term = msg.match[1]

    items = [];

    err_msg = "Oops I couldn't find anything :( "

    sheet = new GoogleSpreadsheet( "17giPrYrlt54tqgHTQcAwOa4C6Pg0bqBPqQ38TgkaPOI");

    # if auth is set, you can edit. you read the rows while authenticated in order to get the edit feed URLs from google
    sheet.setAuth process.env["GOOGLE_USER_NAME"], process.env["GOOGLE_PASSWORD"], (err) ->
      sheet.getRows 1, (err, rows) ->
        console.log err  if err
        if rows? and rows.length > 0
          rows.forEach (element) ->
            items.push
              title:element.term,
              content:element.description

          # filters the list for matches against a pattern or string
          results = fuzzy.filter(term, items,
            extract: (el) ->
              el.title
          )

          matches = results.map((el) ->
            el.original.content
          )

          matches = err_msg  if matches.length is 0

          msg.send matches
        else
          msg.send err_msg

