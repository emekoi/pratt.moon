local *
local token, LEXER
require "util.meta"
lexer = require "lexer"

pratt = {}
pratt.ENV = {}

pratt.OP_CODE = {
  LITERAL: class OP_LITERAL
    lbp: 0, rbp: 0
    new: (@val) =>
    nud: => tonumber(@val) or @val

  "+": class OP_ADD
    lbp: 1, rbp: 0
    led: (left) =>
      if type(left) == "string"
        left = pratt.ENV[left]
      left + expression @lbp

  "-": class OP_SUB
    lbp: 1, rbp: 10
    nud: () => -expression @rbp
    led: (left) =>
      if type(left) == "string"
        left = pratt.ENV[left]
      left - expression @lbp

  "*": class OP_MUL
    lbp: 2, rbp: 0
    led: (left) =>
      if type(left) == "string"
        left = pratt.ENV[left]
      left * expression @lbp

  "/": class OP_DIV
    lbp: 2, rbp: 0
    led: (left) =>
      if type(left) == "string"
        left = pratt.ENV[left]
      left / expression @lbp

  "%": class OP_MOD
    lbp: 2, rbp: 0
    led: (left) =>
      if type(left) == "string"
        left = pratt.ENV[left]
      left % expression @lbp

  "^": class OP_POW
    lbp: 3, rbp: 0
    led: (left) =>
      if type(left) == "string"
        left = pratt.ENV[left]
      left ^ expression @lbp - 1

  "(": class OP_LPR
    lbp: 0, rbp: 0
    nud: (left) =>
      expr = expression!
      match pratt.OP_CODE[")"]
      return expr

  ")": class OP_RPR
    lbp: 0, rbp: 0

  "=": class OP_ASN
    lbp: 1, rbp: 0
    led: (left) =>
      if type(left) == "number"
        error "left hand expression '#{left}' is not assignable"
      pratt.ENV[left] = expression @lbp - 1
      return pratt.ENV[left]

  END: class OP_END
    lbp: 0, rbp: 0
}

expression = (rbp = 0) ->
  t = token
  token = getToken LEXER
  if token
    nud = t\nud!
    left = nud

    while rbp < token.lbp
      t = token
      token = getToken LEXER
      led = t\led left
      left = led

    if type(left) == "string"
      left = pratt.ENV[left] or "nil"

    return left

match = (tok) ->
  if tok and tok.__class ~= token.__class
    error "expected #{tok}"
  token = getToken LEXER


getToken = (L) ->
  tok = lexer.nextToken L
  if tok.type == "ERROR"
    print (string.char(27) + '[31m') + tok.str + (string.char(27) + '[0m')
  elseif tok.type == "IDENTIFIER"
    return pratt.OP_CODE["LITERAL"] tok.str
  elseif tok.type == "NUMBER"
    return pratt.OP_CODE["LITERAL"] tok.num
  elseif pratt.OP_CODE[tok.str]
    return pratt.OP_CODE[tok.str]!
  elseif lexer.end L
    return pratt.OP_CODE["END"]!


pratt.parse = (program) ->
  if program\len! > 0
    LEXER = lexer.new program
    token = getToken LEXER
    if token
      res = expression!
      print res if res

pratt
