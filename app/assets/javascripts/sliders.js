function recalculaHoras() {
    var max_horas = pega_horas_dia();
    updateAllSliders(max_horas);
    $("#horas_do_dia").text(getTime(max_horas));
}

function slideTime(event, ui) {
    $(event.target).parent().find("#time").text(
            getTime(ui.value)
            );
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
    $(".slider > .hora_field").each(function(i, e) {
        val += parseInt(e.value);
    });
    return val;
}

function sumCardSliders(parent) {
    var val = 0;
    $(parent).find(".hora_field").each(function(i, e) {
        val += parseInt(e.value);
    });
    return val;
}

function getTime(val) {
    var hours = parseInt(val / 60);
    var minutes = pad(val % 60 + "", 2);
    return hours + ":" + minutes + " hora(s)";
}

function initializeSliders() {
    $(".slider").each(function(i, e) {
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
        step: 10,
        slide: slideTime,
        orientation: "horizontal",
        range: "min"
    });
}

function updateAllSliders(maxtime) {
    $(".slider, .card-slider").each(function(i, e) {
        if ($(e).find(".hora_field")[0].value > maxtime) {
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

function pad(str, max) {
    return str.length < max ? pad("0" + str, max) : str;
}

function horasCartoesInvalidas() {
    var invalidos = false;
    $(".fields").each(function(i, e) {
        if (sumCardSliders($(e).find(".trello-dropover")) > parseInt($(e).find(".hora_field")[0].value))
            invalidos = true;
    });
    return invalidos;
}

function projetosVazios() {
    var vazios = false;
    $(".projeto-seletor").each(function(i, e) {
        if (e.value == null || e.value == "")
            vazios = true;
    });
    return vazios;
}

function diaVazio() {
    var value = $("#dia_numero").val();
    if (value == "" || value == null) return true;
    else return false;
}

function validateSliders() {
    if (projetosVazios()) {
        alert("Nenhum projeto selecionado");
        return false;
    }
    else if (pega_horas_dia() < 60) {
        alert("É necessario registrar pelo menos 1 hora");
        return false;
    }
    else if (pega_horas_dia() != sumSliders()) {
        alert("Horas em atividades diferem das horas declaradas");
        return false;
    }
    else if (horasCartoesInvalidas()) {
        alert("Horas em atividades diferem dos cartões");
        return false;
    }
    else if (diaVazio()) {
        alert("Nenhum dia selecionado");
        return false;
    }
    return true;
}
