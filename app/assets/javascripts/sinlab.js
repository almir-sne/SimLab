function toggleAusencia() {
    $("#ausencias").show();
    $("#meses-button").show();
    $("#meses").hide();
    $("#ausencias-button").hide();
}

function toggleMeses() {
    $("#meses").show();
    $("#ausencias-button").show();
    $("#ausencias").hide();
    $("#meses-button").hide();
}

function getFirstValid(seletor) {
    seletor.value = "";
    $(seletor.children).each(function(i, e) {
        if ($(e).css('display') != 'none') {
            seletor.value = e.value;
            return;
        }
    });
}

function toggleObservacao(obj) {
    $(obj).closest('form').find("#observacao-div").toggle();
}

function ajustaAltura() {
    var height1 = $(window).height() - $("#atividades-title").height() -
            $("#dropover").height() - $("#upper-bar").height() - 200;
    var height2 = $(window).height() - $("#upper-bar").height() - $("#boards").height()
            - $("#collapse-button").height() - 140;
    var height3 = $(window).height() - $("#upper-bar").height() - 120;
    $("#atividade-panel").height(height1);
    $("#card-list").height(height2);
    $("#horarios-panel").height(height3);
}

function toggleCollapse(obj) {
    if (obj.children[0].className == "icon-chevron-sign-right")
        obj.children[0].className = "icon-chevron-sign-down";
    else
        obj.children[0].className = "icon-chevron-sign-right"
}

function hideNavegacao() {
    var nav = $("#navegacao");
    $("#lista").attr({style: "width: 100%;  float: right;"});
    nav.hide();
    $("#show-navegacao").attr({style: "display: inline;"});
    $("#hide-navegacao").attr({style: "display: none;"});
}

function showNavegacao() {
    var pnav = $("#prenavegacao");
    pnav.hide();
    var nav = $("#navegacao");
    $("#lista").attr({style: "width: 85%;  float: right;"});
    nav.show();
    $("#show-navegacao").attr({style: "display: none;"});
    $("#hide-navegacao").attr({style: "display: inline;"});
}

// http://stackoverflow.com/questions/11582512/how-to-get-url-parameters-with-javascript
function getURLParameter(name) {
    return decodeURIComponent((new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').
            exec(location.search) || [, ""])[1].replace(/\+/g, '%20')) || null;
}

function mudaUsuario(obj) {
    var url = location.href;
    if (!url.match(/[?]/))
        url = url + "?";
    location.href = url.replace(/usuario_id=[0-9]+/, "") + "usuario_id=" + $(obj).val();
}

function ver_periodo_novo(obj)
{
    var orgurl = $(obj).attr("tpg");
    var inicio = $('#datepicker1').val();
    var fim = $('#datepicker2').val();

    var finalurl = orgurl + "&inicio=" + inicio + "&fim=" + fim;

    $(obj).attr("href", finalurl);
}

function ver_periodo_novo_proj(obj)
{
    var orgurl = $(obj).attr("tpg");
    var inicio = $('#datepicker1').val();
    var fim = $('#datepicker2').val();

    var finalurl = orgurl + "?inicio=" + inicio + "&fim=" + fim;

    $(obj).attr("href", finalurl);
}

function formChanged(form) {
    $(form).data("changed", true);
    $(form).find(".form-status .form-saved").hide();
    $(form).find(".form-status .form-changed").show();
}

function formSaved(form) {
    $(form).data("changed", false);
    $(form).find(".form-status .form-saved").show();
    $(form).find(".form-status .form-changed").hide();
    $(form).find(".form-status .form-spinner").hide();
}

function showSpinner(form) {
    $(form).find(".form-status .form-spinner").show();
}

function hideSpinner(form) {
    $(form).find(".form-status .form-spinner").hide();
}

function checkForm() {
    var changed = false;
    $("form").each(function(i, e) {
        if ($(e).data("changed"))
            changed = true;
    });
    if (changed)
        return "Há mudanças não salvas";
    else
        return null;
}

function updateUsuarios(selector) {
    $.ajax({
        type: "POST",
        url: "/reunioes/usuarios",
        data: {projeto_id: selector.value, reuniao_id: $("#reuniao_id").val()}
    });
}

function setChecked(checkbox) {
    $("table td input[type='checkbox']").prop('checked', checkbox.checked)
}