const format = require("./format");

const test = new format();
test.add("test.lua", "print(1)");

console.log(test.serialize().join(", "))