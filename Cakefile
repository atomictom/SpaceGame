{exec} = require 'child_process'
Rehab = require 'rehab'

src_folder = "gamecore"
out_file = "game"

task 'build', 'Build coffee2js using Rehab', sbuild = ->
  console.log "Building project from #{src_folder}/*.coffee to ./#{out_file}.js"

  files = new Rehab().process "./#{src_folder}"

  to_single_file = "--join #{out_file}.js"
  from_files = "--compile #{files.join ' '}"

  exec "coffee #{to_single_file} #{from_files}", (err, stdout, stderr) ->
    return
