_ = require 'lodash'
PROD_INTERVAL_SERVICE_UUID = '765bd3a4-546d-45e6-a62f-1157281083f0'

localIntervalServiceCreds = require '../nanocyte-interval-redis/meshblu.json'

class RegistryMangler
  mangle: (originalRegistry) =>
    registryString = JSON.stringify originalRegistry, null, 2
    intervalRegex = new RegExp PROD_INTERVAL_SERVICE_UUID, 'g'
    newRegistryString = registryString.replace intervalRegex, localIntervalServiceCreds.uuid

    newRegistry = JSON.parse newRegistryString
    newRegistry

module.exports = RegistryMangler
