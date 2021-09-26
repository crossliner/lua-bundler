const format = require("./format");

const test = new format();
test.add("main.lua", "print(import('joe.lua'))");
test.add("joe.lua", "return 420"); // weird number ok
console.log(test.serialize().join(", "))