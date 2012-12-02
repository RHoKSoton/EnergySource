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
    var iconGreen = 'images/greenLarge.png';

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
    map.fitBounds(bounds);
}