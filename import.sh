(echo -n "var population = "; cat Import/population.json;) > frontend/javascript/population.js
(echo -n "var scores, markers; scores = markers = "; cat Import/africa.json;) > frontend/javascript/scores.js
