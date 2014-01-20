window.NestedFormEvents.prototype.insertFields = function(content, assoc, link) {
    var a = $(content).insertBefore($('#novo_item'));
    //@author rezende, stein
    //vou comentar linha por linha para poder refatorar depois
    //'td' que será adicionado, depende apenas do novo_item
    var tableData = a.children().eq(0);
    //criando um input para ser colocado na nova linha, depende de se se quer um input
    var usuario_id_hidden_input = $(document.createElement('input'));
    //talvez o indice do id seja sempre o mesmo
    var new_random_id = a.children().eq(1).children().eq(0).attr('id').split('_')[3];
    nome = ($('#autocomplete_field').val());
    //depende do model pai (workon) e do model filho (coordenacoes)
    //também depende de quais fields se quer
    usuario_id_hidden_input.attr('id', 'workon_coordenacoes_attributes_' + new_random_id + '_usuario_id');
    usuario_id_hidden_input.attr('name', 'workon[coordenacoes_attributes][' + new_random_id + '][usuario_id]');
    usuario_id_hidden_input.attr('type', 'hidden');
    //é necessário achar o id do novo usuário
    //pode ser refatorado sem ajax, talvez
    $.ajax({
        url: url,
        data: {name: nome},
        success: function(result) {
            usuario_id_hidden_input.attr('value', result);
        }
    });
    //dar append nas coisas
    tableData.text(nome);
    tableData.append(usuario_id_hidden_input);
    return a;
}

function set_autocomplete_equipe() {
    $("#autocomplete_field").autocomplete({
        source: users_projeto
    });
}