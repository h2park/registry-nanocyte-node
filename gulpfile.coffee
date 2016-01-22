server          = require 'gulp-webserver'
gulp            = require 'gulp'
download        = require 'gulp-download'
jsonTransform   = require 'gulp-json-transform'
gutil           = require 'gulp-util'
clean           = require 'gulp-clean'
RegistryMangler = require './registry-mangler'
cors = require 'cors'
registryUrl = process.env.NODE_REGISTRY_URL || 'https://raw.githubusercontent.com/octoblu/nanocyte-node-registry/master/registry.json'
localIntervalUUID = process.env.NANOCYTE_INTERVAL_UUID
localCredentialsServiceUUID = process.env.CREDENTIALS_SERVICE_UUID

gulp.task 'clean', ->
  gulp.src 'public', read: false
    .pipe clean()

gulp.task 'build', ->
  mangler = new RegistryMangler
  download(registryUrl)
    .pipe jsonTransform (originalRegistry) =>
      replaceMap =
        '765bd3a4-546d-45e6-a62f-1157281083f0' : localIntervalUUID
        'CREDENTIALS_SERVICE_UUID' : localCredentialsServiceUUID

      replaceNodes =
        channel:
          sendWhitelist: ['CREDENTIALS_SERVICE_UUID']
          composedOf:
            'octoblu-credentials-message-formatter':
              'type': 'nanocyte-component-octoblu-credentials-message-formatter'
              'linkedToPrev': true
              'linkedToOutput': true
            'pass-through':
              'type': 'nanocyte-component-pass-through'
              'linkedToInput': true
              'linkedToNext': true
            'octoblu-credentials-configurator':
              'type': 'nanocyte-component-octoblu-credentials-configurator'
              'linkedToPrev': true
              'linkedTo': ['octoblu-channel']
            'octoblu-channel':
              'type': 'nanocyte-component-octoblu-channel-request-formatter'
              'linkedToPrev': true
              'linkedTo': ['http-request']
            'http-request':
              'type': 'nanocyte-component-http-request'
              'linkedTo': ['parse-body']
            'parse-body':
              'type': 'nanocyte-component-body-parser'
              'linkedToNext': true

      mangler.mangle originalRegistry: originalRegistry, replaceMap: replaceMap, replaceNodes: replaceNodes
    .pipe gulp.dest './public'

gulp.task 'server', ->
  gulp
    .src('public')
    .pipe(server({
      port: process.env.PORT || 9999
      livereload: false,
      directoryListing: false,
      open: false,
      middleware: [cors()]
    }))

gulp.task 'default', ['clean', 'build', 'server']
