# Description:
#   The following module loads a glossary of terms from a google spreadsheet
#   The module uses fuzzy search to find the best match, hopefully no two terms
#   has the same key.
#
# Dependencies:
#   "fuzzy": "^0.1.0"
#   "google-spreadsheet": "^1.0.1"
#
# Configuration:
#   GOOGLE_SPREADSHEET_KEY
#
# Commands:
#   hubot what is ? - Glossary of GroupBy technical terms
#
# Author:
#   ferronrsmith
# Update Aug 28, 2015
# updated to google-spreadsheet 1.0.1 - client auth is deprecated.
# fix to use jwt

GoogleSpreadsheet = require "google-spreadsheet"
fuzzy = require 'fuzzy'

module.exports = (robot) ->
  robot.respond /what is (.*)\??/i, (msg) ->
    term = msg.match[1]

    term = term.split("\?")[0].trim() if term.length > 0

    items = [];

    err_msg = "Oops I couldn't find anything :-("

    sheet = new GoogleSpreadsheet(process.env["GOOGLE_SPREADSHEET_KEY"]);

    jwt_auth_file = process.env['GOOGLE_CREDS_FILE']

    creds = require "#{jwt_auth_file}"

    # if auth is set, you can edit. you read the rows while authenticated in order to get the edit feed URLs from google
    sheet.useServiceAccountAuth creds, (err) ->
      sheet.getRows 1, (err, rows) ->
        console.log err  if err
        if rows? and rows.length > 0
          rows.forEach (element) ->
            # check row for the [UNKNOWN] term. Use this as the err_msg
            if element.term == 'UNKNOWN'
              err_msg = element.description

            # add glossary term & description to the array
            items.push
              title:element.term,
              content:element.description

          # filters the list for matches against a pattern or string
          results = fuzzy.filter(term, items,
            extract: (el) ->
              el.title
          )

          # retrieve the [content] of all match results
          matches = results.map (el) ->
            el.original.content

          # return [UNKNOWN] as an error_message if no matches exists
          matches = err_msg  if matches.length is 0

          msg.send matches
        else
          msg.send err_msg
