exports.env_var = /\$(\w+)/g

exports.expression = /\{\{([\w\W]+?)\}\}/g
exports.expression = ///
	(
		[\ \t\r=]* 			# prior whitespace
	)
	\{\{
	([\w\W]+?)
	\}\}
///g

exports.import = ///
	(
		[\ \t\r=]* 			# prior whitespace
	)
	import
	\s
	['"]
	(.+?)
	['"]
///gm