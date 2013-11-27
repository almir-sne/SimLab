function recalculaHoras() {
    // updateAllSliders();
    horas = pega_horas_dia();
    $("#horas_do_dia").text(getTime(horas.totalHorasDia));
    $("#dia_intervalo").text(getTime(horas.totalIntervalo));
}

function slideTime(event, ui) {
    var parent = $(event.target).parent();
    parent.find("#time").text(
            getTime(ui.value)
            );
    parent.find(".hora_field")[0].value = ui.value;
    if (parent.attr("class") == "slider slider-horas")
        updateSubSliders(parent, ui.value);
    updateHorasAtividades(sumSliders(), pega_horas_dia().totalHorasDia, $("#horas_atividades"));
}

function updateSubSliders(parent, maxtime) {
    parent.parents("#atividade-form").find(".slider-par").each(function(i, e) {
        if ($(e).find(".hora_field")[0].value > maxtime) {
            $(e).find(".hora_field")[0].value = maxtime;
            initTime($(e).find("#time"), maxtime);
            $(e).find("#slider").slider("value", maxtime);
        }
        $(e).find("#slider").slider("option", "max", maxtime);
    });
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
    $(".fields:visible > .slider > .hora_field").each(function(i, e) {
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
    var time = sliderParent.find(".hora_field")[0].value;
    var max;
    if (sliderParent.parent().attr("class") == "par")
        max = $(sliderParent).parents("#atividade-form").find(".atividade_field")[0].value;
    else
        max = 720;
    initSlider(sliderParent.find('#slider'), time, max);
    initTime(sliderParent.find('#time'), time);
}

function initTime(div, time) {
    div.text(getTime(time));
}

function initSlider(div, time, max_time) {
    div.slider({
        min: 0,
        max: max_time,
        value: parseFloat(time),
        step: 10,
        slide: slideTime,
        orientation: "horizontal",
        range: "min"
    });
}

function updateAllSliders() {
    var max = pega_horas_dia();
    maxtime = max.totalHorasDia;
    $(".slider").each(function(i, e) {
        if ($(e).find(".hora_field")[0].value > maxtime) {
            $(e).find(".hora_field")[0].value = maxtime;
            initTime($(e).find("#time"), maxtime);
            $(e).find("#slider").slider("value", maxtime);
        }
        $(e).find("#slider").slider("option", "max", maxtime);
    });
}

function pad(str, max) {
    return str.length < max ? pad("0" + str, max) : str;
}

//essa função não faz sentido
//rezende
function projetosVazios() {
    var vazios = false;
    $(".fields:visible > .projeto-seletor").each(function(i, e) {
        if (e.value == null || e.value == "")
            vazios = true;
    });
    return vazios;
}

function validateSliders() {
    if (projetosVazios()) {
        alert("Nenhum projeto selecionado");
        return false;
    }
    return true;
}

