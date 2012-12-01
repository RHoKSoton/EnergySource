fs = require 'fs'

data = fs.readFileSync 'population.json'
data = JSON.parse data


lastName = ""
for country, rows of data
  for row in rows
    name = row.name
    population = row.population
    if name.match /[{(]/
      [ignore, name] = name.match /[({](.*)[)}]/
    name = name.replace /,/g, ":"
    if name.match /^incl\./
      name = lastName + " " + name
    else
      lastName = name
    console.log "#{country},#{name},#{population}"
