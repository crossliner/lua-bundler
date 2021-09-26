local bit = bit or require("bit");
local unpack = unpack or table.unpack;

local encoders = {}; do 
  function encoders:decode(arr) 
    return string.char(unpack(arr.tbl))
  end;
end;

local array = {}; do 
  array.__index = array;

  function array.new(tbl) 
    return setmetatable({ tbl = tbl or {} }, array);
  end;

  function array:get(index) 
    return self.tbl[index + 1];
  end;

  function array:set(index, value) 
    self.tbl[index + 1] = value;
  end;

  function array:forEach(callback) 
    for i = 1, #self.tbl do 
      callback(i - 1, self.tbl[i])
    end;
  end;

  function array:push(val) 
    local index = (#self.tbl + 1) - 1

    self:set(index, val);
    return index;
  end;

  function array:slice(from, to) 
    local passed = 0;
    local arr = array.new();

    while (passed ~= to - from) do 
      arr:push(self:get(from + passed));
      passed = passed + 1;
    end;

    return arr;
  end;
end;

local reader = {}; do 
  reader.__index = reader;

  function reader.new(arr) 
    return setmetatable({ 
      arr = arr,
      byteIndex = 0
    }, reader);
  end;

  function reader:readByte() 
    local byte = self.arr:get(self.byteIndex);
    self.byteIndex = self.byteIndex + 1;

    return byte;
  end;

  function reader:readLong() 
    local a, b, c, d = 
      self:readByte(),
      self:readByte(),
      self:readByte(),
      self:readByte();
    
    local result = bit.bor(bit.lshift(d, 8), c);
    result = bit.bor(bit.lshift(result, 8), b);
    result = bit.bor(bit.lshift(result, 8), a);

    return result;
  end;

  function reader:readString(length) 
    local str = self.arr:slice(self.byteIndex, self.byteIndex + length);
    self.byteIndex = self.byteIndex + length;

    return encoders:decode(str);
  end;

  function reader:readBuffer(length) 
    local buffer = self.arr:slice(self.byteIndex, self.byteIndex + length);
    self.byteIndex = self.byteIndex + length;

    return buffer;
  end;
end;

local format = {}; do 
  format.__index = format;

  function format.new(data) 
    return setmetatable({ 
      buf = reader.new(data)
    }, format)
  end;

  function format:deserialize() 
    local buf = self.buf;
    local data = {
      fileMap = {},
      byteCodeArray = array.new();
    };

    local map_Length = buf:readLong();

    for i = 1, map_Length do 
      local keyLength = buf:readLong();
      local key = buf:readString(keyLength);
      local bytecode_Index = buf:readLong();

      data.fileMap[key] = bytecode_Index;
    end;

    local bytecode_Length = buf:readLong();

    for i = 1, bytecode_Length do 
      local bc_Length = buf:readLong();
      local bc_Buffer = buf:readBuffer(bc_Length);
      data.byteCodeArray:push(bc_Buffer);
    end;

    return data;
  end;
end;

local arr = array.new({ 1, 0, 0, 0, 8, 0, 0, 0, 116, 101, 115, 116, 46, 108, 117, 97, 0, 0, 0, 0, 1, 0, 0, 0, 96, 0, 0, 0, 27, 76, 117, 97, 81, 0, 1, 4, 8, 4, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 4, 0, 0, 0, 5, 0, 0, 0, 65, 64, 0, 0, 28, 64, 0, 1, 30, 0, 128, 0, 2, 0, 0, 0, 4, 6, 0, 0, 0, 0, 0, 0, 0, 112, 114, 105, 110, 116, 0, 3, 0, 0, 0, 0, 0, 0, 240, 63, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 });

local test = format.new(arr);
local test_Data = test:deserialize();

print(#test_Data.byteCodeArray.tbl)