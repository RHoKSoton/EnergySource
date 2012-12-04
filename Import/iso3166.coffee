fs = require 'fs'

source = fs.readFileSync 'iso_3166-1_alpha-2.tsv', 'utf8'
source = source.split /\n/

keys = source.shift().split /\t/

output = []
for row in source
  row = row.split(/\t/)
  if row.length < keys.length
    continue
  data = {}
  for key, i in keys
    data[key] = row[i]
  output.push data

fs.writeFileSync 'iso3166.json', JSON.stringify output, null, 2
