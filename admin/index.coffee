require 'sugar'
$ = require 'jquery'
oboe = require 'oboe'
loki = require 'lokijs'
db = new loki
wsdls = db.addCollection 'wsdls'

`
Array.prototype.associate = function (keys) {
  var result = {};

  this.forEach(function (el, i) {
    result[keys[i]] = el;
  });

  return result;
};
`

$ ->
	$('input[name="wsdl"]').change ->
		formdata = new FormData()
		formdata.append 'wsdl', this.files[0]
		filename = $('input[name="wsdl"]').val().replace(/^.*(\\|\/|\:)/, '').split('.')[0]

		$.post
			url: "http://localhost:7777/resource/1/wsdlCache/#{filename}"
			data: formdata
			processData: false
			contentType: false

	$('.filter.items.list').on 'click', '.add.more', ->
		$(this).parent().clone().appendTo '.filter.items.list'

	$('#filter').click ->
		keys = ($('input[name="key[]"]').map -> $(this).val()).get()
		vals = ($('input[name="value[]"]').map -> $(this).val()).get()
		data = vals.associate keys
		console.log data

		filterName = $('.filterName').val()
		$.post "http://localhost:7777/resource/1/dataView/#{filterName}", data, (response) ->
			console.log response

	addOption = (target, value, options) ->
		$ '<option>'
		.attr options
		.val value
		.html value
		.appendTo $ target

	wsdls.on 'insert', ({wsdl}) ->
		addOption '.wsdls.available', wsdl, class: 'wsdls option' unless $('.wsdls.available').find("option[value='#{wsdl}']").length

	$('.wsdls.available').change ->
		$('.actions.available').empty()
		addOption '.actions.available', action, class: 'actions option' for {action} in wsdls.find wsdl: $(this).val()
		$('.actions.available').slideDown()

	mapObj2Form = (target, data) ->
		for item in data
			div = $ '<div>'

			$ '<label>'
			.prop 'for', "#{item}-query"
			.html "#{item}: "
			.appendTo div

			$ '<input>'
			.prop 'name', item
			.prop 'id', "#{item}-query"
			.appendTo div

			div.appendTo $ target

	$('.actions.available').change ->
		wsdls.find
			action: $(this).val()
			wsdl: $('.wsdls.available').find(':selected').val()
		.map ({io: {input}}) ->
			Object.keys input
		.each (data) ->
			$('.wsdl.input.items').empty()
			mapObj2Form '.wsdl.input.items', data

	$('#query').click ->
		wsdl = $('.wsdls.available').find(':selected').val()
		action = $('.actions.available').find(':selected').val()
		data = Object.fromQueryString $('#addQuery').serialize()
		$.post "http://localhost:7777/resource/1/wsdlCache/#{wsdl}/#{action}", data

	oboe 'http://localhost:7777/resource/1/wsdlCache'
	.done (data) -> wsdls.insert data