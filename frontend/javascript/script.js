var markers = [
		['Nairobi', -1.283330, 36.816670, 2000],
		['Mombasa', -4.050000, 39.666670, "iconRed"],
		['Nakuru', -0.283330, 36.066670, "iconYellow"],
		['Kisumu', -0.100000, 34.750000, "iconYellow"],
	    ['Marsabit', 2.333330, 37.983330, "iconGreen"],
		['Eldoret', 0.516670, 35.283330, "iconGreen"]
	];



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



    for (i = 0; i < markers.length; i++) {
        var pos = new google.maps.LatLng(markers[i][1], markers[i][2]);
        bounds.extend(pos);
        //var image = "images/grayLarge.png";

        /*
        if (markers[i][3] == "iconRed") {
        image =  "images/grayLarge.png";
        } else if (markers[i][3] == "iconYellow") { 
        image =  "images/yellowLarge.png";
        }else{
        image =  "images/greenLarge.png";
        }
            
            
        */

        if (markers[i][3] >= 100) {
            image = "images/greenLarge.png";
        } else if (markers[i][3] <= 3) {
            image = "images/redLarge.png";
        } else {
            image = "images/yellowLarge.png";
        }


        marker = new google.maps.Marker({
            position: pos,
            map: map,
            title: markers[i][0],
            icon: image
        });



        /*
        marker = new google.maps.Marker({
        map: map,
        position: pos,
        title: markers[i][0],
        icon: image
        });

        */

        google.maps.event.addListener(marker, 'click', (function (marker, i) {

            return function () {
                infowindow.setContent(markers[i][0]);
                infowindow.open(map, marker);
                energy.city_clicked(markers[i][0]);
            }
        })(marker, i));
    }
    map.fitBounds(bounds);
}