###
# run this as ./search.coffee ke >> scores.json
###

userAgentList = [
  'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-GB; rv:1.8.1.6) Gecko/20070725 Firefox/2.0.0.6'
  'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1)'
  'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.30)'
  'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; .NET CLR 1.1.4322)'
  'Mozilla/4.0 (compatible; MSIE 5.0; Windows NT 5.1; .NET CLR 1.1.4322)'
  'Internet Explorer 5, Windows XP'
  'Opera/9.20 (Windows NT 6.0; U; en)'
  'Opera/9.00 (Windows NT 5.1; U; en)'
  'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; en) Opera 8.50'
  'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; en) Opera 8.0'
  'Mozilla/4.0 (compatible; MSIE 6.0; MSIE 5.5; Windows NT 5.1) Opera 7.02 [en]'
  'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.7.5) Gecko/20060127 Netscape/8.1'
]
country = process.argv[0]

https = require 'https'
util = require 'util'
fs = require 'fs'

delay = (ms, cb) -> setTimeout cb, ms

POP_THRESHOLD = 10000
ACTUALLY_SEARCH = 0
RAND_DELAY = 40000
google_are_angry = false

search = (term, cb) ->
  url = "https://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=#{encodeURIComponent term}"
  parsed = url.parse url
  options = 
    hostname: parsed.hostname
    port: parsed.port
    path: parsed.path
    agent: false
  req = https.get options, (res) ->
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
  # Randomize our UA
  ua = userAgentList[Math.floor Math.random()*userAgentList.length]
  req.setHeader 'User-Agent', ua
  req.setHeader 'Accept', 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
  #req.setHeader 'Referer', 'http://www.google.com/'
  req.setHeader 'Accept-Language', 'en-US,en;q=0.8'
  req.setHeader 'Accept-Charset', 'ISO-8859-1,utf-8;q=0.7,*;q=0.3'


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
      #step = Math.floor countrySpec.cities.length/6
      #cities = (city.name for city, n in countrySpec.cities when (n % step) is 0)
      cities = (city.name for city in countrySpec.cities when city.population > POP_THRESHOLD)
      #cities = ['Kakamega', 'Garissa', 'Eldoret']
      #cities = cities.slice(0,2)
      for city in cities then do (city) ->

        started++
        reqNum = started
        #term = 'intext:sonnenschein intext:battery intext:(nairobi | kisumu | mombasa | dadaab) intext:kenya -filetype:pdf (site:.com | site:.ke)'
        term = "#{componentSpec.Term} intext:\"(#{city}), #{countryName}\" (site:.com | site:.#{countrySpec.tld}) -filetype:pdf"

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
              console.error "Results [#{reqNum}] for #{componentSpec.Manufacturer} #{componentSpec.Part} in #{city}: #{numResults ? 0}"
              outputTuples.push
                city: city
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
