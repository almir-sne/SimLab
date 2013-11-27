function pega_horas_dia()
{   
    var totalHorasTrabalhadas = 0;
    var intervalo = 0;
    var tempoTotal = 0;
    var primeiraEntrada = 0;
    var entrada = 0;
    var saida = 0;
    $('.horario_select').each(
      function(i,e) {
        var entradaH = 0;
        var entradaM = 0;
        var saidaH = 0;
        var saidaM = 0;
        if ((e.className.indexOf('entrada_horario') != -1) && (e.id.indexOf('4i') != -1)) {
          entradaH = parseInt(e.value);
          entradaM = parseInt(e.nextElementSibling.value);
          entrada = (entradaH * 60) + entradaM;
          if (i == 0) {
            primeiraEntrada = entrada;
          }
        }
        else if ((e.className.indexOf('saida_horario') != -1) && (e.id.indexOf('4i') != -1)) {
          saidaH = parseInt(e.value);
          saidaM = parseInt(e.nextElementSibling.value);
          saida = (saidaH * 60) + saidaM;
          totalHorasTrabalhadas += (saida - entrada);
        }
      }   
    );
    return {
      totalIntervalo: (saida - primeiraEntrada - totalHorasTrabalhadas),
      totalHorasDia: totalHorasTrabalhadas
    };
}

function pega_horas_atividade() {
    var atividadeH = parseInt($("#dia_atividades_attributes_0_horas_4i").val());
    var atividadeM = parseInt($("#dia_atividades_attributes_0_horas_5i").val());
    return(atividadeH * 60 + atividadeM);
}

//@author rezende
function autocomplete_source(ac_source) {
    $('.typeahead').typeahead({
        source: ac_source,
        minLength: 0,
        items: ac_source.length,
        //peguei de tatiyants.com/how-to-use-json-objects-with-twitter-bootstrap-typeahead
        matcher: function(item) {
            if (this.query == "*")
                return true;
            else
            if (item.toLowerCase().indexOf(this.query.trim().toLowerCase()) != -1) {
                return true;
            }
            return false;
        }
    });
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

function getFirstValid(seletor) {
    seletor.value = "";
    $(seletor.children).each(function(i, e) {
        if ($(e).css('display') != 'none') {
            seletor.value = e.value;
            return;
        }
    });
}

function toggleObservacao(obj) {
    $(obj).next().toggle();
}

function ajustaAltura() {
    var height1 = $(window).height() - $("#atividades-title").height() -
            $("#dropover").height() - $("#upper-bar").height() - 170;
    var height2 = $(window).height() - $("#upper-bar").height() - $("#boards").height()
            - $("#collapse-button").height() - 150;
    $("#atividade-panel").height(height1);
    $("#output").animate({height: height2}, 400);
}

function toggleCollapse(obj) {
    if (obj.children[0].className == "icon-chevron-sign-right")
        obj.children[0].className = "icon-chevron-sign-down";
    else
        obj.children[0].className = "icon-chevron-sign-right"
}
