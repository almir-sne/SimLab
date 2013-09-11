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

function pad (str, max) {
    return str.length < max ? pad("0" + str, max) : str;
}

function recalculaHoras() {
    var max_horas = pega_horas_dia();
    updateAllSliders(max_horas);
    $("#horas_do_dia").text(getTime(max_horas));
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
                }).addClass("card filter " + card.idBoard).text(card.name).appendTo($cards);
            });
            filterCards(document.getElementById('dia_atividades_attributes_0_projeto_id'));
        });
        loadCards();
    });
}

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
    var target = event.target;
    while (target.className != "trello-dropover") {
        target = target.parentElement
    }
    var name =  $(target.parentElement).find(".hora_field")[0].name.replace("horas", "trello") + "[" + data + "]"
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
        name: name + "[check]",
        value: true,
        checked: true,
        style: "float: right"
    }).appendTo(div);
    cardSlider(div, name);
    return div;
}

function loadCards() {
    $(".card-placeholder").each(function (index, input) {
        var parent = input.parentElement;
        var card_id = input.id
        var horas = $(parent.parentElement).find(".hora_field")[0]
        var name =  horas.name.replace("horas", "trello") + "[" + card_id + "]"
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
                name: name + "[check]",
                value: "true",
                checked: true,
                style: "float: right"
            }).appendTo(div);
            cardSlider(div, name, input.value);
            $(input).detach();
            updateHorasAtividades(sumCardSliders(parent), horas.value, $(parent.parentElement).find("#horas_cartao"))
        });
    });
}

function getBoards() {
    updateLoggedIn();
    $("#output").empty();
    Trello.members.get("me", function(member){
        $("#fullName").text(member.fullName);
        var $boards = $("<div>").text("Carregando boards...").appendTo("#output");
        Trello.get("members/me/boards", function(boards) {
            $boards.empty();
            $.each(boards, function(ix, board) {
                var check;
                $.each(segundaPraMim, function(index, pps) {
                    if (pps == board.id) {
                        check = true;
                    }
                });
                if (board.closed == false) {
                    var div = $("<div>");
                    div.appendTo($boards);
                    $("<input>").attr({
                        type: "checkbox",
                        name: "trello[]",
                        value: board.id,
                        checked: check
                    }).appendTo(div);
                    $("<a>").attr({
                        href: board.url,
                        target: "trello"
                    }).addClass("card").text(board.name).appendTo(div);
                }
            });
        });
    });
}

function filterCards(selector) {
    if (projetos_boards[selector.value][0] !=  null) {
        $(".filter").css("display", "none");
        $.each(projetos_boards[selector.value], function(ix, board) {
            $("." + board).css("display", "inline-table");
        });
    }
    else
        $(".filter").css("display", "inline-table");
}

/***********/
/* Sliders */
/***********/
var pog;
function slideTime(event, ui){
    $(event.target).parent().find("#time").text(
        getTime(ui.value)
        );
    pog = event;
    $(event.target).parent().find(".hora_field")[0].value = ui.value;
    if (event.target.parentElement.className == "slider") {
        updateHorasAtividades(sumSliders(), pega_horas_dia(), $("#horas_atividades"))
    }

    else {
        var parent = $(event.target).parents('div[class^="trello"]');
        updateHorasAtividades(sumCardSliders(parent), parent.parent().find(".hora_field")[0].value,
        $(parent.parent().find("#horas_cartao")[0]));
    }
}

function updateHorasAtividades(val, max, div) {
    div.text(getTime(val));
    div.removeClass();
    if (val > max)
        div.addClass("nok");
    else if (val == max)
        div.addClass("ok");
}

function sumSliders() {
    var val = 0;
    $(".slider > .hora_field").each (function(i, e) {
        val += parseInt(e.value);
    });
    return val;
}

function sumCardSliders(parent) {
    var val = 0;
    $(parent).find(".hora_field").each (function(i, e) {
        val += parseInt(e.value);
    });
    return val;
}

function getTime(val) {
    var hours = parseInt(val / 60);
    var minutes = pad(val % 60 + "", 2);
    return hours + ":" + minutes + " horas";
}

function initializeSliders() {
    $(".slider").each (function(i, e) {
        createSlider($(e));
    });
}

function createSlider(sliderParent) {
    var time = sliderParent.find(".hora_field")[0].value
    initSlider(sliderParent.find('#slider'), time, pega_horas_dia());
    initTime(sliderParent.find('#time'), time);
}

function initTime(div, time) {
    div.text(getTime(time));
}

function initSlider(div, time, max_time) {
    div.slider({
        min: 0,
        max: max_time,
        value: time,
        step:10,
        slide: slideTime,
        orientation: "horizontal",
        range: "min"
    });
}

function updateAllSliders(maxtime) {
    $(".slider, .card-slider").each (function(i, e) {
        if ($(e).find(".hora_field")[0].value  > maxtime) {
            $(e).find(".hora_field")[0].value = maxtime;
            initTime($(e).find("#time"), maxtime);
            $(e).find("#slider").slider("value", maxtime);
        }
        $(e).find("#slider").slider("option", "max", maxtime);
    });
}

function cardSlider(parent, name, time) {
    var div = $("<div>");
    div.addClass("card-slider");
    $("<div>").attr({
        id: "slider"
    }).appendTo(div);
    $("<div>").attr({
        id: "time"
    }).appendTo(div);
    $("<input>").attr({
        type: "text",
        name: name + "[slider]",
        value: time,
        style: "display: none"
    }).addClass("hora_field").appendTo(div);
    div.appendTo(parent);
    createSlider(div);
}