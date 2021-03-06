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

# Randomly generated words
words = [
  'report'
  'stall'
  'sometime'
  'detected'
  'geographical'
  'terminal'
  'determined'
  'distant'
  'recognition'
  'offer'
  'stunt'
  'overhead'
  'ear'
  'suspect'
]

# This is just for randomization you realise.
# I do not necessarily endorse the reading of these publications.
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
BING_API_KEY = process.env.BING_API_KEY
if !BING_API_KEY
  console.error "NO API KEY!"
  process.exit 1


delay = (ms, cb) -> setTimeout cb, ms

shuffle = (o) ->
  return Math.round(Math.random()*2)-1

POP_THRESHOLD = 100000
ACTUALLY_SEARCH = 100
RAND_DELAY = 250
google_are_angry = false

googleSearch = (term, cb) ->
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

bingSearch = (phrase, cb) ->
  #phrase = "'#{encodeURIComponent phrase}'"
  phrase = "'#{phrase.replace(/'/g,"\\'")}'"
  options =
    hostname: "api.datamarket.azure.com"
    port: 443
    path: "/Bing/Search/Web?$format=json&Query=#{encodeURIComponent phrase}"
    agent: false
    auth: "#{BING_API_KEY}:#{BING_API_KEY}"
    headers:
      "User-Agent": "RHoK Soton Energy Source"

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
        console.error "INVALID JSON: #{data}"
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
  writeNow()
  process.exit 0

checkComplete = ->
  delay 0, ->
    if started is done
      allDone()

writeNow = ->
  filename = "partial.#{new Date().getTime()}.json"
  toWrite = JSON.stringify outputTuples, null, 2
  fs.writeFileSync filename, toWrite
  console.error "Current data was output to #{filename}"
  return filename

process.on 'SIGINT', ->
  console.error "WE'VE BEEN Ctrl-C'd!! ARGH!"
  writeNow()
  allDone()

process.on 'SIGUSR1', ->
  writeNow()
  return

process.once 'uncaughtException', (err) ->
  writeNow()
  console.error "UNCAUGHT EXCEPTION!!"
  console.error util.inspect err, false, null, true
  allDone()


outputTuples = []
if ACTUALLY_SEARCH is 0
  RAND_DELAY = 0

population = JSON.parse fs.readFileSync 'population.json', 'utf8'

cities = []
lastName = ""
for countryName, list of population
  countryName = countryName.replace /-.*$/, ""
  countryName = countryName.replace /([a-z])([A-Z])/g,"$1 $2"
  for citySpec in list
    name = citySpec.name
    if name.match /[{(\[]/
      [ignore, name] = name.match /[\[({](.*?)[\])}]/
    name = name.replace /,/g, ":"
    if name.match /^incl\./
      # Skip this!
      continue
      name = lastName + " " + name
    else
      lastName = name
    city =
      country:countryName
      city: name
      population: citySpec.population
    cities.push city

cities.sort (a, b) ->
  return b.population - a.population

for city in cities then do (city) ->

  for componentType, componentSpecs of data.components then do (componentType, componentSpecs) ->
    for componentSpec in componentSpecs then do (componentSpec) ->

      started++
      reqNum = started
      #term = 'sonnenschein battery "(nairobi | kisumu | mombasa | dadaab), kenya"'
      term = "#{componentSpec.Term} \"(#{city.city}), #{city.country}\""

      if reqNum > ACTUALLY_SEARCH
        RAND_DELAY = 0
      delay (reqNum-1)*RAND_DELAY + Math.random()*(RAND_DELAY/4), ->
        if reqNum <= ACTUALLY_SEARCH and not google_are_angry
          console.error "Search #{reqNum}: #{term}"
          bingSearch term, (err, res) ->
            done++
            if err or !res?.d?.results?
              if res?
                google_are_angry = true
              console.error "ERROR!"
              console.error err ? res
              checkComplete()
              return
            #console.error util.inspect res, false, null, true
            numResults = res.d.results.length
            score = (if numResults > 100 then 2 else if numResults > 10 then 1 else 0)
            console.error "Results [#{reqNum}] for #{componentSpec.Manufacturer} #{componentSpec.Part} in #{city.city}: #{numResults ? 0}"
            resultsCropped = res.d.results
            resultsCropped = resultsCropped.slice(0,Math.min(4,resultsCropped.length))
            outputTuples.push
              city: city.city
              population: city.population
              country: city.country
              manufacturer: componentSpec.Manufacturer
              part: componentSpec.Part
              searchTerm: term
              numResults: numResults
              score: score
              bingResults: resultsCropped
            checkComplete()
        else
          delay 0, ->
            done++
            console.error "Not Searching #{done}: #{term} (#{if google_are_angry then "angry" else "calm"})"
            checkComplete()
