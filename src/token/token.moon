local *
require "util.meta"

token = {
  TOKEN: {}
  KEYWORD: {}

  new: (t) =>
    {
      type: t.str
      len:  math.max 0, @tail - @head
      str: if t ~= token.TOKEN.EOF
        @source\sub(@head, @tail - 1)
      else t.lit
      line: @line
      col: @col
      env: {}
    }

  err: (msg) =>
    {
      type: token.TOKEN.ERROR.str
      str: msg
      len: msg\len!
      line: @line
      col: @col
    }

  match: (tok, t) =>
    if not tok or tok.type ~= t
      error ("[{line}:{col}] expected %s got %s" % @) ^ { t, tok.type }

  registerToken: (str) ->
    for k, v in pairs require str
      token.TOKEN[k] or= v

  registerKeyword: (str) ->
    for k, v in pairs require str
      token.KEYWORD[v.lit] or= v
}

token.registerToken "token.control"
token.registerToken "token.keyword"
token.registerToken "token.operator"
token.registerKeyword "token.keyword"

return token
