var energy = {
	init: function() {
		var components_list = $("#components_list");
		for (var component in data.components) {
			for (var i = 0, i_len = data.components[component].length; i < i_len; i++) {
				var mf = data.components[component][i];
				var mf_name = mf.Manufacturer;
				components_list.append("<tr><td><input name='component' data-comp_name='" + mf_name + "' id='" + mf_name + "' type='radio'/></td><td class='style3'>" + mf_name + "(" + mf.Part + ") </td><td class='style4'><img class='score_light' align='right' alt='' src='/static/img/Button-Blank-Red-icon.png' /></td></tr>");
			}
		}
	},
	city_clicked: function(city_name) {
		for (var i = 0, i_len = scores.length; i < i_len; i++) {
			var score = scores[i];
			if (score.city === city_name) {
				var comp_dom = $("input[data-comp_name='" + score.component.Manufacturer + "']");
				var image_link = 'Button-Blank-Red-icon.png';
				var norm_score = parseInt(score.results) / 1000;
				if (norm_score < 0.3) {
					image_link = 'Button-Blank-Red-icon.png';
				}
				else if (norm_score < 0.7) {
					image_link = 'Button-Blank-Yellow-icon.png';
				}
				else {
					image_link = 'Button-Blank-Green-icon.png';
				}
				comp_dom.closest("tr").find(".score_light").attr({'src': "/static/img/" + image_link});
			}
		}
	}
}
$(function() {
	energy.init();
});