function selectPais(){

  var select = document.createElement("select");
  var cartoes_pais = $("#cartoes_pais_ids").val().split(" ");
  var cartoes_pais_trello = $("#cartoes_pais_trello_ids").val().split(" ");

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
    option = document.createElement("option");
    option.setAttribute("value", cartoes_pais[i]);
    Trello.get("/cards/" + cartoes_pais_trello[i], function(card){
      option.innerHTML = card.name
    })
    select.appendChild(option);
  }
  document.getElementById("cartao_pai_select").appendChild(select);
}
loginTrello(selectPais)
