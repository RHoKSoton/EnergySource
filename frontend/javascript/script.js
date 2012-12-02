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

    for (i = 0; i < markers.length; i++) {
    
    	var city =  markers[i]["city"];
      var latitude, longitude;
      for (var j = 0; j < population.Kenya.length; j++) {
        var city2 = population.Kenya[j];
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

        google.maps.event.addListener(marker, 'click', (function (marker, i, city, map) {

            return function () {
                infowindow.setContent(city);
                infowindow.open(map, marker);
                energy.city_clicked(city);
            }
        })(marker, i, city, map));
        
    }
    var geocoder = new google.maps.Geocoder();
    /*
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
   */
    map.fitBounds(bounds);
}
