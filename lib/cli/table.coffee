Table = require 'cli-table'
get = require 'sugar/object/get'
max = require 'sugar/array/max'

createTable = (data, columns, colWidths=[], aliases={})->
	split = columns.map (column)-> column.split(':')
	head = split.map (column)-> column[0]
	body = split.map (column)-> column[1]
	optimizeColumns(data, columns, colWidths, aliases)
	
	table = new Table {head, colWidths}
	for item in data
		table.push body.map (column)->
			result = get(item,column)
			result = result.slice(0,12) if /\bid\b/i.test(column) and result
			return result or ''

	return table.toString()

removeColumn = (columns, widths, indices...)->
	removeAt = require 'sugar/array/removeAt'
	for index in indices.reverse()
		removeAt columns, index
		removeAt widths, index
	return

optimizeColumns = (data, columns, colWidths, aliases)->
	return if not data.length
	for column,index in columns
		[label,prop] = column.split(':')
		prop = aliases[prop] or prop
		values = getValues(data, prop)
		currentWidth = colWidths[index]
		maxWidth = max(values, (p)-> p.length).length
		maxWidth = 12 if /\bid\b/i.test(prop) and maxWidth

		colWidths[index] = Math.max(maxWidth+2, label.length+2)
	return


getValues = (data, prop)->
	output = []
	
	for entry in data
		value = get(entry, prop)
		value ?= ''
		output.push value+''

	return output


module.exports = createTable
module.exports.removeColumn = removeColumn