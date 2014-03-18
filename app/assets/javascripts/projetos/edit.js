window.NestedFormEvents.prototype.insertFields = function(content, assoc, link) {
    if (assoc == "coordenacoes") {
        var a = $(content).insertBefore($('#novo_item_coordenador'));
        return a;
    }
    else {
        var a = $(content).insertBefore($('#novo_item'));
        //@author rezende, stein
        var tableData = a.children().eq(0);
        var usuario_id_hidden_input = $(document.createElement('input'));
        var new_random_id = a.children().eq(1).children().eq(0).attr('id').split('_')[3];
        id = $("#usuarios").val();
        nome = $("#usuarios").find("option[value='" + id + "']").text();
        usuario_id_hidden_input.attr({
            id: 'projeto_workons_attributes_' + new_random_id + '_usuario_id',
            name: 'projeto[workons_attributes][' + new_random_id + '][usuario_id]',
            value: id,
            type: 'hidden'
        });
        tableData.text(nome);
        tableData.append(usuario_id_hidden_input);
        a.find(".coordenador-select").chosen({
            width: "95%",
            no_results_text: "Nenhum resultado encontrado",
            placeholder_text_multiple: "Coordenadores..."
        });
        return a;
    }
};

checkTrello(getBoards);

$(document).ready(function() {
  if ($("input[name='super_projeto']:checked").val() == "true")
      mostraFilhos();
  else
      mostraPai();
})

$("#super_projeto_true").click(function() {
    mostraFilhos();
});

$("#super_projeto_false").click(function() {
    mostraPai();
});

function mostraPai() {
    $("#filhos").hide(200);
    $("#pai").show(200);
}

function mostraFilhos() {
    $("#filhos").show(200);
    $("#pai").hide(200);
}

$(".usuario-select").chosen({
    width: "95%",
    no_results_text: "Nenhum resultado encontrado",
    placeholder_text_single: "Escolha um usuario"
});

$('.usuario-select').on('change', function(evt, params) {
    $("#workon-add").click();
});

$('.coordenador-select').chosen({
    width: "95%",
    no_results_text: "Nenhum resultado encontrado",
    placeholder_text_multiple: "Coordenadores..."
});

$(".datepicker").datepicker({dateFormat: "dd/mm/yy"});