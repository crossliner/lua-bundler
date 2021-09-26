const { randomBytes } = require("crypto");
const { spawnSync } = require("child_process");
const { join } = require("path");
const { writeFileSync, readFileSync, unlinkSync } = require("fs");

module.exports = (data) => {
  const [ output, input ] = [ 
    join(__dirname, "compile-data",`${randomBytes(7).toString("hex")}.bin`),
    join(__dirname, "compile-data",`${randomBytes(7).toString("hex")}.bin`)
  ];
  
  writeFileSync(input, data);
  
  const childProcess = spawnSync("luac5.1", [
    "-o",
    output,
    "-s",
    input
  ]);
  unlinkSync(input);
  
  if (childProcess.stderr.length > 0) return childProcess.stderr.toString("binary");
  const bytecode = readFileSync(output);
  
  unlinkSync(output);

  return bytecode;
}