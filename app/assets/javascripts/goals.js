// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// Quick submit buttons on goals index will submit an execution with
// today's date on click...
$(document).on('click', '.quick-submit', function (e) {
  var action = $(this).data('action');
  $.post(action);
});

// TODO: remove?
jQuery(function($) {
  $("tr[data-link]").click(function() {
    window.location = $(this).data('link');
  });
});
