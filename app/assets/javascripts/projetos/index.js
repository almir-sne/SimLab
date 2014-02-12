  $('#tipo').bind('change', function() {
    location.href = "" + projpath + "?tipo=" + $(this).val()
  });

  $('.collapse-link').on('hidden', function() {
   console.log("-");
  });
