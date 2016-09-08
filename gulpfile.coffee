_           = require 'lodash'
gulp        = require 'gulp'
clean       = require 'gulp-clean'
jsonCombine = require 'gulp-jsoncombine'
connect     = require 'gulp-connect'
cors        = require 'cors'

ChristacheioStream = require 'gulp-json-template-christacheio'

gulp.task 'clean', ->
  gulp.src('dist', read: false).pipe clean()

majorTemplateData =
  interval_service_uuid    : '765bd3a4-546d-45e6-a62f-1157281083f0'
  credentials_service_uuid : 'c339f6ce-fe26-4788-beee-c97605f50403'
  triggers_service_uuid    : 'b560b6ee-c264-4ed9-b98e-e3376ce6ce64'

hpeTemplateData =
  interval_service_uuid    : '8b807eae-f50a-46df-b025-bf15f67146a9'
  credentials_service_uuid : '7f5fa746-c537-4d7c-aabc-25880592b2d5'
  triggers_service_uuid    : '6afb5069-36c7-4d0c-8406-adc6cccb4155'

defaultTemplateData =
  interval_service_uuid    : process.env.NANOCYTE_INTERVAL_UUID
  credentials_service_uuid : process.env.CREDENTIALS_SERVICE_UUID
  triggers_service_uuid    : process.env.TRIGGERS_SERVICE_UUID

gulp.task 'build', ->
  data = _.defaults defaultTemplateData, majorTemplateData
  christacheioStream = new ChristacheioStream { data }
  gulp.src('./nanocyte-definitions/**/*.json')
    .pipe jsonCombine('registry.json', (data) -> new Buffer(JSON.stringify(data, null, 2)))
    .pipe christacheioStream
    .pipe gulp.dest './dist'

gulp.task 'build:hpe', ->
  christacheioStream = new ChristacheioStream  data: hpeTemplateData
  gulp.src('./nanocyte-definitions/**/*.json')
    .pipe jsonCombine('registry.json', (data) -> new Buffer(JSON.stringify(data, null, 2)))
    .pipe christacheioStream
    .pipe gulp.dest './dist/hpe'

gulp.task 'build:major', ->
  christacheioStream = new ChristacheioStream  data: majorTemplateData
  gulp.src('./nanocyte-definitions/**/*.json')
    .pipe jsonCombine('registry.json', (data) -> new Buffer(JSON.stringify(data, null, 2)))
    .pipe christacheioStream
    .pipe gulp.dest './dist/major'

gulp.task 'watch', ->
  gulp.watch(['./nanocyte-definitions/**/*.json'], ['build'])

gulp.task 'server', ->
  connect.server
    root: ['dist'],
    port: process.env.PORT || 9999
    middleware: -> [cors()]

gulp.task 'build:all', ['build', 'build:major', 'build:hpe']

gulp.task 'default', ['clean', 'build', 'watch', 'server']
