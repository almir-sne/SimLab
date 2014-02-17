$('#myTab a').click(function(e) {
  e.preventDefault();
  $(this).tab('show');
});

$(function() {
  $( "#datepicker1" ).datepicker();
  $( "#datepicker2" ).datepicker();
});

