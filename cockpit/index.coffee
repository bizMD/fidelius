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
pSocket = (require 'socket.io-client') durl

addOption = (target, value, options) ->
	$ '<option>'
	.val value
	.html value
	.appendTo $ target

$ ->
	oboe "#{durl}/api/dashboards"
	.done ({dashboard}) ->
		console.log dashboard
		addOption '#pages', dashboard, 'pages option'

	$('#button').on 'click', ->
		pSocket.emit 'change active dashboard', $('#pages').find(':selected').val()