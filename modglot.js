var modglot = { hasAwait: null, kind: null }

modglot.hasAwait = (function() {
  try {
    new Function("async () => 0")
    return true
  }
  catch (err) {
    return false
  }
})()

// await is parsed as an identifier if not in an async context nor modules
// in esm or async function: await /1/ / 1; (operator, regexp, divide, number)
// else: await / 1 //1; (variable, divide, number, comment)

if (false) await /1//1; modglot.kind = 'esm'; export default modglot
; // prevent automatical semicolon insertion

(function(root) {
  if (typeof define === 'function' && define.amd) {
    modglot.kind = 'amd'
    define([], function() { return modglot })
  }
  else if (typeof exports === 'object') {
    modglot.kind = 'cjs'
    module.exports = modglot
    Object.defineProperty(exports, "__esModule", { value: true })
  }
  else if (typeof root === 'object') {
    modglot.kind = 'browser-legacy'
    root.modglot = modglot
  }

  // EcmaScript Modules have none of these properties set but the await hack
  // above will be already executed here. So don't run anything here.
})(this)

