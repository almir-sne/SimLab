function validate()
{
    var horas_trabalhadas = pega_horas_dia();
    var horas_atividade = pega_horas_atividade();
    return(
        validar_horas(horas_trabalhadas, horas_atividade)
        );
}

function validar_horas(hDia, hAtividade)
{
    if(hDia <= 0 || hAtividade <= 0 || hAtividade > hDia)
    {
        if(hDia <=0)
            alert("horas no dia inválidas");
        else if(hAtividade <= 0)
            alert("horas da atividade inválidas");
        else
            alert("atividade não pode ter mais horas que o dia ¬¬");
        return false;
    }
    else
        return true;
}

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

function recalculaHoras() {
    var max_horas = pega_horas_dia();
    document.getElementById("dia_atividades_attributes_0_horas_4i").selectedIndex = max_horas/60;
    document.getElementById("dia_atividades_attributes_0_horas_5i").selectedIndex = max_horas%60;
}


function correctCheck(id, id_2) {
    if(document.getElementById(id).checked == true)
        if(document.getElementById(id_2).checked == true)
            document.getElementById(id_2).checked = false;
}

function getCards () {
    updateLoggedIn();
    $("#output").empty();
    Trello.members.get("me", function(member){
        $("#fullName").text(member.fullName);
        var $cards = $("<div>").text("Carregando cartões...").appendTo("#output");
        Trello.get("members/me/cards", function(cards) {
            $cards.empty();
            $.each(cards, function(ix, card) {
                $("<a>").attr({
                    href: card.url,
                    target: "trello",
                    id: card.id,
                    draggable: true,
                    style: "width: 100%",
                    ondragstart: "dragCard(event)"
                }).addClass("card").text(card.name).appendTo($cards);
            });
        });
    });
};

function updateLoggedIn() {
    var isLoggedIn = Trello.authorized();
    $("#loggedout").toggle(!isLoggedIn);
    $("#loggedin").toggle(isLoggedIn);
}

function loginTrello(callback) {
    Trello.authorize({
        type: "popup",
        success: callback
    })
}

function checkTrello(callback) {
    Trello.authorize({
        interactive:false,
        success: callback
    });
}

function logoutTrello() {
    Trello.deauthorize();
    updateLoggedIn();
}

function allowDrop(event) {
    event.preventDefault();
}

function dropCard(event) {
    event.preventDefault();
    var data = event.dataTransfer.getData("Text");
    var cartaoRepetido = false;
    var target;
    if (event.target.tagName == "A")
        target = event.target.parentElement;
    else
        target = event.target;
    if (target.className == "nodrop")
        target = target.parentElement;
    var name =  target.previousElementSibling.name.replace("observacao", "trello") + "[]"
    $.each(target.children, function(index, pps) {
        if (data == pps.childNodes[1].value) {
            cartaoRepetido = true;  
        }
    })
    if (cartaoRepetido == false) {
        formatCardLink($("#" + data), name).appendTo(target);
    }
}

function dragCard(ev) {
    ev.dataTransfer.setData("Text",ev.target.id);
}

function formatCardLink (card, name) {
    var div = $("<div>");
    div.addClass("nodrop");
    $("<a>").attr({
        href: card.attr("href"),
        target: "trello"
    }).addClass("card").text(card.html()).appendTo(div);
    $("<input>").attr({
        type: "checkbox",
        name: name,
        value: card.attr("id"),
        checked: true,
        style: "float: right"
    }).appendTo(div);
    return div;
}

function loadCard(card_id, id) {
    var parent = $("#" + id).parent();
    var name =  parent.prev().attr("name").replace("observacao", "trello") + "[]";
    Trello.get("/cards/" + card_id, function(card) {
        var div = $("<div>");
        div.addClass("nodrop");
        div.appendTo(parent);
        $("<a>").attr({
            href: card.url,
            target: "trello"
        }).addClass("card").text(card.name).appendTo(div);
        $("<input>").attr({
            type: "checkbox",
            name: name,
            value: card.id,
            checked: true,
            style: "float: right"
        }).appendTo(div);
    });
    $("#" + id).detach();
}

function getBoards () {
    updateLoggedIn();
    $("#output").empty();
    Trello.members.get("me", function(member){
        $("#fullName").text(member.fullName);
        var $cards = $("<div>").text("Carregando cartões...").appendTo("#output");
        Trello.get("members/me/cards", function(cards) {
            $cards.empty();
            $.each(cards, function(ix, card) {
                $("<a>").attr({
                    href: card.url,
                    target: "trello",
                    id: card.id,
                    draggable: true,
                    style: "width: 100%",
                    ondragstart: "dragCard(event)"
                }).addClass("card").text(card.name).appendTo($cards);
            });
        });
    });

};