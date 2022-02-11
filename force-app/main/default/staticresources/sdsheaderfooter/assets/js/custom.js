// Search Button Click Function
function search_btn() {
	$('.search-btn').on('click', function() {
		$('.search-overlay').show();
		$(this).siblings('.search-input').css({'width': '200px' , 'opacity': '1', 'padding': '0.375rem 0.75rem', 'border': '1px solid #555555'});
	});

	$('.search-overlay').on('click', function() {
		$(this).hide();
		$('.search-input').css({'width': '0px' , 'opacity': '0', 'padding': '0', 'border': '0'});
	});
}


$(document).ready(function() {
	search_btn();
});