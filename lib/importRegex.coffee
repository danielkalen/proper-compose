module.exports = ///^
	(
		[\ \t\r=]* 			# prior whitespace
	)
	import
	\s
	['"]
	(.+?)
	['"]
$///gm