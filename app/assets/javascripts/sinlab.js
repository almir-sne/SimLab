function pega_horas_dia()
{
    var entradaH = parseInt($('#dia_0_entrada').val());
    var entradaM = parseInt($('#dia_0_entrada').next().val());
    var saidaH = parseInt($('#dia_0_saida').val());
    var saidaM = parseInt($('#dia_0_saida').next().val());
    var intervaloH = parseInt($('#dia_0_intervalo').val());
    var intervaloM = parseInt($('#dia_0_intervalo').next().val());
    var entrada = entradaH * 60 + entradaM;
    var saida = saidaH * 60 + saidaM;
    var intervalo = intervaloH * 60 + intervaloM;
    return saida - entrada - intervalo;
}

function pega_horas_atividade() {
    var atividadeH = parseInt($("#dia_atividades_attributes_0_horas_4i").val());
    var atividadeM = parseInt($("#dia_atividades_attributes_0_horas_5i").val());
    return(atividadeH * 60 + atividadeM);
}

function toggleAusencia() {
    $("#ausencias").show();
    $("#meses-button").show();
    $("#meses").hide();
    $("#ausencias-button").hide();
}

function toggleMeses() {
    $("#meses").show();
    $("#ausencias-button").show();
    $("#ausencias").hide();
    $("#meses-button").hide();
}

function escondeProjetos() {
    var seletores = $(".fields:visible > .projeto-seletor");
    seletores.children().show();
    seletores.each(function(i, e) {
        seletores.each(function(j, f) {
            if (e != f)
                $($(f).find('[value=' + e.value + ']').hide());
            if ($(f.selectedOptions).css('display') == 'none')
                getFirstValid(f);
        });
    });
}

function getFirstValid(seletor) {
    seletor.value = "";
    $(seletor.children).each(function(i, e) {
        if ($(e).css('display') != 'none') {
            seletor.value = e.value;
            return;
        }
    });
}