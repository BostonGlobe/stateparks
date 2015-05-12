(function() { globe.onDefine('window.jQuery && $(".article-graphic.map").length', function() {

	require('./templates/templates.js');

	var masterSelector = '.article-graphic.map';
	var master = $(masterSelector);


	require('./main.js');

}); }());