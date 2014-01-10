function getCards() {
    updateLoggedIn();
    
    $("#output").empty();
    $(".trelloprogress").show();
    Trello.members.get("me", function(member) {
        $(".fullName").each(function(i, e) {
            $(e).text(member.fullName);
        });
        var $cards = $("<div>").attr({
            id: "card-list"
        }).appendTo("#output");
        
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
        $(".trelloprogress").hide();
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
    $(".fields:visible > .cartao_field").each(function(index, pps) {
        if (data == pps.value) {
            cartaoRepetido = true;
        }
    });
    if (cartaoRepetido == false) {
        $("#nova_atividade").click();
        var target = $(".fields").last();
        var card = $("#" + data);
        var input = $(target.find(".cartao_field")[0]);
        input.after(card);
        input.val(card.attr("id"));
        var tags = $(".tag_autocomplete").last();
        var tag_link = $("._card").last();
        $.ajax({
            url: "/dias/cartao_tags",
            data: {cartao_id: card.attr("id")},
            success: function(result) {
                tags.val(result);
            }
        });
        var field_name = "cartao[" + data + "][tags]";
        tags.attr("name",field_name);
        tag_link[0].id = card.attr("id") + "_card";
        insertFather(target, data);
    }
}

function insertFather(atividadeDiv, cartao_id) {
    var input = atividadeDiv.find("#input");
    $.ajax({
        url: "/dias/cartao_pai",
        data: {cartao_id: cartao_id},
        success: function(result) {
            input.empty();
            $("<input>").attr({
                id: "cartao_pai",
                value: result,
                type: "hidden",
                name: "cartao[" + cartao_id + "][cartao_pai]"
            }).appendTo(input);
            loadCardById(input, result);
        }
    });
}

function loadCardById(div, card_id) {
    $(".trelloprogress").show();
    Trello.get("/cards/" + card_id, function(card) {
        $("<a>").attr({
            href: card.url,
            id: card.id,
            target: "_blank",
            draggable: true,
            style: "width: 100%",
            ondragstart: "dragCard(event)"
        }).addClass("card filter " + card.idBoard).text(card.name).appendTo(div);
        $(".trelloprogress").hide();
    });
}

function dropPai(event) {
    event.preventDefault();
    var data = event.dataTransfer.getData("Text");
    var target = $(event.target.parentElement).find("#input");
    var pai = $("#" + data).clone();
    var card = $(event.target).parents("#atividade-form").find(".cartao_field")[0].value;
    target.empty();
    $("<input>").attr({
        id: "cartao_pai",
        value: data,
        type: "hidden",
        name: "cartao[" + card + "][cartao_pai]"
    }).appendTo(target);
    pai.appendTo(target);
}

function dragCard(ev) {
    ev.dataTransfer.setData("Text", ev.target.id);
}

function loadFormCards() {
    $(".cartao_field").each(function(index, input) {
        var card_id = input.value;
        $(".trelloprogress").show();
        Trello.get("/cards/" + card_id, function(card) {
            $(input).after($("<a>").attr({
                href: card.url,
                id: card.id,
                target: "_blank",
                draggable: true,
                style: "width: 100%",
                ondragstart: "dragCard(event)"
            }).addClass("card filter " + card.idBoard).text(card.name));
            $(".trelloprogress").hide();
        });
    });
}

function loadSimpleCards() {
    updateLoggedIn();
    $(".trelloprogress").show();
    Trello.members.get("me", function(member) {
        $(".fullName").each(function(i, e) {
            $(e).text(member.fullName);
        });
        $(".card-placeholder").each(function(index, input) {
            var parent = input.parentElement;
            var card_id = input.id;
            Trello.get("/cards/" + card_id, function(card) {
                if (input.classList.contains("father-abrev")) {
                    $("<a>").attr({
                        href: card.url,
                        title: card.name,
                        target: "_blank"
                    }).addClass("cardnaohover").text("SIM").appendTo(parent);
                }
                else {
                    var div = $("<div>");
                    div.addClass("nodrop");
                    div.appendTo(parent);
                    $("<a>").attr({
                        href: card.url,
                        target: "_blank"
                    }).addClass("cardnaohover").text(card.name).appendTo(div);
                    if (input.value > 0)
                        $("<div>").attr({style: "color: black"}).text(getTime(input.value)).appendTo(div);
                    if (input.classList.contains("with-description")) {
                        $("<div>").attr({
                            style: "color: black; margin: 10px"
                        }).html(card.desc.replace(/\n/g, "<br/>")).appendTo(div);
                    }

                    $("<br/>").appendTo(div);
                }
                $(input).detach();
                
            });
        });
        $(".trelloprogress").hide();
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
        var proj_id = "proj" + $(input).attr("pid") + "_mark";
        $(".trelloprogress").show();
        Trello.get("/cards/" + card_id, function(card) {
            var text = getTime(input.value).replace(" hora(s)", " - ");
            if (card.name.length > 10)
                text += card.name.substr(0, 10) + "...";
            else
                text += card.name;
            $("<br/>").appendTo(parent);
            $("<a>").attr({
                href: card.url,
                target: "_blank",
                title: card.name,
                class: proj_id
            }).text(text).appendTo(parent);
            $(input).detach();
            $(".trelloprogress").hide();
        });
    });
}

function loadBoards() {
    $(".board-placeholder").each(function(index, input) {
        var board_id = input.value;
        $(".trelloprogress").show();
        Trello.get("/boards/" + board_id, function(board) {
            $(input).after(board.name);
            $(input).detach();
            $(".trelloprogress").hide();
        });
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
        $(".trelloprogress").hide();
    });
}

function filterCards(obj) {
    $("#card-list ." + obj.id).toggle();
}

function getToken() {
    $("#key").val(Trello.key);
    $("#token").val(Trello.token);
}
