gulp          = require 'gulp'
download      = require 'gulp-download'
jsonTransform = require 'gulp-json-transform'
jsonCombine   = require 'gulp-jsoncombine'
clean         = require 'gulp-clean'
mergeStream   = require 'merge-stream'
mergeJson     = require 'gulp-merge-json'
order         = require 'gulp-order'
connect       = require 'gulp-connect'
cors          = require 'cors'

RegistryMangler = require './registry-mangler'

registryUrl = process.env.NODE_REGISTRY_URL || 'https://raw.githubusercontent.com/octoblu/nanocyte-node-registry/master/registry.json'
localIntervalUUID = process.env.NANOCYTE_INTERVAL_UUID
localCredentialsServiceUUID = process.env.CREDENTIALS_SERVICE_UUID

gulp.task 'clean', ->
  gulp.src 'public', read: false
    .pipe clean()

gulp.task 'build', ->
  devNanocytes =
    gulp.src('./nanocyte-definitions/**/*.json')
      .pipe jsonCombine('new-nanocytes.json', (data) -> new Buffer(JSON.stringify(data, null, 2)))

  mergeStream(devNanocytes, download(registryUrl))
    .pipe order(['registry.json', 'new-nanocytes.json'])
    .pipe mergeJson('registry.json')


gulp.task 'build', ->
  mangler = new RegistryMangler
  download(registryUrl)
    .pipe jsonTransform (originalRegistry) =>
      replaceMap =
        '765bd3a4-546d-45e6-a62f-1157281083f0' : localIntervalUUID
        'CREDENTIALS_SERVICE_UUID' : localCredentialsServiceUUID

      mangler.mangle originalRegistry: originalRegistry, replaceMap: replaceMap, replaceNodes: replaceNodes
    .pipe gulp.dest './public'

gulp.task 'watch', ->
  gulp.watch(['./nanocyte-definitions/**/*.json'], ['build']);


gulp.task 'server', ->
  connect.server
    root: ['public'],
    port: process.env.PORT || 9999
    middleware: -> [cors()]

gulp.task 'default', ['clean', 'build', 'server']
