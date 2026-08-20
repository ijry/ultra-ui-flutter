// Resolver hook so Node can load the uview-plus source modules, which use
// extensionless ESM imports (bundler-style, e.g. './measure-adapter').
//
// Used by novel_reader_reference.mjs via --import.
import { register } from 'node:module'
import { pathToFileURL } from 'node:url'

export async function resolve(specifier, context, nextResolve) {
  try {
    return await nextResolve(specifier, context)
  } catch (error) {
    if (error?.code !== 'ERR_MODULE_NOT_FOUND') throw error
    // Retry with the extension the source omitted.
    return nextResolve(specifier + '.js', context)
  }
}

register(pathToFileURL(import.meta.filename))
