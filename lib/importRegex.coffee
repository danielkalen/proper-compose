module.exports = 
	///^
		(
			[\ \t\r=]* 			# prior whitespace
		)
		\b
		import
		\b
		['"]
		(.+?)
		['"]
	$///gm