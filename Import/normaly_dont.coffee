fs = require 'fs'

data = JSON.parse fs.readFileSync 'scores.json'

#normalise them all by this result to produce a result per 10000 head population
newdata = []
for dat in data then do (dat) ->
  dat.numResults = dat.numResults / dat.population * 10000
  newdata.push dat

#work out the largest single result now
largest = 1    # do not devide by 0
for dat in newdata then do (dat) ->
  dat.numResults ?= 0
  if dat.numResults > largest
    largest = dat.numResults
console.error "#{largest}"

#normalise the results into a 0 to 1 linear scale.
newerdata = []
for dat in newdata = 

console.log JSON.stringify newdata, null, 2
process.exit 0

