http = require 'http'
fs = require 'fs'

url = 'http://www.citypopulation.de/%COUNTRY%.html'
countries = [
  'Angola'
  'Algeria'
  'Angola'
  'Benin'
  'Botswana'
  'BurkinaFaso'
  'Burundi'
  'Cameroon'
  'CapeVerde'
  'Centralafrica'
  'Chad'
  'Comores'
  'Congo'
  'CongoDemRep'
  'CotedIvoire'
  'Djibouti'
  'Egypt'
  'EquatorialGuinea'
  'Eritrea'
  'Ethiopia'
  'Gabon'
  'Gambia'
  'Ghana'
  'Guinea'
  'GuineaBissau'
  'Kenya'
  'Lesotho'
  'Liberia'
  'Libya'
  'Madagascar'
  'Malawi'
  'Mali'
  'Mauritania'
  'Mauritius'
  'Mayotte'
  'Mocambique'
  'Morocco'
  'Namibia'
  'Niger'
  'Nigeria'
  'Reunion'
  'Rwanda'
  'SaoTome'
  'Senegal'
  'Seychelles'
  'SierraLeone'
  'Somalia'
  'SouthAfrica-UA'
  'SouthSudan'
  'StHelena'
  'Sudan'
  'Swaziland'
  'Tanzania'
  'Togo'
  'Tunisia'
  'Uganda'
  'Zambia'
  'Zimbabwe'
]

#countries = countries.slice(0,1)
#countries = ["BurkinaFaso"]
started = 0
done = 0

checkComplete = ->
  if started is done
    json = JSON.stringify output, null, 2
    fs.writeFileSync 'population.json', json

output = {}
for country in countries then do (country) ->
  output[country] = []
  started++
  http.get url.replace(/%COUNTRY%/, country), (res) ->
    res.setEncoding 'utf8'
    data = ""
    res.on 'data', (d) ->
      data += d
    res.on 'end', ->
      done++
      html = data
      res = html.match /<table id="ts(?:h)?"[^>]*>([\s\S]*?)<\/table>/
      if res?
        [ignore,html] = res
        trs = html.split /\n/
        for tr in trs
          if !tr.match(/<tr/) or tr.match /<th/
            continue
          city = []
          tds = tr.match /<td[^>]*>(.*?)<\/td>/g
          if !tds
            console.log "BAD! #{tr}"
            continue
          pop = 0
          for td in tds
            [ignore, data] = td.match /<td[^>]*>(.*?)<\/td>/
            data = data.replace /<[^>]*>/g, ""
            city.push data
            if td.match /<td class="n">/
              p = parseInt(data.replace(",",""),10)
              if p > 0
                pop = p
          if pop is 0
            continue
          city = {
            name: city[1]
            population: pop
          }
          output[country].push city
      if output[country].length < 10
        console.log "WARNING: #{country} has only #{output[country].length} results"
      checkComplete()
