fs = require 'fs'

{print} = require 'sys'
{spawn} = require 'child_process'

build = (min=false,callback) ->
  opts = if min then 'm' else ''
  minExt = if min then '.min' else ''
  outFile = 'dist/jquery.yacal'+minExt+'.js'
  coffee = spawn 'coffeebar', ['-bB'+opts, '-o', outFile, 'src']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()
  coffee.on 'exit', (code) ->
    print outFile + ' is done!\n'
    callback?(outFile) if code is 0

task 'sbuild', 'Build distr/ from src/', ->
  build()
  build(true)