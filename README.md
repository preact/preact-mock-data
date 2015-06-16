# preact-mock-data
Example of how to push a bunch of fake generated data to Preact

This will create ~50 dummy accounts with 1-10 people in each account. The same account ids and person ids will be used each time, though there is randomness about how many accounts are created each day (to simulate real-world behavior).

For each account 10-100 events will randomly be created and assigned randomly to the people associated with the account.

Takes api code/secret on execution and one or more integers of how many days ago to log the events from.

```
$ bundle
$ ruby mock.rb code secret day1 [day2 day3]
```

## Example

To log a set of random events timestamped for yesterday and the day before:

```
$ ruby mock.rb yourcode yoursecret 1 2
```

## Advanced

If you wish to customize the names of the generated events, you should edit the mock.rb before running it to update the event_names array to include names relevant to your business or intended usage.

The default is

```
event_names = [
  "logged-in",
  "logged-out",
  "forgot-password",
  "changed-password",
  "updated-profile",
  "updated-payment",
  "created-document",
  "uploaded-media",
  "modified-dashboard",
  "viewed-dashboard",
  "purchased-item",
  "changed-login",
  "created-profile",
  "downgraded",
  "upgraded",
  "signed-up"
]

```

## License

Copyright (c) 2015 Preact, Inc.

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.