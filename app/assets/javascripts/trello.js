function loadUserCards() {
    var cardsList = $("#card-list");
    cardsList.empty();
    var dontInclude = $("input.card-form").map(function() {
        return $(this).val();
    }).get();
    Trello.get("members/me/cards", function(cards) {
        $.each(cards, function(ix, card) {
            if (dontInclude.indexOf(card.id) == -1)
                $("<a>").attr({
                    href: card.shortUrl,
                    id: card.id,
                    target: "_blank",
                    draggable: true,
                    style: "width: 100%; display: none",
                    ondragstart: "dragCard(event)"
                }).addClass("card filter " + card.idBoard).text(card.name).appendTo(cardsList);
        });
        $("#boards :input").each(function(i, e) {
            if (e.checked)
                filterCards(e);
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
    var target = $("#input-pai");
    var pai = $("#card-list #" + data).clone();
    $("#cartao_pai_trello_id").val(data);
    target.empty();
    pai.appendTo(target);
}

function removePai() {
    var father_id = $("#cartao_pai_trello_id").val();
    var card_url = $(".cardnaohover")[0].href;
    removeFromChecklist(card_url, father_id);
    $("#cartao_pai_trello_id").val("");
    $("#input-pai").empty();
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
        if ($("#cartoes_pais_ids").size() > 0) {
            selectPais();
        }
        getToken();
        loadBoards();
        loadBoardLinks();
        loadBoardLists();
    });
}


function loadCard(input, card) {
    var link = $("<a>").attr({
        href: card.shortUrl,
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
        href: card.shortUrl,
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
    if (input.classList.contains("get-tags")) {
        mergeTags(card.name);
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
                    ajustaAltura();
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
                        href: card.shortUrl,
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

function updateTrelloData(card_id, mergeTags, showAlert) {
    var regex_tags = /[\[][^\[\]]*[\]]/g;
    var tags = null;
    Trello.get("/cards/" + card_id, function(card) {
        tags = card.name.match(regex_tags);
        $.ajax({
            url: '/cartoes/dados.json',
            type: "GET",
            dataType: "json",
            data: {trello_id: card.id, tags: tags, merge_tags: mergeTags},
            success: function(data) {
                if (data != "erro") {
                    if (data.pai)
                        Trello.get("/cards/" + data.pai, function(pai) {
                            updateTrelloData(data.pai, true, false);
                            putOnTrello(card, {estimativa: data.estimativa, pai: pai, horas_filhos: data.horas_filhos,
                                horas: data.horas, tags: data.tags, showAlert: showAlert});
                        });
                    else
                        putOnTrello(card, {estimativa: data.estimativa, horas_filhos: data.horas_filhos,
                            horas: data.horas, tags: data.tags, showAlert: showAlert});
                }
                else
                    alert("Erro durante atualização do cartão no Trello");
            }
        });
    });
}

function updateFatherCheckist(card_url, father) {
    Trello.get("/cards/" + father.id + "/checklists", function(lists) {
        var filhosList = null;
        $(lists).each(function(i, e) {
            if (e.name == "FILHOS")
                filhosList = e;
        });
        if (!filhosList)
            Trello.post("/checklists/", {name: "FILHOS", idCard: father.id}, function(list) {
                Trello.post("/checklists/" + list.id + "/checkItems", {name: card_url});
            });
        else {
            var exists = false;
            $(filhosList.checkItems).each(function(i, e) {
                if (e.name == card_url)
                    exists = true;
            });
            if (!exists)
                Trello.post("/checklists/" + filhosList.id + "/checkItems", {name: card_url});
        }
    });
}

function removeFromChecklist(card_url, father_id) {
    Trello.get("/cards/" + father_id + "/checklists", function(lists) {
        var filhosList = null;
        $(lists).each(function(i, e) {
            if (e.name == "FILHOS")
                filhosList = e;
        });
        if (filhosList)
            $(filhosList.checkItems).each(function(i, e) {
                if (e.name == card_url)
                    Trello.delete("/checklists/" + filhosList.id + "/checkItems/" + e.id);
            });
    });
}

function putOnTrello(card, params) {
    var regex_tags = /\[.*\]/;
    var regex_time = /[(]\d+[.]?\d*[)]$/;
    var new_name = card.name.replace(regex_tags, '').replace(regex_time, '').trim();
    var new_desc = newDesc(card.desc, params.estimativa, params.pai, params.horas_filhos);
    if (params.pai)
        updateFatherCheckist(card.shortUrl, params.pai);
    if (params.tags.length > 0)
        new_name = "[" + params.tags.join("][") + "] " + new_name;
    if (params.horas)
        new_name = new_name + " (" + params.horas + ")";
    if (card.name != new_name || new_desc != card.desc)
        Trello.put('/cards/' + card.id + '/', {name: new_name, desc: new_desc});
    if (params.showAlert)
        alert("Cartão atualizado com sucesso!");
}

function newDesc(old_desc, estimate, father, time) {
    var new_desc = old_desc;
    var regex_estimate = /\n{Estimativa:.*}/;
    var regex_father = /\n{Cartão PAI:.*}/;
    var regex_time = /\n{Horas totais dos filhos:.*}/;
    new_desc = new_desc.replace(/[-]{35}(.|\s)*/, "");
    if (time == null && father == null && estimate == null)
        return new_desc;
    new_desc = new_desc.trim() + "\n\n-----------------------------------\n{SIMLAB}";
    if (estimate) {
        new_desc = new_desc.replace(regex_estimate, '').trim() +
                "\n{Estimativa: " + estimate + "}";
    }
    if (father) {
        new_desc = new_desc.replace(regex_father, '').trim() +
                "\n{Cartão PAI: " + father.shortUrl + "}";
    }
    if (time) {
        new_desc = new_desc.replace(regex_time, '').trim() +
                "\n{Horas totais dos filhos: " + time + "}";
    }
    return new_desc;
}


function mergeTags(name) {
    var regex_tags = /[\[][^\[\]]*[\]]/g;
    var card_tags = name.match(regex_tags);
    $(card_tags).each(function(i, e) {
        card_tags[i] = e.replace(/[\]\[]/g, '');
    });
    var input_tags = $("#cartao_tags_string").val().split(/[,][ ]*/);
    var concat = $.unique(input_tags.concat(card_tags));
    $("#cartao_tags_string").val(concat.join(", "));
}

function selectPais() {

    var select = document.createElement("select");
    var cartoes_pais = $("#cartoes_pais_ids").val().split(" ");
    var cartoes_pais_trello = $("#cartoes_pais_trello_ids").val().split(" ");
    var cartoes_pais_opcoes = new Array();

    select.setAttribute("name", "cartao_pai");
    select.setAttribute("id", "cartao_pai");
    select.setAttribute("class", "menu_select");

    option = document.createElement("option");
    option.setAttribute("value", "-2");
    option.innerHTML = "Pais - TODOS";
    select.appendChild(option);

    option = document.createElement("option");
    option.setAttribute("value", "0");
    option.innerHTML = "Com Pais";
    select.appendChild(option);

    option = document.createElement("option");
    option.setAttribute("value", "-1");
    option.innerHTML = "Sem Pais";
    select.appendChild(option);

    for (i = 0; i < cartoes_pais.length; i++) {
        Trello.get("/cards/" + cartoes_pais_trello[i], function(card) {
            cartoes_pais_opcoes[i] = document.createElement("option");
            cartoes_pais_opcoes[i].setAttribute("value", cartoes_pais[i]);
            cartoes_pais_opcoes[i].innerHTML = card.name;
            select.appendChild(cartoes_pais_opcoes[i]);
        })
    }

    document.getElementById("cartao_pai_select").appendChild(select);
}
