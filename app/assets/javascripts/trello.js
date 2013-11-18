
function getCards() {
    updateLoggedIn();
    $("#output").empty();
    Trello.members.get("me", function(member) {
        $(".fullName").each(function(i, e) {
            $(e).text(member.fullName);
        });
        var $cards = $("<div>").attr({
            id: "card-list"
        }).text("Carregando cartões...").appendTo("#output");
        Trello.get("members/me/cards", function(cards) {
            $cards.empty();
            $.each(cards, function(ix, card) {
                $("<a>").attr({
                    href: card.url,
                    id: card.id,
                    target: "_blank",
                    draggable: true,
                    style: "width: 100%; display: none",
                    ondragstart: "dragCard(event)"
                }).addClass("card filter " + card.idBoard).text(card.name).appendTo($cards);
            });
        });
        loadFormCards();
        loadBoards();
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
    $(".fields:visible > .cartao_field").each(function(index, pps) {
        if (data == pps.value) {
            cartaoRepetido = true;
        }
    });
    if (cartaoRepetido == false) {
        $("#nova_atividade").click();
        var target = $(".fields").last();
        var card = $("#" + data);
        var input = $(target.children(".cartao_field")[0]);
        input.after(card);
        input.val(card.attr("id"));
    }
}

function dragCard(ev) {
    ev.dataTransfer.setData("Text", ev.target.id);
}

function loadFormCards() {
    $(".cartao_field").each(function(index, input) {
        var card_id = input.value;
        Trello.get("/cards/" + card_id, function(card) {
            $(input).after($("<a>").attr({
                href: card.url,
                id: card.id,
                target: "_blank",
                draggable: true,
                style: "width: 100%",
                ondragstart: "dragCard(event)"
            }).addClass("card filter " + card.idBoard).text(card.name));
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

function filterCards(obj) {
    $("#card-list ." + obj.id).toggle();
}

function getToken() {
    $("#key").val(Trello.key);
    $("#token").val(Trello.token);
}
