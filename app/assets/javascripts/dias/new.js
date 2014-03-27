recalculaHoras();

$(document).on('nested:fieldAdded', function(event) {
    var form = event.field.closest("form");
    formChanged(form);
    createSlider(event.field.find('.slider'));
    $(".timepicker").timepicker({
        showPeriodLabels: false
    });
});

$(document).on('nested:fieldRemoved', function(event) {
    formChanged(event.field.closest("form"));
});

$('.timepicker').timepicker({
    showPeriodLabels: false
});

$('#boards').on('hidden', function() {
    ajustaAltura();
});

$('#boards').on('shown', function() {
    ajustaAltura();
});

initializeSliders();
updateHorasAtividades(sumSliders(), pega_horas_dia().totalHorasDia, $("#horas_atividades"));

function recalculaHoras() {
    // updateAllSliders();
    horas = pega_horas_dia();
    $("#horas_do_dia").text(getTime(horas.totalHorasDia));
    $("#dia_intervalo").text(getTime(horas.totalIntervalo));
}

$(window).on('resize', function() {
    ajustaAltura();
});

window.onbeforeunload = function(e) {
    return checkForm();
};
