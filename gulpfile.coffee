gulp          = require 'gulp'
clean         = require 'gulp-clean'
jsonCombine     = require 'gulp-jsoncombine'
connect       = require 'gulp-connect'
cors          = require 'cors'
ChristacheioStream = require 'gulp-json-template-christacheio'
localIntervalUUID = process.env.NANOCYTE_INTERVAL_UUID
localCredentialsServiceUUID = process.env.CREDENTIALS_SERVICE_UUID

gulp.task 'clean', ->
  gulp.src('dist', read: false).pipe clean()

gulp.task 'build', ->
  console.log 'building'
  christacheioStream = new ChristacheioStream  data: hello: 'world'
  gulp.src('./nanocyte-definitions/**/*.json')
    .pipe jsonCombine('registry.json', (data) -> new Buffer(JSON.stringify(data, null, 2)))
    .pipe christacheioStream
    .pipe gulp.dest './dist'

gulp.task '_build', ->
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

gulp.task 'default', ['clean', 'build', 'watch', 'server']
