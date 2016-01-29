require 'sugar'
$ = require 'jquery'

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
	$('input[type="file"]').change ->
		formdata = new FormData()
		formdata.append 'wsdl', this.files[0]
		filename = $('input[type="file"]').val().replace(/^.*(\\|\/|\:)/, '').split('.')[0]
		console.log "filename: #{filename}"

		$.ajax
			url: "http://localhost:7777/resource/1/wsdlCache/#{filename}"
			type: 'post'
			data: formdata
			processData: false
			contentType: false

	$('.add.more').on 'click', ->
		console.log 'Button got clicked!'
		$(this).parent().clone().appendTo '.filter.items.list'

	$('#filter').click ->
		keys = ($('input[name="key[]"]').map -> $(this).val()).get()
		vals = ($('input[name="value[]"]').map -> $(this).val()).get()
		data = vals.associate keys

		filterName = $('.filterName').val()
		$.post "http://localhost:7777/resource/1/dataView/#{filterName}", data