--====================================================================--
--== DMC Lua Byte Array Spec
--====================================================================--

--[[
Tests for lua_bytearray.lua
--]]



--====================================================================--
--== Path Setup


package.path = './dmc_lua/?.lua;' .. package.path



--====================================================================--
--== Imports


local ByteArray = require 'lua_bytearray'
local File = require 'lua_files'



--====================================================================--
--== Support Functions


local function createByteArray()
	local ba = ByteArray:new()
	ba:setEndian( ByteArray.ENDIAN_BIG )
	return ba
end



--====================================================================--
--== Support Functions


describe( "Module Test: lua_bytearray.lua", function()


	describe( "test custom binary file", function()

		local data
		local ba1, ba2

		setup( function()
			local data_file = './spec/bin/s-goog.bin'
			data = File.readFile( data_file, { lines=false })

			ba1 = createByteArray()
			ba1:writeBuf( data )
			ba1:setPos( 1 )

			ba2 = createByteArray()

		end)

		teardown( function()
			ba1, ba2 = nil, nil
		end)

		--== these tests must be in order

		it( "1. reads heartbeat information", function()
			assert.is.equal( ba1:readStringBytes(1), 'H' )
			assert.is.equal( ba1:readStringBytes(1), 'T' )
			assert.is.equal( ba1:readLong(), 1401726013968 )
		end)

		it( "2. reads snapshot information", function()

			local len, data

			assert.is.equal( ba1:readStringBytes(1), 'N' )

			len = ba1:readUShort()
			assert.is.equal( len, 3 )
			assert.is.equal( ba1:readStringBytes(len), '100' )
			ba1:setPos( ba1:getPos()-5 )

			assert.is.equal( ba1:readStringUShort(), '100' )

			len = ba1:readInt()
			assert.is.equal( len, 15 )
			data = ba1:readStringBytes(len)

			assert.is.equal( ba1:readByte(), 0xFF )
			assert.is.equal( ba1:readByte(), 0x0a )

		end)

		it( "3. tests setPos()", function()

			local char, pos

			ba1:setPos(1)
			pos = ba1:getPos()
			assert.is.equal( pos, 1 )
			char = ba1:readStringBytes(1)

			ba1:setPos(1)
			pos = ba1:getPos()
			assert.is.equal( pos, 1 )

			assert.is.equal( ba1:readStringBytes(1), char )

		end)

		it( "4. copy part of array", function()

			-- test ba1
			ba1:setPos(1)

			ba1:readBytes( ba2, 1, 10 )
			assert.is.equal( ba2:getAvailable(), 0 )

			assert.is.equal( ba1:getLen(), 364 )
			assert.is.equal( ba1:getAvailable(), 354 )

			ba1:setPos(1)
			assert.is.equal( ba1:getAvailable(), 364 )


			-- test ba2
			assert.is.equal( ba2:getLen(), 10 )
			assert.is.equal( ba2:getAvailable(), 0 )

			ba2:setPos(1)
			assert.is.equal( ba2:getLen(), 10 )
			assert.is.equal( ba2:getAvailable(), 10 )

			assert.is.equal( ba2:readStringBytes(1), 'H' )
			assert.is.equal( ba2:readStringBytes(1), 'T' )
			assert.is.equal( ba2:readLong(), 1401726013968 )

			assert.is.equal( ba2:getLen(), 10 )
			assert.is.equal( ba2:getAvailable(), 0 )

			ba2:setPos(1)
			assert.is.equal( ba2:getAvailable(), 10 )

		end)

	end)



	describe( "read bytes from another bytearray, add more", function()

		local DATA1, DATA2 = "hello-", "world"
		local ba1, ba2

		setup( function()
			ba1 = createByteArray()
			ba2 = createByteArray()
		end)

		teardown( function()
			ba1, ba2 = nil, nil
		end)

		--== these tests must be in order

		it( "1. can insert data, but none avail until reset", function()
			ba1:writeBuf( DATA1 )
			assert.is.equal( ba1:getAvailable(), 0 )

			ba1:setPos( 1 )
			assert.is.equal( ba1:getAvailable(), 6 )
		end)

		it( "2. no data avail, even after reset", function()
			assert.is.equal( ba2:getAvailable(), 0 )

			ba2:setPos( 1 )
			assert.is.equal( ba2:getAvailable(), 0 )
		end)

		it( "3. copy data from byte array", function()
			ba1:readBytes( ba2, 1, ba1:getAvailable() )
			assert.is.equal( ba2:getAvailable(), 0 )

			assert.is.equal( ba2:getAvailable(), 0 )
		end)

		it( "4. write additional data to array", function()
			ba2:writeBuf( DATA2 )
			assert.is.equal( ba2:getAvailable(), 0 )

		end)

		it( "5. reset data position, check data", function()
			ba2:setPos(1)
			assert.is.equal( ba2:getAvailable(), 11 )

			assert.is.equal( ba2:readStringBytes(1), 'h' )
			assert.is.equal( ba2:readStringBytes(1), 'e' )
			assert.is.equal( ba2:readStringBytes(1), 'l' )
			assert.is.equal( ba2:readStringBytes(1), 'l' )
			assert.is.equal( ba2:readStringBytes(1), 'o' )
			assert.is.equal( ba2:readStringBytes(1), '-' )
			assert.is.equal( ba2:readStringBytes(1), 'w' )
			assert.is.equal( ba2:readStringBytes(1), 'o' )
			assert.is.equal( ba2:readStringBytes(1), 'r' )
			assert.is.equal( ba2:readStringBytes(1), 'l' )
			assert.is.equal( ba2:readStringBytes(1), 'd' )

			-- no more data to read
			-- TODO: check for proper error type
			assert.is.error( function() ba2:readStringBytes(1) end )
		end)

	end)


end)







