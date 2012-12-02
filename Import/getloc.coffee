https = require 'https'
util = require 'util'
Url = require 'url'
fs = require 'fs'

delay = (ms, cb) -> setTimeout cb, ms

getloc = (country, city, cb) ->
  url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{city},#{country}&sensor=true"
  parsed = Url.parse url
  options =
    hostname: parsed.hostname
    port: parsed.port
    path: parsed.path
    agent: false
    headers:
      'User-Agent': 'Internet Exploder'
      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
      'Referer': 'Nigel'
      'Accept-Language': 'en-US,en;q=0.8'
      'Accept-Charset': 'ISO-8859-1,utf-8;q=0.7,*;q=0.3'
  https.get options, (res) ->
    res.setEncoding 'utf8'
    data = ""
    res.on 'data', (chunk) -> 
      data+=chunk
    res.on 'end', ->
      try
        json = JSON.parse data
        json = json.results[0].geometry.location
        cb null, json
      catch e
        console.log "ERROR"
        console.log util.inspect e, false, null, true
        cb true
        # ERROR
    res.on 'error', ->
      console.log "ERROR!"


started = 0
done = 0

checkComplete = ->
  fs.writeFileSync 'population-latlng.json', JSON.stringify population, null, 2
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
    if name.match /[{(\[]/
      [ignore, name] = name.match /[\[({](.*?)[\])}]/
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
    delay (count-1)*800, ->
      getloc city.country, city.city, (err, res) ->
        done++
        if err?
          console.log "GOT ERR"
        else
          list[i].lat = res.lat
          list[i].lng = res.lng
          console.log "#{countryName}, #{name}, #{res.lat}, #{res.lng}"
        checkComplete()
