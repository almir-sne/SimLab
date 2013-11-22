$('#menu_select').bind('change', function() { location.href = url + '?usuario_id=' + $(this).val() });

$('#myTab a').click(function(e) {
  e.preventDefault();
  $(this).tab('show');
});
