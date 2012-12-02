var energy = {
	clicked_city: null,
	country_info: null,
	country_name: null,
	init: function() {
		energy.country_info = $("#country_info");
		energy.country_name = $("#country_name");
		var components_list = $("#components_list");
		for (var component in data.components) {
			for (var i = 0, i_len = data.components[component].length; i < i_len; i++) {
				var mf = data.components[component][i];
				var mf_name = mf.Manufacturer;
				components_list.append("<tr><td style='height:25px'><input name='component' data-comp_name='" + mf_name + "' id='" + mf_name + "' type='radio' style='display:none'/></td><td class='style3'><a class='component_link' href=''>" + mf_name + "(" + mf.Part + ") </a></td><td class='style4'><a class='score_link'><img class='score_light' align='right' alt='' src='images/Button-Blank-Red-icon.png' /></a></td></tr>");
			}
		}
		$(".score_link").hide();
		$("#clicked_city").closest("td").hide();
		$(".component_link").live("click", function(e) {
			energy.component_clicked($(this).closest("tr").find("input").attr("data-comp_name"));
			e.preventDefault();
		})
		$(".score_link").live("click", function(e) {
			energy.score_clicked($(this).closest("tr").find("input").attr("data-comp_name"));
			e.preventDefault();
		})
	},
	city_clicked: function(city_name) {
    console.log("Clicked: "+city_name);
		energy.clicked_city = city_name;
		$("#clicked_city").html(city_name);
		$(".score_link").show();
		$("#clicked_city").closest("td").show();
		for (var i = 0, i_len = scores.length; i < i_len; i++) {
			var score = scores[i];
			if (score.city === city_name) {
        var num_results = score.numResults || 0;
				var comp_dom = $("input[data-comp_name='" + score.manufacturer + "']");
				var image_link = 'Button-Blank-Red-icon.png';
				if (num_results < 1) {
					image_link = 'Button-Blank-Red-icon.png';
				}
				else if (num_results < 40) {
					image_link = 'Button-Blank-Yellow-icon.png';
				}
				else {
					image_link = 'Button-Blank-Green-icon.png';
				}
				comp_dom.closest("tr").find(".score_light").attr({'src': "images/" + image_link});
			}
		}
		
	},
	component_clicked: function(comp_name) {
		for (var i = 0, i_len = scores.length; i < i_len; i++) {
			var score = scores[i];
			if (score.city === energy.clicked_city && score.manufacturer === comp_name) {
				window.open("http://google.com/search?q=" + score.searchTerm, "_blank");
				break;
			}
		}
		
	},
	score_clicked: function(comp_name) {
		for (var i = 0, i_len = scores.length; i < i_len; i++) {
			var score = scores[i];
			if (score.city === energy.clicked_city && score.manufacturer === comp_name) {
				if (score.gResults.length > 0) {
					window.open(score.gResults[0].unescapedUrl, "_blank");
				}
				break;
			}
		}
	},
	display_country_info: function(country_name) {
		energy.country_name.html(country_name);
		energy.country_info.html(countries[country_name]);
	},
	clear_country_info: function() {
		energy.country_name.html("");
		energy.country_info.html("");
	}
}
$(function() {
	energy.init();
});
