$(document).on('turbolinks:load', function() {
  var clipboard = new Clipboard('.clipboard-btn');
  console.log(clipboard);

  clipboard.on('success', function(e) {
    setTooltip(e.trigger, 'Copied!');
  });

  clipboard.on('error', function(e) {
    setTooltip(e.trigger, 'Failed!');
  });
});

function setTooltip(btn, message) {
  $(btn).attr('data-original-title', message)
        .tooltip('show');
}
