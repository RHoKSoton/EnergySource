###
# run this as ./search.coffee ke >> scores.json
###

country = process.argv[0]

https = require 'https'
util = require 'util'
fs = require 'fs'

delay = (ms, cb) -> setTimeout cb, ms

ACTUALLY_SEARCH = 0

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
  if started is done
    console.log JSON.stringify outputTuples, null, 2
    process.exit 0

outputTuples = []

for countryName, countrySpec of data.countries then do (countryName, countrySpec) ->
  for componentType, componentSpecs of data.components then do (componentType, componentSpecs) ->
    for componentSpec in componentSpecs then do (componentSpec) ->
      cities = (city.name for city in countrySpec.cities)
#      cities = cities.slice(0,2)
      for city in cities then do (city) ->
        started++
        #term = 'intext:sonnenschein intext:battery intext:(nairobi | kisumu | mombasa | dadaab) intext:kenya -filetype:pdf (site:.com | site:.ke)'
        term = "#{componentSpec.Term} intext:\"(#{city}), #{countryName}\" (site:.com | site:.#{countrySpec.tld}) -filetype:pdf"

        if started <= ACTUALLY_SEARCH
          console.error "Search #{started}: #{term}"
          search term, (err, res) ->
            if err
              console.error "ERROR!"
              console.error err
              return
            #console.error util.inspect res, false, null, true
            #console.error "Results for #{componentSpec.Manufacturer} #{componentSpec.Part} in #{city}: #{res.responseData.cursor.resultCount ? 0}"
            done++
            outputTuples.push
              city: city
              country: countryName
              component: componentSpec
              results: res.responseData.cursor.resultCount
            checkComplete()
        else
          delay 0, ->
            done++
            console.error "Not Searching #{done}: #{term}"
