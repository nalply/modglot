export function resolve(specifier, context, nextResolve) {
  //console.log("loader", { specifier, context })
  const parent = context.parentURL
  const resolvePromise = nextResolve(specifier)

  function log(reject) {
    return resolveResult => {
      if (resolveResult.format) resolveResult.format = 'module'
      const resolveResultString = reject
        ? resolveResult.toString()
        : resolveResult.format + " " + resolveResult.url
      console.log("loader", specifier, "-->", resolveResultString)
      return resolveResult
    }
  }
  return resolvePromise
    .then(log(), log('reject'))
}
