checkTrello(getCards);
$(document).on('nested:fieldAdded', function(event) {
    createSlider(event.field.find('.slider'));
});
$('#boards').on('hidden', function() {
    ajustaAltura();
});
$('#boards').on('shown', function() {
    ajustaAltura();
});
initializeSliders();
updateHorasAtividades(sumSliders(), pega_horas_dia().totalHorasDia, $("#horas_atividades"));
ajustaAltura();

function tag_autocomplete_apply()
{
    $(".tag_autocomplete").autocomplete({
        source: availableTags
    });
}
