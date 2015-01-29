# hubot-glossary [![Build Status](https://travis-ci.org/bot-scripts/hubot-glossary.svg)](https://travis-ci.org/bot-scripts/hubot-glossary)

A hubot script for pulling star wars quote

See [`src/glossary.coffee`](src/glossary.coffee) for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-glossary --save`

Then add **hubot-glossary** to your `external-scripts.json`:

```json
[
  "hubot-glossary"
]
```


## Configuration

The following environment variables must be set to allow hubot access to the google spreadsheet.

> NB : Public 

`GOOGLE_USER_NAME` - hubot username for google docs 

`GOOGLE_PASSWORD`  - hubot password for google docs 

## Sample Interaction

```
user1> hubot glossary what is congo ?
hubot>  Congo is the database data access object (dao) layer that stores...
```
