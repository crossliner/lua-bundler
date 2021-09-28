const compile = require("../compile");
const serializer = require("../serializer");

module.exports = class format {
  constructor(strip) {
    this.byteCodeArray = [];
    this.fileMap = new Map();
    this.strip = strip;
  }

  add(file, script) {
    const index = this.byteCodeArray.push(script) - 1;
    this.fileMap.set(file, index);
  }

  serialize() {
    const format_Serializer = new serializer();
    format_Serializer.writeLong(this.fileMap.size);

    for (const [ i, v ] of this.fileMap.entries()) {
      format_Serializer.writeLong(i.length);
      format_Serializer.writeString(i);
      format_Serializer.writeLong(v);
    }

    format_Serializer.writeLong(this.byteCodeArray.length);

    for (let i in this.byteCodeArray) {
      const v = this.byteCodeArray[i];
      const bytecode = compile(v, this.strip);
      if (typeof bytecode === "string") throw new Error(bytecode);
      format_Serializer.writeLong(bytecode.length);
      format_Serializer.writeBuffer(bytecode);
    }

    return format_Serializer.buffer;
  }
}