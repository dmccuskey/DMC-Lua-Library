# DMC-Lua-Library

try:
	if not gSTARTED: print( gSTARTED )
except:
	MODULE = "DMC-Lua-Library"
	include: "../DMC-Lua-Library/snakemake/Snakefile"

module_config = {
	"name": "DMC-Lua-Library",
	"module": {
		"files": [
		],
		"requires": [
			"lua-bytearray",
			"lua-e4x",
			"lua-error",
			"lua-events-mixin",
			"lua-files",
			"lua-json-shim",
			"lua-megaphone",
			"lua-objects",
			"lua-patch",
			"lua-promise",
			"lua-states-mixin",
			"lua-utils"
		]
	},
	"tests": {
		"files": [
		],
		"requires": [
		]
	}
}

register( "DMC-Lua-Library", module_config )


