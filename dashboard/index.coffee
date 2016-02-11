# Create the target url
protocol = window.location.protocol
host = window.location.hostname
url = "#{protocol}//#{host}:7777"
durl = "#{protocol}//#{host}:8000"

require 'sugar'
$ = require 'jquery'
oboe = require 'oboe'
dotize = require 'dotize'
socket = (require 'socket.io-client') url

addOption = (target, value, options=false) ->
	option = $ '<option>'
	.val value
	.html value
	option.attr options if not options == false
	option.addClass 'placeholder' if value == 'Please select'
	option.appendTo $ target

mapObj2Form = (target, data) ->
	$(target).empty()
	for item in data
		div = $ '<div>'

		$ '<label>'
		.prop 'for', "#{item}-query"
		.html "#{item}"
		.appendTo div

		$ '<input>'
		.prop 'name', item
		.prop 'id', "#{item}-query"
		.appendTo div

		div.appendTo $ target

layouts = {}
widgets = {}

$ ->
	$.get "#{durl}/api/layouts", (data) ->
		layouts = data
		addOption '#lname', item for item in Object.keys data

	$("#lname").on 'change', ->
		lname = $(this).val()
		$('#version').empty()
		addOption '#version', 'Please select', {disabled: true, selected: true}
		addOption '#version', item for item in layouts[lname]
		$('.versionDiv').slideDown()

	$.get "#{durl}/api/widgets", (data) ->
		widgets = data
		addOption '.format', item for item in Object.keys data

	$('.format').on 'change', ->
		format = $(this).val()
		$(this).parent().parent().find('.wname').empty()
		addOption $(this).parent().parent().find('.wname'), 'Please select', {disabled: true, selected: true}
		addOption $(this).parent().parent().find('.wname'), item for item in widgets[format]
		$('.wnameDiv').slideDown()

	$('.wname').on 'change', ->
		$('.slotDiv').slideDown()
		lname = $('#lname').find(':selected').val()
		version = $('#version').find(':selected').val()
		$.get "#{durl}/layouts/#{lname}/#{version}/html", (data) ->
			slots = $('<div/>', {html: data}).find '[id^=widget_slot]'
			slots.each (index, slot) -> addOption '.slot', $(slot).prop('id')

		$('.dataDiv').slideDown()
		oboe "#{url}/resource/1/dataView"
		.done (data) ->
			addOption '.data', data.name

		$('.optionsDiv').slideDown()

	$('.add.option').on 'click', ->
		wname = $(this).closest('.widgets.world.object').find('.wname').find(':selected').val()
		format = $(this).closest('.widgets.world.object').find('.format').find(':selected').val()
		$.get "#{durl}/widgets/#{format}/#{wname}/html", (data) =>
			options = $('<div/>', {html: data}).find '.widget-option'
			props = []
			options.each (index, option) ->
				pClass = '.' + $(option).prop 'class'
				pClass = pClass.replace /\s/gi, '.'
				props.push pClass
			mapObj2Form $(this).closest('.widgets.world.object').find('.widget.options.list'), props

	###
	$('body').on 'click', '.add.more', ->
		cloner = $(this).closest('.widget.options.list')
		clonedOpts.clone(true, true).insertAfter cloner
	clonedOpts = $('.widget.options.list').clone(true, true)
	###

	$('body').on 'click', '.add.widget', ->
		cloner = $(this).closest('.widgets.world.object.list')
		clonedWidget.find('.format').html $('.format').first().html()
		clonedWidget.clone(true, true).insertAfter cloner
	clonedWidget = $('.widgets.world.object.list').clone(true, true)

	$('#button').on 'click', ->
		world = {}
		world.title = $('#title').val()

		world.layout ?= {}
		world.layout.name = $('#lname').val()
		world.layout.version = $('#version').val()

		world.widgets ?= []
		$('.widgets.world.object.list').children().each (index, widget) ->
			widgetObj = {}
			widgetObj.name = $(widget).find('.wname').find(':selected').val()
			widgetObj.format = $(widget).find('.format').find(':selected').val()
			widgetObj.target = $(widget).find('.slot').find(':selected').val()
			widgetObj.data = $(widget).find('.data').find(':selected').val() if $(widget).find('.data').find(':selected').val() == 'false'
			
			$(widget).find('.widget.options.list').children().each (index2, option) ->
				widgetObj.options ?= []
				optionObj =
					key: $(option).find('label').html()
					value: $(option).find('input').val()
				if !!optionObj.key and !!optionObj.value
					widgetObj.options.push optionObj
				if index2+1 == $(widget).find('.widget.options.list').children().length
					world.widgets.push widgetObj

			if index+1 == $('.widgets.world.object.list').children().length
				$.post "#{durl}/api/dashboards/" + $('#dname').val(), world, (result) ->
					console.log '========'
					console.log world