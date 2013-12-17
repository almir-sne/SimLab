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
      nome = ($('#autocomplete_field').val());
      usuario_id_hidden_input.attr('id', 'projeto_workons_attributes_'+new_random_id+'_usuario_id');
      usuario_id_hidden_input.attr('name', 'projeto[workons_attributes]['+new_random_id+'][usuario_id]');
      usuario_id_hidden_input.attr('type', 'hidden');
      $.ajax({
        url: url,
        data: {name: nome}, 
        success: function(result) { 
          usuario_id_hidden_input.attr('value', result);
        }
      });
      tableData.text(nome);
      tableData.append(usuario_id_hidden_input);
      return a;
      }
  } 
  
  checkTrello(getBoards);

  $(document).ready(function() {
    if($("input[name='super_projeto']:checked").val() == "true")
      mostraFilhos();
    else
      mostraPai();
  })

  $("#super_projeto_true").click(function(){
    mostraFilhos();
  });

  $("#super_projeto_false").click(function(){
    mostraPai();
  });

  function mostraPai(){
    $("#filhos").hide(200);
    $("#pai").show(200);
  }

  function mostraFilhos(){
    $("#filhos").show(200);
    $("#pai").hide(200);
  }
  
function set_autocomplete_equipe()
{
  $("#equipe_autocomplete").autocomplete({
        source: availableTags
    });
}