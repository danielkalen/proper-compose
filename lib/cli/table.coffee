Table = require 'cli-table'
get = require 'sugar/object/get'

createTable = (data, columns, colWidths=[])->
	split = columns.map (column)-> column.split(':')
	head = split.map (column)-> column[0]
	body = split.map (column)-> column[1]
	
	table = new Table {head, colWidths}
	for item in data
		table.push body.map (column)->
			result = get(item,column)
			result = result.slice(0,12) if /\bid\b/i.test(column) and result
			return result or ''

	return table.toString()

module.exports = createTable