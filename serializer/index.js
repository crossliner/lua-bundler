module.exports = class Serializer {
  constructor() {
    this.data = [];
  }

  writeLong(long) {
    const buf_Long = Buffer.alloc(4);
    buf_Long.writeInt32LE(long, 0);

    this.data.push(buf_Long);
  }

  writeByte(byte) {
    const buf_Byte = Buffer.alloc(1);
    buf_Byte.writeInt8(byte, 0);

    this.data.push(buf_Byte);
  }

  writeBuffer(buffer) {
    this.data.push(buffer);
  }

  writeString(str) {
    this.data.push(Buffer.from(str));
  }

  get buffer() {
    return Buffer.concat(this.data);
  }
}