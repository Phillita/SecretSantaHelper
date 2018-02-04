$(document).on('turbolinks:load', function() {
  // When hitting "Enter", make sure the user is hitting the next button.
  $('body').on('keypress', 'form.wizard', function(e) { 
    if(e.which === 13) { // Enter
      e.preventDefault();
      $('form.wizard').find('input[type=submit].next').trigger('click');
    }
  });
});