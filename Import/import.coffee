###
# run as ./import.coffee ke
###

fs = require 'fs'

tld = process.argv[2]

importCSV = (filepath) ->
  componentsCSV = fs.readFileSync filepath, 'utf8'
  components = []

  lines = componentsCSV.split /\n/
  headers = lines.shift().split(/,/)

  for line in lines
    entry = {}
    line = line.split /,/, headers.length
    if line.length < headers.length
      continue
    for item, i in line
      if item.substr(0,1) is '"'
        # Unstringify
        item = item.substr(1,item.length-2)
        item = item.replace /""/g, '"'
      entry[headers[i]] = item
    components.push entry
  return components

allComponents = importCSV 'Pats Countries - Components.csv'
components = {}
for component in allComponents
  components[component.Part] ?= []
  components[component.Part].push component

cities = importCSV "Pats Countries - Cities #{tld}.csv"
cities.sort (a, b) ->
  return b.Population - a.Population
countries = {}
for city in cities
  countries[city.Country] ?= {name:city.Country,tld:tld,cities:[]}
  countries[city.Country].cities.push {name:city.City,population:city.Population}

data = {components:components, countries:countries}

fs.writeFileSync 'data.json', (JSON.stringify data, null, 2)
