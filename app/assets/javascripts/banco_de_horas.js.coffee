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