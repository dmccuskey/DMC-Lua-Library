# DMC-Lua-Library

try:
	if not gSTARTED: print( gSTARTED )
except:
	MODULE = "DMC-Lua-Library"
	include: "../DMC-Lua-Library/snakemake/Snakefile"

module_config = {
	"name": "DMC-Lua-Library",
	"module": {
		"dir": "dmc_lua",
		"files": [
			"json.lua",
			"lua_bytearray.lua",
			"lua_bytearray/exceptions.lua",
			"lua_bytearray/pack_bytearray.lua",
			"lua_e4x.lua",
			"lua_error.lua",
			"lua_events_mix.lua",
			"lua_files.lua",
			"lua_megaphone.lua",
			"lua_objects.lua",
			"lua_patch.lua",
			"lua_promise.lua",
			"lua_states_mix.lua",
			"lua_utils.lua"
		],
		"requires": [
			"lua-bit-shim",
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
		"dir": "spec",
		"files": [],
		"requires": []
	}
}

register( "DMC-Lua-Library", module_config )


