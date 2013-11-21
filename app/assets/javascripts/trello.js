
function getCards() {
    updateLoggedIn();
    $("#output").empty();
    Trello.members.get("me", function(member) {
        $(".fullName").each(function(i, e) {
            $(e).text(member.fullName);
        });
        var $cards = $("<div>").text("Carregando cartões...").appendTo("#output");
        Trello.get("members/me/cards", function(cards) {
            $cards.empty();
            $.each(cards, function(ix, card) {
                $("<a>").attr({
                    href: card.url,
                    id: card.id,
                    target: "_blank",
                    draggable: true,
                    style: "width: 100%",
                    ondragstart: "dragCard(event)"
                }).addClass("card filter " + card.idBoard).text(card.name).appendTo($cards);
            });
            filterCards(document.getElementById('dia_atividades_attributes_0_projeto_id'));
        });
        loadFormCards();
        getToken();
    });
}

function updateLoggedIn() {
    var isLoggedIn = Trello.authorized();
    $(".loggedout").toggle(!isLoggedIn);
    $(".loggedin").toggle(isLoggedIn);
}

function loginTrello(callback) {
    Trello.authorize({
        type: "popup",
        success: callback,
        name: "SimLab",
        scope: {read: true, write: true, account: false},
        expiration: "never"
    });
}

function checkTrello(callback) {
    Trello.authorize({
        interactive: false,
        success: callback,
        name: "SimLab",
        scope: {read: true, write: true, account: false},
        expiration: "never"
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
        target = target.parentElement;
    }
    var name = $(target.parentElement).find(".hora_field")[0].name.replace("horas", "trello") + "[" + data + "]";
    $.each(target.children, function(index, pps) {
        if (data == pps.childNodes[1].value) {
            cartaoRepetido = true;
        }
    });
    if (cartaoRepetido == false) {
        formatCardLink($("#" + data), name).appendTo(target);
    }
}

function dragCard(ev) {
    ev.dataTransfer.setData("Text", ev.target.id);
}

function formatCardLink(card, name) {
    var div = $("<div>");
    div.addClass("nodrop");
    $("<a>").attr({
        href: card.attr("href"),
        target: "_blank"
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

function loadFormCards() {
    $(".card-placeholder-form").each(function(index, input) {
        var parent = input.parentElement;
        var card_id = input.id;
        var horas = $(parent.parentElement).find(".hora_field")[0];
        var name = horas.name.replace("horas", "trello") + "[" + card_id + "]";
        Trello.get("/cards/" + card_id, function(card) {
            var div = $("<div>");
            div.addClass("nodrop");
            div.appendTo(parent);
            $("<a>").attr({
                href: card.url,
                target: "_blank"
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
            updateHorasAtividades(sumCardSliders(parent), horas.value, $(parent.parentElement).find("#horas_cartao"));
        });
    });
}

function loadSimpleCards() {
    updateLoggedIn();
    Trello.members.get("me", function(member) {
        $(".fullName").each(function(i, e) {
            $(e).text(member.fullName);
        });
        $(".card-placeholder").each(function(index, input) {
            var parent = input.parentElement;
            var card_id = input.id;
            Trello.get("/cards/" + card_id, function(card) {
                var div = $("<div>");
                div.addClass("nodrop");
                div.appendTo(parent);
                $("<a>").attr({
                    href: card.url,
                    target: "_blank"
                }).addClass("cardnaohover").text(card.name).appendTo(div);
                if (input.value > 0)
                    $("<div>").attr({style: "color: black"}).text(getTime(input.value)).appendTo(div);
                $("<br/>").appendTo(div);
                $(input).detach();
            });
        });
        getToken();
        loadBoards();
        loadAbrevCards();
        loadBoardLinks();
        loadBoardLists();
    });
}

function loadAbrevCards() {
    $(".card-abrev").each(function(index, input) {
        var parent = input.parentElement;
        var card_id = input.id;
        Trello.get("/cards/" + card_id, function(card) {
            var div = $(parent).find(".day-link");
            var text = getTime(input.value).replace(" hora(s)", " - ");
            if (card.name.length > 10)
                text += card.name.substr(0, 10) + "...";
            else
                text += card.name;
            $("<br/>").appendTo(div);
            $("<a>").attr({
                href: card.url,
                target: "_blank",
                title: card.name
            }).text(text).appendTo(div);
            $(input).detach();
        });
    });
}

function loadBoards() {
    $(".board-placeholder").each(function(index, input) {
        var board_id = input.value;
        Trello.get("/boards/" + board_id, function(board) {
            $(input).after(board.name);
            $(input).detach();
        });
    });
}



function loadBoardLinks() {
    $(".board-link").each(function(index, link) {
        var board_id = $(link).html().trim();
        Trello.get("/boards/" + board_id, function(board) {
            $(link).html(board.name);
        });
    });
}

function loadBoardLists() {
    if ($("#selected-board").length > 0) {
        var board_id = $("#selected-board").html().trim();
        var listDiv = $("#list-div");
        Trello.get("/boards/" + board_id, function(board) {
            $("#selected-board").html(board.name);
        });
        Trello.get("/boards/" + board_id + "/lists?cards=open&card_fields=name,url&fields=name", function(lists) {
            $(lists).each(function(ix, list) {
                var h3 = $("<h3>").attr({
                    "data-toggle": "collapse",
                    "data-target": "#list_" + ix,
                    style: "cursor: pointer"
                }).html(list.name).appendTo(listDiv);
                var collapse = $("<div>").attr({
                    id: "list_" + ix
                }).addClass("collapse").appendTo(listDiv);
                var table = $("<table>").addClass("list-table").appendTo(collapse);
                var header = $("<tr>");
                $("<th>").html("Cartão").appendTo(header);
                $("<th>").html("Estimativa").appendTo(header);
                $("<th>").html("Mais detalhes").appendTo(header);
                header.appendTo(table);
                $(list.cards).each(function(i, card) {
                    var tr = $("<tr>");
                    var td = $("<td>");
                    $("<a>").attr({
                        href: card.url,
                        id: card.id,
                        target: "_blank"
                    }).text(card.name).appendTo(td);
                    td.appendTo(tr);
                    td = $("<td>");
                    var select = $("#estimativa").clone();
                    select.attr({
                        id: "estimativa_" + card.id,
                        name: "estimativa[" + card.id + "]",
                        style: "display: inherit"
                    }).appendTo(td);
                    td.appendTo(tr);
                    $("<td>").appendTo(tr);
                    tr.appendTo(table);
                });
            });
        });
    }
}

function getBoards() {
    updateLoggedIn();
    $("#output").empty();
    Trello.members.get("me", function(member) {
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
                        target: "_blank"
                    }).addClass("card").text(board.name).appendTo(div);
                }
            });
        });
    });
}

function filterCards(selector) {
    if (typeof projetos_boards != 'undefined') {
        if (projetos_boards[selector.value][0] != null) {
            $(".filter").css("display", "none");
            $.each(projetos_boards[selector.value], function(ix, board) {
                $("." + board).css("display", "inline-table");
            });
        }
        else
            $(".filter").css("display", "inline-table");
    }
}

function getToken() {
    $("#key").val(Trello.key);
    $("#token").val(Trello.token);
}
