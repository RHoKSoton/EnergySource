function initializeMaps() {
  console.log("Initialize");
    var myOptions = {
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        mapTypeControl: false
    };
    var map = new google.maps.Map(document.getElementById("map"), myOptions);
    var infowindow = new google.maps.InfoWindow();
    var marker, i;
    var bounds = new google.maps.LatLngBounds();
    var iconRed = 'images/grayLarge.png';
    var iconYellow = 'images/yellowLarge.png';
    var iconGreen = 'images/img/greenLarge.png';

    //alert(markers.length);
    var oldMarkers = markers;
    markers = [];
    var cities = {};

    for (i = 0; i < oldMarkers.length; i++) {
      var m = oldMarkers[i];
      if (!cities[m.city]) {
        cities[m.city] = {
          city: m.city,
          country: m.country,
          results: 0,
          count: 0
        };
      }
      cities[m.city].results += m.numResults;
      cities[m.city].count++;
      cities[m.city].numResults = Math.ceil(cities[m.city].results / cities[m.city].count);

    }
    for (var k in cities) {
      markers.push(cities[k]);
    }

    max = 200;
    for (i = 0; i < markers.length; i++) {
      if (max < 0) break;
    
      var m = markers[i];
      if (!m.city || !m.country) {
        console.log(m);
        continue;
      }
    	var city = m.city
      var country = m.country.replace(/ /g,"");
      var latitude = 0, longitude = 0;
      if (!population[country]) {
        console.warn("Couldn't find country: "+country);
        continue;
      }
      var city2 = null;
      for (var j = 0; j < population[country].length; j++) {
        city2 = population[country][j];
        //console.log(city2.name + " vs " + city);
        if (city2.name  == city) {
          latitude = city2.lat;
          longitude = city2.lng;
          //console.log(city+ ": "+latitude+", "+longitude);
          break;
        }
      }
      if (!latitude) {
        console.log("Failed to find lat for "+city);
        continue;
      }
      max--;
        
        pos = new google.maps.LatLng(latitude, longitude);
        bounds.extend(pos);

        if (markers[i]["numResults"] >= 40) {
            image = "images/greenLarge.png";
        } else if (markers[i]["numResults"] >0) {
            image = "images/yellowLarge.png";
        } else {
            image = "images/redLarge.png";
        }

        marker = new google.maps.Marker({
            position: pos,
            map: map,
            title: city,
            icon: image
        });

        google.maps.event.addListener(marker, 'click', (function (marker, i, country, city, city2, map) {

            return function () {
                infowindow.setContent(city+", "+country+"<br />Population: "+city2.population);
                infowindow.open(map, marker);
                energy.city_clicked(city, country);
            }
        })(marker, i, country, city, city2, map));
        
    }
    var geocoder = new google.maps.Geocoder();
    google.maps.event.addListener(map, 'center_changed', function() {
    	var c = map.getCenter();
    	var latlng = new google.maps.LatLng(c.lat(), c.lng());
    	geocoder.geocode({'latLng': latlng}, function(results, status) {
    		if (results !== null && results.length > 0) {
    			var address = results[0].address_components[results[0].address_components.length - 1];
    			var country_name = address.long_name;
    			energy.display_country_info(country_name);
    		}
    		else if (status !== "OVER_QUERY_LIMIT") {
    			energy.clear_country_info();
    		}
    	});
    });
    map.fitBounds(bounds);
}
