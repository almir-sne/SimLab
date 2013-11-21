  $('#filtra').click(function() {
    location.href = "/ausencias?mes=" + $('#mes_select').val() + "&ano=" + $('#ano_select').val() + "&usuario_id=" + $('#usuario_select').val() + "&projeto_id=" + $('#projeto_select').val() + "&dia=" + $('#dia_select').val()
  });