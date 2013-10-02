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
    var atividadeH =  parseInt($("#dia_atividades_attributes_0_horas_4i").val());
    var atividadeM =  parseInt($("#dia_atividades_attributes_0_horas_5i").val());
    return(atividadeH *60 + atividadeM);
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
    }
  });
}

/*
function gera_coordenador_form(workon_id) {
    //carregar a lista de coordenadores
    $.ajax({
      type: "POST",
      url: "/projetos/coordenadorform", 
        data: {wrkn_id: workon_id},
        async: false,
        success: function(result) {
          $("#crd_form").html("<%= escape_javascript(render(:partial => 'banana')).html_safe %>");
          $('#crd_form').modal('show');           
        }
    });  
}
*/
