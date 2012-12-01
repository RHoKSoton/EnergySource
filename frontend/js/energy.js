var energy = {
	init: function() {
		var components_list = $("#components_list");
		var mfs = {};
		for (var i = 0, i_len = scores.length; i < i_len; i++) {
			var mf = scores[i].component.Manufacturer;
			if (!mfs[mf]) {
				components_list.append("<tr><td><input name='component' data-comp_name='" + mf + "' id='" + mf + "' type='radio'/></td><td class='style3'>" + mf + "(" + scores[i].component.Part + ") </td><td class='style4'><img class='score_light' align='right' alt='' src='/static/img/Button-Blank-Red-icon.png' /></td></tr>");
				mfs[mf] = 1;
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