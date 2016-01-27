gulp          = require 'gulp'
clean         = require 'gulp-clean'
jsonCombine     = require 'gulp-jsoncombine'
connect       = require 'gulp-connect'
cors          = require 'cors'
ChristacheioStream = require 'gulp-json-template-christacheio'

templateData =
  interval_service_uuid: process.env.NANOCYTE_INTERVAL_UUID || '765bd3a4-546d-45e6-a62f-1157281083f0'
  credentials_service_uuid : process.env.CREDENTIALS_SERVICE_UUID || 'c339f6ce-fe26-4788-beee-c97605f50403'

gulp.task 'clean', ->
  gulp.src('dist', read: false).pipe clean()

gulp.task 'build', ->
  christacheioStream = new ChristacheioStream  data: templateData
  gulp.src('./nanocyte-definitions/**/*.json')
    .pipe jsonCombine('registry.json', (data) -> new Buffer(JSON.stringify(data, null, 2)))
    .pipe christacheioStream
    .pipe gulp.dest './dist'

gulp.task 'watch', ->
  gulp.watch(['./nanocyte-definitions/**/*.json'], ['build']);

gulp.task 'server', ->
  connect.server
    root: ['dist'],
    port: process.env.PORT || 9999
    middleware: -> [cors()]

gulp.task 'default', ['clean', 'build', 'watch', 'server']
