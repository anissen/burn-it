burn_it = require("../lib/burn-it.js")
exports["awesome"] =
  setUp: (done) ->
    done()

  "no args": (test) ->
    test.expect 1
    test.equal burn_it.awesome(), "awesome", "should be awesome."
    test.done()
