https = require 'https'
util = require 'util'
fs = require 'fs'

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

done = 0
for countryName, countrySpec of data.countries then do (countryName, countrySpec) ->
  for componentType, componentSpecs of data.components then do (componentType, componentSpecs) ->
    for componentSpec in componentSpecs then do (componentSpec) ->
      cities = (city.name for city in countrySpec.cities)
      for city in cities
        done++
        if done > 1
          return
        #term = 'intext:sonnenschein intext:battery intext:(nairobi | kisumu | mombasa | dadaab) intext:kenya -filetype:pdf (site:.com | site:.ke)'
        term = "#{componentSpec.Term} intext:\"(#{city}), #{countryName}\" (site:.com | site:.#{countrySpec.tld}) -filetype:pdf"

        console.log term
        search term, (err, res) ->
          if err
            console.error "ERROR!"
            console.error err
            return
          #console.log util.inspect res, false, null, true
          console.log "Results for #{componentSpec.Manufacturer} #{componentSpec.Part} in #{city}: #{res.responseData.cursor.resultCount ? 0}"
