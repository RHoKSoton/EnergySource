fs = require 'fs'

data = JSON.parse fs.readFileSync 'scores.json'

##work out the largest single result
#largest = 1    # do not devide by 0
#fir dat in data then do (dat) ->
#  dat.numResults ?= 0
#  if dat.numResults > largest
#    largest = dat.numResults
##console.error "#{largest}"

#normalise them all by this result to produce a result per 10000 head population
newdata = []
for dat in data then do (dat) ->
  dat.numResults = dat.numResults / dat.population * 10000
  newdata.push dat

console.log JSON.stringify newdata, null, 2
process.exit 0
