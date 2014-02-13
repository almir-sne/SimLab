function selectPais(){

  var select = document.createElement("select");
  var cartoes_pais = $("#cartoes_pais_ids").val().split(" ");
  var cartoes_pais_trello = $("#cartoes_pais_trello_ids").val().split(" ");
  var cartoes_pais_opcoes = new Array();

  select.setAttribute("name", "cartao_pai");
  select.setAttribute("id", "cartao_pai");
  select.setAttribute("class", "menu_select");

  option = document.createElement("option");
  option.setAttribute("value", "0");
  option.innerHTML = "Pais - Todos";
  select.appendChild(option);

  option = document.createElement("option");
  option.setAttribute("value", "-1");
  option.innerHTML = "Pais - Nenhum";
  select.appendChild(option);

  for(i=0; i<cartoes_pais.length; i++){
    Trello.get("/cards/" + cartoes_pais_trello[i], function(card){
      cartoes_pais_opcoes[i] = document.createElement("option");
      cartoes_pais_opcoes[i].setAttribute("value", cartoes_pais[i]);
      cartoes_pais_opcoes[i].innerHTML = card.name;
      select.appendChild(cartoes_pais_opcoes[i]);
    })
  }

  document.getElementById("cartao_pai_select").appendChild(select);
}
loginTrello(selectPais)
