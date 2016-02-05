# When creating a register, it should not contain certain values. These values are all stored in this variable.
blacklist = ['targetnamespace', 'targetnsalias']

# Create the target url
protocol = window.location.protocol
host = window.location.hostname
url = "#{protocol}//#{host}:7777"

require 'sugar'
$ = require 'jquery'
oboe = require 'oboe'
loki = require 'lokijs'
socket = (require 'socket.io-client') url

db = new loki
wsdls = db.addCollection 'wsdls'
filters = db.addCollection 'filters'

`
Array.prototype.associate = function (keys) {
  var result = {};

  this.forEach(function (el, i) {
    result[keys[i]] = el;
  });

  return result;
};
`

addOption = (target, value, options) ->
	$ '<option>'
	.attr options
	.val value
	.html value
	.appendTo $ target

mapObj2Form = (target, data) ->
	for item in data
		if item.toLowerCase() not in blacklist
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

$ ->
	$('input[name="wsdl"]').on 'change', ->
		formdata = new FormData()
		formdata.append 'wsdl', this.files[0]
		filename = $('input[name="wsdl"]').val().replace(/^.*(\\|\/|\:)/, '').split('.')[0]

		$.post
			url: "#{url}/resource/1/wsdlCache/#{filename}"
			data: formdata
			processData: false
			contentType: false

	$('.filter.items.list').on 'click', '.add.more', ->
		$(this).parent().clone().appendTo '.filter.items.list'

	$('#filter').on 'click', ->
		keys = ($('input[name="key[]"]').map -> $(this).val()).get()
		vals = ($('input[name="value[]"]').map -> $(this).val()).get()
		data = vals.associate keys
		console.log data

		filterName = $('.filterName').val()
		$.post "#{url}/resource/1/dataView/#{filterName}", data, (response) ->
			socket.emit 'subscribe to filter', filterName
			console.log response

	socket.on 'new data delivery', (data) ->
		console.log data

	socket.on 'new data delivery error', (data) ->
		console.log data

	## --------- ##

	wsdls.on 'insert', ({wsdl}) ->
		addOption '.wsdls.available', wsdl, class: 'wsdls option' unless $('.wsdls.available').find("option[value='#{wsdl}']").length

	$('.wsdls.available').on 'change', ->
		$('.actions.available').empty()
		addOption '.actions.available', 'Choose an Action', {class: 'placeholder', disabled: true, selected: true}
		addOption '.actions.available', action, class: 'actions option' for {action} in wsdls.find wsdl: $(this).val()
		$('.actions.available').slideDown()

	## --------- ##

	$('.actions.available').on 'change', ->
		selected = wsdls.find
			action: $(this).val()
			wsdl: $('.wsdls.available').find(':selected').val()
		
		console.log selected.first().io.output
		#$('.wsdl.output.result').html JSON.stringify selected.first().io.output
		#$('.wsdl.output.footer').slideDown()

		selected
		.map ({io: {input}}) ->
			Object.keys input
		.each (data) ->
			$('.wsdl.input.items').empty()
			mapObj2Form '.wsdl.input.items', data

	$('#query').on 'click', ->
		wsdl = $('.wsdls.available').find(':selected').val()
		action = $('.actions.available').find(':selected').val()
		data = Object.fromQueryString $('#addQuery').serialize()
		$.post "#{url}/resource/1/wsdlCache/#{wsdl}/#{action}", data, (response) ->
			console.log response

	oboe "#{url}/resource/1/wsdlCache"
	.done (data) -> wsdls.insert data