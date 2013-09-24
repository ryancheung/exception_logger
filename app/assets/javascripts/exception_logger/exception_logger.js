$(function () {
	function CSRFProtection(xhr) {
	    var token = $('meta[name="csrf-token"]').attr('content');
	    if (token) xhr.setRequestHeader('X-CSRF-Token', token);
	};

	function ajax_headers() {
		if ('ajaxPrefilter' in $) $.ajaxPrefilter(function(options, originalOptions, xhr){ CSRFProtection(xhr) });
		else $(document).ajaxSend(function(e, xhr){ CSRFProtection(xhr) });
	};

	ajax_headers();

	$(document).on('click', '.show_link', function(event) {
		$.get($(this).attr("href"));
		return false;
	});

	$(document).on('click', '.close_link', function(event) {
		$("#showpage").hide();
		return false;
	});

	$(document).on('click', '.delete_link', function(event) {
		$.ajax({
			url: $(this).attr("href"),
			type: 'DELETE'
		});
		return false;
	});

	$(document).on('click', '.delete_visible_link', function(event) {
		var arr=$('tr.exception').map(function() { var id = $(this).attr("id"); return parseInt(id.replace(/^\w+_/, '')); }).get();
		$.ajax({
			url: $(this).attr("href"),
			type: 'POST',
			data: $.param({ids: arr}),
			dataType: 'script'
		});
		return false;
	});

	$(document).on('click', '.filter_link', function(event) {
		$('.filter_link').removeClass('selected');
		$(this).addClass('selected');
		$.ajax({
			url: $(this).attr("href"),
			type: 'POST',
			dataType: 'script'
		});
		return false;
	});

	$(document).on('click', '#query-form :submit', function(event) {
		$.ajax({
			url: $("#query-form").attr("action"),
			type: 'POST',
			data: $("#query-form").serialize(),
			dataType: 'script'
		});
		return false;
	});

	$(document).on('click', ".pagination a", function() {
		$.getScript(this.href);
		return false;
	});
});

