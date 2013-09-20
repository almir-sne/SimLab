
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

function loadCard2(card_id, id) {
    var parent = $("#" + id)
    Trello.get("/cards/" + card_id, function(card) {
        var div = $("<div>");
        div.addClass("nodrop");
        div.appendTo(parent);
        $("<a>").attr({
            href: card.url,
            target: "trello"
        }).addClass("cardnaohover").text(card.name).appendTo(div);
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
    if (typeof projetos_boards != 'undefined') {
        if (projetos_boards[selector.value][0] !=  null) {
            $(".filter").css("display", "none");
            $.each(projetos_boards[selector.value], function(ix, board) {
                $("." + board).css("display", "inline-table");
            });
        }
        else
            $(".filter").css("display", "inline-table");
    }
}
