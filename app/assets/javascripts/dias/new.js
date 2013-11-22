checkTrello(getCards);
$(document).on('nested:fieldAdded', function(event) {
    createSlider(event.field.find('.slider'));
});
$(document).on('nested:fieldRemoved', function(event) {
    updateAllSliders();
});
$('#boards').on('hidden', function() {
    ajustaAltura();
});
$('#boards').on('shown', function() {
    ajustaAltura();
});
initializeSliders();
updateHorasAtividades(sumSliders(), pega_horas_dia(), $("#horas_atividades"));
ajustaAltura();