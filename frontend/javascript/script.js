function initializeMaps() {
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
    
        var latitude = markers[i]["latitude"];
    	var longitude =  markers[i]["longitude"];
    	var city =  markers[i]["city"];
        
        pos = new google.maps.LatLng(latitude, longitude);
        bounds.extend(pos);

        if (markers[i]["numResults"] >= 100) {
            image = "images/greenLarge.png";
        } else if (markers[i]["numResults"] >3) {
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

        google.maps.event.addListener(marker, 'click', (function (marker, i) {

            return function () {
                infowindow.setContent(city);
                infowindow.open(map, marker);
                energy.city_clicked(city);
            }
        })(marker, i));
        
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