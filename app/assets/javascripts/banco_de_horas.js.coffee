# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
print = (param) ->
	if param == null
		return ''
	else
		return param

$ ()->
	$('.modal').on 'shown', ->
		$(this).find('input:visible:first').focus().end().find('form').enableClientSideValidations()
	$("form.new_banco_de_hora").on "ajax:success", (event, data, status, xhr) ->
    $('#new-banco-modal').modal('hide')

$ ->
  $.loadModal = ->
    $('.edit-dia a').click (event) ->
      event.preventDefault()
      loading = $ '<div id="loading" style="display: none;"><span><img src="/assets/loading.gif" alt="carregando..."/></span></div>'
      $('.other_images').prepend loading
      loading.fadeIn()
      $.ajax type: 'GET', url: $(@).attr('href'), dataType: 'script', success: (-> loading.fadeOut -> loading.remove())
      false

  $.loadModal()

function validate()
{
  var atividadeOBS = document.getElementById("dia_atividades_attributes_0_observacao").value;
  var horas_trabalhadas = pega_horas_dia();
  var horas_atividade = pega_horas_atividade();

  return(
    validar_horas(horas_trabalhadas, horas_atividade) &&
    validar_atividade_observacao(atividadeOBS)
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

function validar_atividade_observacao(obs)
{
  if(obs == "")
  {
    alert("Atividade não pode ficar sem observação!");
    return false;
  }
  else
    return true;
}

function pega_horas_dia()
{

  var entradaH = document.getElementById("dia_0_entrada").value;
  var entradaM = document.getElementById("dia_0_entrada").nextElementSibling.value;
  var saidaH = document.getElementById("dia_0_saida").value;
  var saidaM = document.getElementById("dia_0_saida").nextElementSibling.value;
  var intervaloH = document.getElementById("dia_0_intervalo").value;
  var intervaloM = document.getElementById("dia_0_intervalo").nextElementSibling.value;

  var entrada = entradaH * 60 + parseInt(entradaM, 10);
  var saida = saidaH * 60 + parseInt(saidaM, 10);
  var intervalo = intervaloH * 60 + parseInt(intervaloM, 10);

  return saida - entrada - intervalo;
}

function pega_horas_atividade()
{
  var atividadeH = document.getElementById("dia_atividades_attributes_0_horas_4i").value;
  var atividadeM = document.getElementById("dia_atividades_attributes_0_horas_5i").value;

  return(atividadeH *60 + parseInt(atividadeM));
}

function recalculaHoras()
{
 var max_horas = pega_horas_dia();
  document.getElementById("dia_atividades_attributes_0_horas_4i").selectedIndex = max_horas/60;
  document.getElementById("dia_atividades_attributes_0_horas_5i").selectedIndex = max_horas%60;

}