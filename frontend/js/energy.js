var energy = {
	clicked_city: null,
	init: function() {
		var components_list = $("#components_list");
		for (var component in data.components) {
			for (var i = 0, i_len = data.components[component].length; i < i_len; i++) {
				var mf = data.components[component][i];
				var mf_name = mf.Manufacturer;
				components_list.append("<tr><td><input name='component' data-comp_name='" + mf_name + "' id='" + mf_name + "' type='radio'/></td><td class='style3'><a class='component_link' href=''>" + mf_name + "(" + mf.Part + ") </a></td><td class='style4'><a class='score_link'><img class='score_light' align='right' alt='' src='images/Button-Blank-Red-icon.png' /></a></td></tr>");
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
		energy.clicked_city = city_name;
		$("#clicked_city").html(city_name);
		$(".score_link").show();
		$("#clicked_city").closest("td").show();
		for (var i = 0, i_len = scores.length; i < i_len; i++) {
			var score = scores[i];
			if (score.city === city_name) {
				var num_results = score.gResults.length;
				if (num_results > 0) {
					num_results = parseInt(score.numResults.replace(",", ""));
				}
				var norm_score = num_results / 1000;
				var comp_dom = $("input[data-comp_name='" + score.manufacturer + "']");
				var image_link = 'Button-Blank-Red-icon.png';
				if (norm_score < 0.03) {
					image_link = 'Button-Blank-Red-icon.png';
				}
				else if (norm_score < 0.1) {
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
	}
}
$(function() {
	energy.init();
});