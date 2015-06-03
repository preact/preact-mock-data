# preact-mock-data
Example of how to push a bunch of fake generated data to Preact

This will create 50 dummy accounts with 1-10 people in each account. The same accounts and people will be created each time.
For each account 0-100 events will randomly be created and assigned randomly to the people associated with the account.
Takes timestamp(s) and api code/secret on execution

  `ruby mock.rb code secret timestampfoo timestampbar`
