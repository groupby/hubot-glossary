# Description:
#   Messing around with reading technical glossary from a spreadsheet!
#   the module uses fuzzy search to find the best match, hopefully no two terms
#   has the same key
#
#   If there a term does not exists with-in the glossary an online dictionary is searched and
#   two random results returned.
#
# Dependencies:
#   "fuzzy": "^0.1.0"
#   "google-spreadsheet": "^0.2.8"
#   "lodash": "^3.0.1"
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
_ = require 'lodash'

module.exports = (robot) ->
  robot.respond /what is (.*)\??/i, (msg) ->
    term = msg.match[1]

    term = term.split("\?")[0].trim() if term.length > 0


    items = [];
    matches = ""

    err_msg = "Oops I couldn't find anything :-("

    sheet = new GoogleSpreadsheet(process.env["GOOGLE_SPREADSHEET_KEY"]);

    # if auth is set, you can edit. you read the rows while authenticated in order to get the edit feed URLs from google
    sheet.setAuth process.env["GOOGLE_USER_NAME"], process.env["GOOGLE_USER_PASSWORD"], (err) ->
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

          # term doesn't exists with-in the glossary. perform a dictionary search
          if matches.length is 0
            matches = err_msg
            robot.http("https://glosbe.com/gapi/translate?from=eng&dest=eng&format=json&phrase=#{term}")
            .get() (err, res, body) ->
              if res? and res.statusCode is 200 and body?
                data = JSON.parse(body)
                # check to ensure that a definition for the word exists
                # if not `tuc` will not be present
                if data["tuc"]?
                  def = data["tuc"]
                  if def.length > 0

                    # filter out all the elements that do not have a `meaning` attribute
                    for elem in def
                      if elem['meanings']?
                        def = elem['meanings']
                        break

                    # check if definition is present
                    if def.length > 0
                      # take a random two definition
                      result = _.sample(def, 2)
                      res="\n";
                      result.forEach (el, idx) ->
                        res += "#{idx+1}. #{el.text}\n"
                      matches = res
                msg.send matches
          else
            msg.send matches
        else
          msg.send err_msg

