###
# run this as ./search.coffee ke >> scores.json
###

# This should probably be brought a little more up to date...
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

# A nice bit of casual racism to pretend to be newspapers...
words = [
  'frog'
  'prince'
  'slum'
  'dog'
  'millionaire'
  'obama'
  'brother'
  'food'
  'public'
  'happy'
  'family'
  'immigrants'
  'jobs'
  'recession'
  'polish'
]

# This is just for randomization you realise.
# I do not endorse the reading of these publications.
refererList = [
  'http://www.dailymail.co.uk/'
  'http://www.techcrunch.com/'
  'http://www.cnet.com/'
  'http://www.telegraph.co.uk/'
  'http://www.thesun.co.uk/'
  'http://www.independent.co.uk/'
  'http://www.hsbc.co.uk/'
]

country = process.argv[0]

https = require 'https'
util = require 'util'
fs = require 'fs'
Url = require 'url'

delay = (ms, cb) -> setTimeout cb, ms

#+ Jonas Raoni Soares Silva
#@ http://jsfromhell.com/array/shuffle [v1.0]

shuffle = (o) ->
  return Math.round(Math.random()*2)-1

POP_THRESHOLD = 100000
ACTUALLY_SEARCH = 120
RAND_DELAY = 50000
google_are_angry = false

search = (term, cb) ->
  url = "https://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=#{encodeURIComponent term}"
  parsed = Url.parse url

  # Randomize our UA
  ua = userAgentList[Math.floor Math.random()*userAgentList.length]
  # Randomize our referrer
  referrer = refererList[Math.floor Math.random()*refererList.length]
  words.sort shuffle
  referrer += words.slice(0, Math.ceil Math.random()*4).join("-")
  referrer += ".html"

  options =
    hostname: parsed.hostname
    port: parsed.port
    path: parsed.path
    agent: false
    headers:
      'User-Agent': ua
      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
      'Referer': referrer
      'Accept-Language': 'en-US,en;q=0.8'
      'Accept-Charset': 'ISO-8859-1,utf-8;q=0.7,*;q=0.3'

  req = https.get options, (res) ->
    res.setEncoding 'utf8'
    data = ""
    res.on 'data', (d) ->
      data += d
      return
    res.on 'close', ->
      if cb?
        cb new Error("Connection closed")
        cb = null
      return
    res.on 'end', ->
      try
        data = JSON.parse data
      catch e
        if cb?
          cb e
          cb = null
        return
      if cb?
        cb null, data
        cb = null
  req.on 'error', (err) ->
    if cb?
      cb err
      cb = null
    return
  return

data = JSON.parse fs.readFileSync 'data.json'

started = 0
done = 0

allDone = ->
  console.log JSON.stringify outputTuples, null, 2
  process.exit 0

checkComplete = ->
  delay 0, ->
    if started is done
      allDone()

process.on 'SIGINT', ->
  console.error "WE'VE BEEN Ctrl-C'd!! ARGH!"
  allDone()

process.once 'uncaughtException', (err) ->
  console.error "UNCAUGHT EXCEPTION!!"
  console.error util.inspect err, false, null, true
  allDone()


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

        delay (started-1)*RAND_DELAY + Math.random()*(RAND_DELAY/4), ->
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
              numResults = res.responseData.cursor.resultCount ? "0"
              numResults = String(numResults).replace ",", ""
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
