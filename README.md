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


- `GOOGLE_USER_NAME` - hubot email address for google docs. 
- `GOOGLE_USER_PASSWORD`  - hubot password for google docs.
- `GOOGLE_SPREADSHEET_KEY`  - spreadsheet key

## Sample Interaction

```
user1> hubot glossary what is congo ?
hubot>  Congo is the database data access object (dao) layer that stores...
```

## Sample Glossary

The first line of the Spreadsheet denotes the Table headers and must not be used for anything else. Currently
the header must be as shown below [Term, Description].

Ensure no empty rows are between the glossary. When an empty is detected the 
[spreadsheet API](https://developers.google.com/google-apps/spreadsheets/#retrieving_a_list-based_feed) will not return
any other record after.

| Term          | Description |
| ------------- | ------------- |
| Blame         | The "blame" feature in Git describes the last modification to each line of a file  |
| Branch        | A branch is a parallel version of a repository. It is contained within the repository  |
| Clone         | A clone is a copy of a repository that lives on your computer instead of on a website's server somewhere, or the act of making that copy  |
| Collaborator  | A collaborator is a person with read and write access to a repository who has been invited to contribute by the repository owner  |
| Commit        | A commit, or "revision", is an individual change to a file (or set of files)  |
| Contributor   | A contributor is someone who has contributed to a project by having a pull request merged but does not have collaborator access  |
| Diff          | A diff is the difference in changes between two commits, or saved changes  |
| Fetch         | Fetching refers to getting the latest changes from an online repository without merging them in  |
| Merge         | Merging takes the changes from one branch (in the same repository or from a fork), and applies them into another  |
| Pull Request  | Pull requests are proposed changes to a repository submitted by a user and accepted or rejected by a repository's collaborators  |
| Pull          | Pull refers to when you are fetching in changes and merging them  |
| Push          | Pushing refers to sending your committed changes to a remote repository |

