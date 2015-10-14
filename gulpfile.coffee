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
gulp.task 'clean', ->
  gulp.src 'public', read: false
    .pipe clean()

gulp.task 'build', ->
  mangler = new RegistryMangler
  download(registryUrl)
    .pipe jsonTransform (originalRegistry) =>
      replaceMap =
        '765bd3a4-546d-45e6-a62f-1157281083f0' : localIntervalUUID

      mangler.mangle originalRegistry: originalRegistry, replaceMap: replaceMap
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
