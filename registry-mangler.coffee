_ = require 'lodash'

class RegistryMangler
  mangle: (options) =>
    {originalRegistry, replaceMap} = options
    registryString = JSON.stringify originalRegistry, null, 2

    _.each replaceMap, (value, key) =>
      replaceRegex = new RegExp key, 'g'
      registryString = registryString.replace replaceRegex, value

    JSON.parse registryString

module.exports = RegistryMangler
