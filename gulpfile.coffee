server          = require 'gulp-webserver'
gulp            = require 'gulp'
download        = require 'gulp-download'
jsonTransform   = require 'gulp-json-transform'
gutil           = require 'gulp-util'
clean           = require 'gulp-clean'
RegistryMangler = require './registry-mangler'

registryUrl = process.env.NODE_REGISTRY_URL || 'https://raw.githubusercontent.com/octoblu/nanocyte-node-registry/master/registry.json'

gulp.task 'clean', ->
  gulp.src 'public', read: false
    .pipe clean()

gulp.task 'build', ->
  mangler = new RegistryMangler
  download(registryUrl)
    .pipe jsonTransform (originalRegistry) =>
      mangler.mangle originalRegistry
    .pipe gulp.dest './public'

gulp.task 'server', ->
  gulp
    .src('public')
    .pipe(server({
      livereload: false,
      directoryListing: false,
      open: false,
    }))

gulp.task 'default', ['clean', 'build', 'server']
