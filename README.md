# DMC-Lua-Library

The DMC Lua modules in one folder: classes and objects, events, errors, promises, state machines, files, XML and more, for Lua 5.1.

Each module is written and documented in its own repository; this one only collects copies of them, so a project can take all of them in one clone, at versions that work together. They were written for the DMC Solar2D (formerly Corona SDK) libraries, which all ship this folder, but they are plain Lua 5.1 and also run on a server.

## Modules

Everything is in `dmc_lua/`. Each module's repository has its Quick Start, reference and known issues.

| module | repository | what it is |
|---|---|---|
| `lua_class` | [lua-class](https://github.com/dmccuskey/lua-class) | Classes: inheritance from one or several classes, getters and setters, calls to a parent's method |
| `lua_objects` | [lua-objects](https://github.com/dmccuskey/lua-objects) | A base class for objects: events, and a set order for setting an object up and tearing it down |
| `lua_events_mix` | [lua-events-mixin](https://github.com/dmccuskey/lua-events-mixin) | `addEventListener()`, `removeEventListener()` and `dispatchEvent()` for any object |
| `lua_states_mix` | [lua-states-mixin](https://github.com/dmccuskey/lua-states-mixin) | Turns any object into a state machine |
| `lua_error` | [lua-error](https://github.com/dmccuskey/lua-error) | `try`, `catch` and `finally`, and error classes you can raise and recognize |
| `lua_promise` | [lua-promise](https://github.com/dmccuskey/lua-promise) | Deferreds and promises, for results that arrive later |
| `lua_megaphone` | [lua-megaphone](https://github.com/dmccuskey/lua-megaphone) | One shared object that any part of an app can send messages to and listen on |
| `lua_bytearray` | [lua-bytearray](https://github.com/dmccuskey/lua-bytearray) | A byte buffer for binary data; reading and writing numbers needs the `pack` C module (lpack) |
| `lua_e4x` | [lua-e4x](https://github.com/dmccuskey/lua-e4x) | Read XML with dot syntax: `xml.book.title` |
| `lua_files` | [lua-files](https://github.com/dmccuskey/lua-files) | Read and write text, lines, JSON and config files in one call each; uses `lfs` and a JSON module when they are installed |
| `lua_patch` | [lua-patch](https://github.com/dmccuskey/lua-patch) | Python-style additions: `%` string formatting, `table.pop()`, `pnotice()`/`pwarn()` |
| `lua_utils` | [lua-utils](https://github.com/dmccuskey/lua-utils) | Small helpers for tables, strings, URLs, callbacks, time and image scaling |
| `json` | [lua-json-shim](https://github.com/dmccuskey/lua-json-shim) | Loads whichever JSON module is installed (`dkjson`, `cjson` or `json`) as `json` |
| `bit` | [lua-bit-shim](https://github.com/dmccuskey/lua-bit-shim) | Loads Solar2D's `plugin.bit`, or else the pure-Lua copy in `lib/bit/numberlua.lua`, as `bit` |

The modules require each other by their plain names (`require 'lua_class'`), so `dmc_lua/` has to be on the Lua search path, as in the Quick Start. Each module's version is in its header.

## Quick Start

The following steps will get you up and running in about 5 minutes with Lua 5.1 on macOS or Linux. You will use three of the modules together: a promise delivers a result, a caught error is reported, and both go out on the megaphone.

Prerequisites: Lua 5.1 (`lua -v` shows `Lua 5.1.x`) and git.

### 1. Get the Code

In an empty folder:

```sh
git clone https://github.com/dmccuskey/DMC-Lua-Library.git
```

### 2. Use Some Modules

Create `main.lua` in the same folder:

```lua
package.path = './DMC-Lua-Library/dmc_lua/?.lua;' .. package.path
local Megaphone = require 'lua_megaphone'
local Promise = require 'lua_promise'
require 'lua_error'  -- adds the globals try, catch and finally

-- a download that answers later, as a promise
local function fetchScore( player )
	local d = Promise.Deferred:new()
	if player == 'ada' then
		d:callback( 42 )
	else
		d:errback( "unknown player " .. player )
	end
	return d
end

-- any module can listen on the one megaphone
Megaphone:listen( function( event )
	print( event.type, event.data )
end )

local function onScore( score ) Megaphone:say( 'score', score ) end
local function onError( reason ) Megaphone:say( 'failed', reason ) end

fetchScore( 'ada' ):addCallbacks( onScore, onError )
fetchScore( 'bob' ):addCallbacks( onScore, onError )

try{
	function()
		error( "out of lives" )
	end,
	catch{
		function( e ) Megaphone:say( 'caught', e ) end
	}
}
```

Run it:

```sh
lua main.lua
```

```text
score	42
failed	unknown player bob
caught	main.lua:30: out of lives
```

If it shows `module 'lua_megaphone' not found`, run it from the folder that holds `DMC-Lua-Library/`.

**Going further:** each module's own Quick Start, in its repository ([Modules](#modules)).

To update, pull the repository again (`git -C DMC-Lua-Library pull`).

## In Solar2D

Every DMC Solar2D library (`dmc-*`) ships this folder as `dmc_corona/lib/dmc_lua/`; [dmc-corona-boot](https://github.com/dmccuskey/dmc-corona-boot) adds it to the search path, and the libraries require the modules as `lib.dmc_lua.<module>`.

Most modules also have a Solar2D package, which loads the module and documents its use in Solar2D: [dmc-objects](https://github.com/dmccuskey/dmc-objects) (which adds classes for display objects), [dmc-events-mixin](https://github.com/dmccuskey/dmc-events-mixin), [dmc-states-mixin](https://github.com/dmccuskey/dmc-states-mixin), [dmc-error](https://github.com/dmccuskey/dmc-error), [dmc-promise](https://github.com/dmccuskey/dmc-promise), [dmc-megaphone](https://github.com/dmccuskey/dmc-megaphone), [dmc-bytearray](https://github.com/dmccuskey/dmc-bytearray), [dmc-e4x](https://github.com/dmccuskey/dmc-e4x), [dmc-files](https://github.com/dmccuskey/dmc-files), [dmc-patch](https://github.com/dmccuskey/dmc-patch) and [dmc-utils](https://github.com/dmccuskey/dmc-utils) (which adds Solar2D helpers).

Load each module under one name only. Loaded as both `lib.dmc_lua.lua_class` and `lua_class`, a module exists twice: there are two megaphones, and objects made from one copy of a class fail `isa()` checks against the other.

## Known Issues

- The `Snakefile` names a `lua_path` module, commented out: there is no lua-path repository. Path handling for Solar2D is in [dmc-path](https://github.com/dmccuskey/dmc-path).

## Development

Nothing in `dmc_lua/` is edited here: fix a module in its own repository, then rebuild. The tests are there too, in each module's repository. The build uses [Snakemake](https://snakemake.readthedocs.io/) (last run with 7.32). The `Snakefile` lists the files and the repositories they come from, `snakemake/Snakefile` holds the rules, and each module repository registers its files in its own `Snakefile`.

A build copies from checkouts of the module repositories next to this one (`../lua-class/` and so on), on whatever branch each one has checked out. From this repository's root folder:

```sh
snakemake --cores 1 --forceall build_module
```

Snakemake decides what to copy by file times; `--forceall` copies every file. Until the next build, a copy here can be older than its repository.

## License

The modules are released under the [MIT License](LICENSE).
