import modglot from  "../modglot.js"

console.log(process.version.split('.')[0], "esm", modglot)

let awaitHack = false
if (false) await /1//1; awaitHack = true
console.log("awaitHack ===", awaitHack)

