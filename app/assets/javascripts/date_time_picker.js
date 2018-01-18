var load_date_time_picker = function() {
  $('.form_datetime').datetimepicker({
    format: 'YYYY-MM-D ha',
    showClear: true,
    ignoreReadonly: true
  });
  $('body').on('focus', '.form_datetime', function() {
    $(this).data('DateTimePicker').show();
  });
};
$(document).on('turbolinks:load', function() {
  load_date_time_picker();
});
