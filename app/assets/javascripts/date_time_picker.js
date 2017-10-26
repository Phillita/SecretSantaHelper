$(document).on('turbolinks:load', function() {
  $('.form_datetime').datetimepicker({
    format: 'YYYY-MM-D ha',
    showClear: true,
    ignoreReadonly: true
  });
});
