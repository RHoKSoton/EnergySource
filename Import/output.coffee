fs = require 'fs'

data = fs.readFileSync 'scores.json'
data = JSON.parse data


for row in data
  console.log "#{row.city},#{row.country},#{row.part},#{row.manufacturer},#{row.numResults ? 0}"
