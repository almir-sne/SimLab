$(".month-table").height($(".month-table").width() + 20)

$('#myTab a').click(function(e) {
    e.preventDefault();
    $(this).tab('show');
})

$(".day-calendario td").hover(
        function() {
            $(this).children().eq(0).show();
        },
        function() {
            $(this).children().eq(0).hide();
        }
);
$("a.day-link").on("dragstart", function(e) {
    return false;
});
  