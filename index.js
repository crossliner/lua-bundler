const { readFileSync, writeFileSync } = require("fs");
const { resolve } = require("path");

const config = require("./config.json");
const format = require("./format");
const loader = readFileSync("./loader.lua");
const luamin = require("./luamin");

const bundle = new format(config.strip);

const [ , , ...args ] = process.argv;
if (args.length < 1) return console.log("args are required");

for (const i in args) {
  const file = args[i];
  const path = resolve(file);
  const data = readFileSync(path, { encoding: "utf-8" });
  const [ , ...paths ] = file.split("/");

  bundle.add(paths.join("/"), data);
}
const data = bundle.serialize().join(", ")

const bundleData = `
${loader}

local data = array.new({${data}});
local format_Data = format.new(data):deserialize();

load(format_Data, "main.lua");
`
const minifiedData = config.minify ? luamin.Minify(bundleData, { 
  RenameVariables: true
}) : bundleData;

writeFileSync("dist.lua", minifiedData);