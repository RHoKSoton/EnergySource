https = require 'https'
util = require 'util'
Url = require 'url'
fs = require 'fs'

DELAY = 40000

delay = (ms, cb) -> setTimeout cb, ms

shuffle = (o) ->
  return Math.round(Math.random()*2)-1

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

getloc = (country, city, cb) ->
  url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{encodeURIComponent city},#{encodeURIComponent country}&sensor=true"
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
  https.get options, (res) ->
    res.setEncoding 'utf8'
    data = ""
    res.on 'data', (chunk) -> 
      data+=chunk
    res.on 'end', ->
      json = null
      try
        json = JSON.parse data
        json = json.results[0].geometry.location
        cb null, json
      catch e
        if json?.status is "ZERO_RESULTS"
          console.log "Not found: #{city}, #{country}"
        else if !json?
          console.log "ERROR in JSON: #{data}"
          console.log util.inspect e, false, null, true
        else
          console.log "ERROR: Something went wrong - is Google angry? (Looking for #{city}, #{country})"
          console.log util.inspect json, false, null, true
          process.exit 1
        cb true
        # ERROR
    res.on 'error', ->
      console.log "ERROR!"


started = 0
done = 0

checkComplete = ->
  fs.writeFileSync 'population.json', JSON.stringify population, null, 2
  if started is done
    process.exit 0

population = JSON.parse fs.readFileSync 'population.json', 'utf8'

iteration = 0
cities = []
lastName = ""
for countryName, list of population
  countryName = countryName.replace /-.*$/, ""
  countryName = countryName.replace /([a-z])([A-Z])/g,"$1 $2"
  for citySpec, i in list then do (i, countryName, citySpec, list) ->
    if citySpec.lng?
      return
    iteration++
    count = iteration
    name = citySpec.name
    if name.match /[{\[]/
      [ignore, name] = name.match /[\[{](.*?)[\]}]/
    if name.match /[(]/
      [ignore, name] = name.match /^(.*) \(.*$/
    name = name.replace /,/g, ":"
    if name.match /^incl\./
      # Skip this!
      return
      name = lastName + " " + name
    else
      lastName = name
    city =
      country:countryName
      city: name
      population: citySpec.population
    cities.push city
    started++
    delay (count-1)*DELAY+Math.random()*DELAY/3, ->
      getloc city.country, city.city, (err, res) ->
        done++
        if err?
          console.log "GOT ERR"
        else
          list[i].lat = res.lat
          list[i].lng = res.lng
          console.log "#{countryName}, #{name}, #{res.lat}, #{res.lng}"
        checkComplete()
