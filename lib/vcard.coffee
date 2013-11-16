
module.exports =
	parseVcard : (vcardString) ->
		fields = vcardString.split /\r\n|\r|\n/
		result = {}
		fields.forEach (field) ->
			if field.match(/^FN/)
				result.fn = field.split(':')[1]
			if parts = field.match(/^TEL\W(\w{1,})\W(.*)/i)
				result.tel ?= {}
				result.tel[parts[1]] = parts[2]
		result
