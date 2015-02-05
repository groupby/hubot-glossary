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
#   GOOGLE_SPREADSHEET_KEY
#   GOOGLE_USER_NAME
#   GOOGLE_USER_PASSWORD
#
# Commands:
#   hubot what is ? - Glossary of GroupBy technical terms
#
# Author:
#   ferronrsmith

GoogleSpreadsheet = require "google-spreadsheet"
fuzzy = require 'fuzzy'

module.exports = (robot) ->
  robot.respond /what is (.*)\??/i, (msg) ->
    term = msg.match[1]

    term = term.split("\?")[0].trim() if term.length > 0

    items = [];

    err_msg = "Oops I couldn't find anything :-("

    sheet = new GoogleSpreadsheet(process.env["GOOGLE_SPREADSHEET_KEY"]);

    # if auth is set, you can edit. you read the rows while authenticated in order to get the edit feed URLs from google
    sheet.setAuth process.env["GOOGLE_USER_NAME"], process.env["GOOGLE_USER_PASSWORD"], (err) ->
      sheet.getRows 1, (err, rows) ->
        console.log err  if err
        if rows? and rows.length > 0
          rows.forEach (element) ->

            if element.term == 'UNKNOWN'
              err_msg = element.description
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
