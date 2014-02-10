function loadUserCards() {
    var cardsList = $("#card-list");
    // reseta lista de cartões
    $("#boards :input").each(function(i, e) {
        if (e.checked)
            e.click();
    });
    cardsList.empty();
    var dontInclude = $("input.card-form").map(function() {
        return $(this).val()
    }).get();
    Trello.get("members/me/cards", function(cards) {
        $.each(cards, function(ix, card) {
            if (dontInclude.indexOf(card.id) == -1)
                $("<a>").attr({
                    href: card.url,
                    id: card.id,
                    target: "_blank",
                    draggable: true,
                    style: "width: 100%; display: none",
                    ondragstart: "dragCard(event)"
                }).addClass("card filter " + card.idBoard).text(card.name).appendTo(cardsList);
        });
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
    $(".trelloprogress").show();
    Trello.authorize({
        interactive: false,
        success: callback,
        name: "SimLab",
        scope: {read: true, write: true, account: false},
        expiration: "never"
    });
    $(".trelloprogress").hide();
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
    $(".edit_atividade .card-form").each(function(index, pps) {
        if (data == pps.value) {
            cartaoRepetido = true;
        }
    });
    if (cartaoRepetido == false) {
        var card = $("#" + data);
        $.ajax({
            type: "POST",
            url: "/atividades/ajax_form",
            data: {trello_id: card.attr("id"), dia_id: $("#dia_id").val()},
            success: function(result) {
                $("#atividade-panel form").last().find(".card-form").after(card);
                initializeSliders();
            },
            error: function(result) {
                return false;
            }
        });
    }
}

function dropPai(event) {
    event.preventDefault();
    var data = event.dataTransfer.getData("Text");
    var target = $(event.target.parentElement).find("#input-pai");
    var pai = $("#card-list #" + data).clone();
    $("#cartao_pai_trello_id").val(data);
    target.empty();
    pai.appendTo(target);
}

function dragCard(ev) {
    ev.dataTransfer.setData("Text", ev.target.id);
}

function loadTrelloData() {
    updateLoggedIn();
    $(".trelloprogress").show();
    Trello.members.get("me", function(member) {
        $(".fullName").each(function(i, e) {
            $(e).text(member.fullName);
        });
        if ($("#card-list").size() > 0) {
            loadUserCards();
        }
        $(".card-placeholder").each(function(index, input) {
            var card_id = input.id;
            Trello.get("/cards/" + card_id, function(card) {
                if (input.classList.contains("card-default")) {
                    loadDefaultCard(input, card);
                }
                else {
                    loadCard(input, card);
                }
            });
        });
        $(".trelloprogress").hide();
        getToken();
        loadBoards();
        loadBoardLinks();
        loadBoardLists();
    });
}


function loadCard(input, card) {
    var link = $("<a>").attr({
        href: card.url,
        title: card.name,
        target: "_blank"
    });
    $(input).after(link);
    if (input.classList.contains("card-father")) {
        link.attr({
            class: "cardnaohover"
        }).text("SIM");
        $(input).detach();
    }
    else if (input.classList.contains("card-abrev")) {
        var proj_id = "proj" + $(input).attr("pid") + "_mark";
        var text = getTime(input.value).replace(" hora(s)", " - ");
        if (card.name.length > 15)
            text += card.name.substr(0, 15) + "...";
        else
            text += card.name;
        $(input).before($("<br/>"));
        link.attr({
            class: proj_id
        }).text(text);
        $(input).detach();
    }
    else if (input.classList.contains("card-form")) {
        link.attr({
            id: card.id,
            draggable: true,
            style: "width: 100%",
            ondragstart: "dragCard(event)",
            class: "card filter " + card.idBoard
        }).text(card.name);
    }
}

function loadDefaultCard(input, card) {
    var div = $("<div>");
    div.addClass("nodrop");
    $(input).after(div);
    $("<a>").attr({
        href: card.url,
        target: "_blank",
        class: "cardnaohover"
    }).text(card.name).appendTo(div);
    if (input.value > 0)
        $("<div>").attr({style: "color: black"}).text(getTime(input.value)).appendTo(div);
    if (input.classList.contains("with-description")) {
        $("<div>").attr({
            style: "color: black; margin: 10px"
        }).html(card.desc.replace(/\n/g, "<br/>")).appendTo(div);
    }
    $("<br/>").appendTo(div);
    $(input).detach();
}

function loadBoards() {
    $(".board-placeholder").each(function(index, input) {
        var board_id = input.value;
        $(".trelloprogress").show();
        Trello.get("/boards/" + board_id,
                function(board) {
                    $(input).after(board.name);
                    $(input).detach();
                    $(".trelloprogress").hide();
                },
                function(e) {
                    $(input.parentElement).remove();
                }
        );
    });
}

function loadBoardLinks() {
    $(".board-link").each(function(index, link) {
        var board_id = $(link).html().trim();
        $(".trelloprogress").show();
        Trello.get("/boards/" + board_id, function(board) {
            $(link).html(board.name).show();
            $(".trelloprogress").hide();
        });
    });
}

function loadBoardLists() {
    if ($("#board").length > 0) {
        var board_id = $("#board").val();
        var listDiv = $("#list-div");
        $(".trelloprogress").show();
        Trello.get("/boards/" + board_id, function(board) {
            $("#selected-board").html(board.name);
            $(".trelloprogress").hide();
        });
        $(".trelloprogress").show();
        Trello.get("/boards/" + board_id + "/lists?cards=open&card_fields=name,url&fields=name", function(lists) {
            $(lists).each(function(ix, list) {
                $("<h3>").attr({
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
                $("<th>").html("Estimativas").appendTo(header);
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
                    $("<a>").attr({
                        href: "/estimativas/cartao/" + card.id,
                        target: "_blank"
                    }).text("Estimar").appendTo(td);
                    td.appendTo(tr);
                    tr.appendTo(table);
                });
                $(".trelloprogress").hide();
            });
        });
    }
}

function getBoards() {
    updateLoggedIn();
    $("#output").empty();
    $(".trelloprogress").show();
    Trello.members.get("me", function(member) {
        $("#fullName").text(member.fullName);
        var $boards = $("<div>").appendTo("#output");
        Trello.get("members/me/boards", function(boards) {
            $boards.empty();
            var checked_boards = $("#boards_ids").val().split(" ");
            $.each(boards, function(ix, board) {
                if (board.closed == false) {
                    var div = $("<div>");
                    div.appendTo($boards);
                    $("<input>").attr({
                        type: "checkbox",
                        name: "trello[]",
                        value: board.id,
                        checked: (checked_boards.indexOf(board.id) > -1)
                    }).appendTo(div);
                    $("<a>").attr({
                        href: board.url,
                        target: "_blank"
                    }).addClass("card").text(board.name).appendTo(div);
                }
            });
        });
        $(".trelloprogress").hide();
    });
}

function filterCards(obj) {
    $("#card-list ." + obj.id).toggle();
}

function getToken() {
    $("input[name='key']").val(Trello.key);
    $("input[name='token']").val(Trello.token);
}
