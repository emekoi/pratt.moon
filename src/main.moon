-- require "util.meta"
-- moon = require "moon"
-- pratt = require "pratt"
--
-- io.write "> "
-- str = io.read!
--
-- while str\len! > 0
--   pratt.parse str
--   io.write "> "
--   str = io.read!
--
-- print moon.p pratt.ENV

arg = {...}

require "util.meta"
-- moon = require "moon"
lexer = require "lexer"
-- token = require "token.token"

ansi = (...) -> [ "#{string.char(27)}[#{esc}m" for esc in *{...} ]

ansi_print = (fmt, ...) ->
  io.write "#{ unpack fmt }#{ ... }#{ unpack ansi 0 }\n"

local LEXER

if #arg < 1
  io.write "> "
  str = io.read!

  while str\len! > 0
    LEXER = lexer.new str
    TOKEN = lexer.nextToken LEXER
    while TOKEN and TOKEN.type ~= "EOF"
      if TOKEN.type == "ERROR"
        ansi_print ansi(31), TOKEN.str
      else
        val = if TOKEN.type == "NUMBER" then TOKEN.num  else TOKEN.str
        print ("%-21s %s" ^ { TOKEN.type, val })

      TOKEN = lexer.nextToken LEXER

    io.write "> "
    str = io.read!
else
  str = ""
  if arg[1] == "--"
    str = io.read "*a"
  else
    file = io.open arg[1]
    str = file\read "*a"
    file\close!

  LEXER = lexer.new str
  TOKEN = lexer.nextToken LEXER
  while TOKEN and TOKEN.type ~= "EOF"
    if TOKEN.type == "ERROR"
      ansi_print ansi(31), TOKEN.str
    else
      val = if TOKEN.type == "NUMBER" then TOKEN.num  else TOKEN.str
      print ("%-21s %s" ^ { TOKEN.type, val })

    TOKEN = lexer.nextToken LEXER

return 0
