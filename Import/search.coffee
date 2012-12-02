###
# run this as ./search.coffee ke >> scores.json
###

country = process.argv[0]

https = require 'https'
util = require 'util'
fs = require 'fs'

delay = (ms, cb) -> setTimeout cb, ms

POP_THRESHOLD = 10000
ACTUALLY_SEARCH = 0
RAND_DELAY = 60000
google_are_angry = false

search = (term, cb) ->
  url = "https://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=#{encodeURIComponent term}"
  req = https.get url, (res) ->
    res.setEncoding 'utf8'
    data = ""
    res.on 'data', (d) ->
      data += d
      return
    res.on 'close', ->
      cb new Error("Connection closed")
      cb = null
      return
    res.on 'end', ->
      try
        data = JSON.parse data
      catch e
        return cb e
      cb null, data
  req.on 'error', (err) ->
    cb err
    cb = null
    return

data = JSON.parse fs.readFileSync 'data.json'

started = 0
done = 0

checkComplete = ->
  delay 0, ->
    if started is done
      console.log JSON.stringify outputTuples, null, 2
      process.exit 0

outputTuples = []
if ACTUALLY_SEARCH is 0
  RAND_DELAY = 0

for componentType, componentSpecs of data.components then do (componentType, componentSpecs) ->
  for componentSpec in componentSpecs then do (componentSpec) ->

    for countryName, countrySpec of data.countries then do (countryName, countrySpec) ->
      cities = (city for city in countrySpec.cities when city.population > POP_THRESHOLD)
      for city in cities then do (city) ->

        started++
        reqNum = started
        #term = 'intext:sonnenschein intext:battery intext:(nairobi | kisumu | mombasa | dadaab) intext:kenya -filetype:pdf (site:.com | site:.ke)'
        term = "#{componentSpec.Term} intext:\"(#{city.name}), #{countryName}\" (site:.com | site:.#{countrySpec.tld}) -filetype:pdf"

        delay started*RAND_DELAY + Math.random()*(RAND_DELAY/2), ->
          if started <= ACTUALLY_SEARCH and not google_are_angry
            console.error "Search #{reqNum}: #{term}"
            search term, (err, res) ->
              done++
              if err or !res?.responseData?.cursor?
                if res?.responseStatus is 403
                  google_are_angry = true
                console.error "ERROR!"
                console.error err ? res
                checkComplete()
                return
              #console.error util.inspect res, false, null, true
              numResults = res.responseData.cursor.resultCount
              numResults = numResults.replace ",", ""
              numResults = parseInt numResults, 10
              score = (if numResults > 500 then 2 else if numResults > 50 then 1 else 0)
              console.error "Results [#{reqNum}] for #{componentSpec.Manufacturer} #{componentSpec.Part} in #{city.name}: #{numResults ? 0}"
              outputTuples.push
                city: city.name
                population: city.population
                country: countryName
                manufacturer: componentSpec.Manufacturer
                part: componentSpec.Part
                searchTerm: term
                numResults: numResults
                score: score
                gResults: res.responseData.results
              checkComplete()
          else
            delay 0, ->
              done++
              console.error "Not Searching #{done}: #{term}"
              checkComplete()
