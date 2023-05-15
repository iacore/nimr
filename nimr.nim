import std/[os, osproc, strformat, strutils, sequtils]

proc print_usage =
  echo &"Usage: {paramStr(0)} [nimargs...] FILE.nim"

let params = commandLineParams()
if params.len == 0:
  print_usage()
  quit(1)

proc getFirstPositionalIndex: int =
  for i in 0..<params.len:
    if params[i] == "--":
      return i + 1
    if params[i].startsWith("-"):
      continue
    return i

let ii = getFirstPositionalIndex()

let script = params[ii]
let splitat = script.searchExtPos

if splitat == -1:
  echo "The given FILE has no extension: " & script
  quit(1)

let exe_name = script[0..<splitat].absolutePath
let should_rebuild = try:
  fileNewer(script, exe_name)
except OSError:
  true

if should_rebuild:
  let p = startProcess("nim", args=concat(@["c"], params[0..ii]), options={poParentStreams,poUsePath})
  let code = p.waitForExit()
  if code != 0:
    quit(code)
  p.close()

let p = startProcess(exe_name, args=params[ii+1..^1], options={poParentStreams,poUsePath})
let code = p.waitForExit()
quit(code)
p.close()

