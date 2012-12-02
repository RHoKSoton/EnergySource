https = require 'https'
util = require 'util'
Url = require 'url'

getloc = (country, city) ->
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
  res = https.get options, (res) ->
    res.setEncoding 'utf8'
    data = ""
    res.on 'data', (chunk) -> data+=chunk
    res.on 'end', ->
      try
        json = JSON.parse data
        json = json.results[0].geometry.location
        console.log util.inspect json, false, null, true
      catch e
        # ERROR
      


country = "Kenya"
city = "Nairobi"

latlong = getloc(country, city)
