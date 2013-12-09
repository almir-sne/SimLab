$(document).ready(function() {
    $('#data-table').dataTable({
        "bPaginate": false,
        "sDom": 'RC<"clear">lfrtip',
        "oColVis": {
            "buttonText": "Exibir/esconder colunas"
        },
        "oLanguage": {
            "sZeroRecords": "Nenhum dado encontrado",
            "sInfo": "Exibindo _START_ de _END_ de _TOTAL_ entrada(s)",
            "sInfoEmpty": "Exibindo 0 de 0 de 0 entradas",
            "sInfoFiltered": "(filtrado de _MAX_ de entrada(s))",
            "sSearch": "Buscar:"
        }
    });
});

$(".ColVis_Button").ready(function() {
    $(".ColVis_Button").attr({
        style: "margin: 10px"
    }).appendTo("#navegacao");
});

$("#data-table_filter").ready(function() {
    $("#data-table_filter").attr({
        style: "margin: 10px; float: none; text-align: left;"

    }).appendTo("#navegacao");
});
