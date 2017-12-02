local *
token = require "token.token"
require "util.meta"

lexer = {}

is = (v, t) -> v and v == v\match t

lexer.new = (source) ->
  {
    :source,
    head: 1,
    tail: 1,
    line: 0,
    col: 0,
  }

lexer.end = () =>
  @source[@tail] == nil

lexer.advance = () =>
  @tail += 1
  @col += 1
  return @source[@tail - 1]

lexer.peek = () =>
  @source[@tail]

lexer.next = () =>
  if lexer.end(@) then nil
  @source[@tail + 1]

lexer.match = (c) =>
  if lexer.end(@) then return false
  if @source[@tail] ~= c then return false
  @tail += 1
  return true

lexer.err = (msg) =>
  ("[{line}:{col}] " % @) + msg

skip_whitespace = () =>
  c = lexer.peek @
  while c and (is c, '%s')
    if c == "\n" then @line += 1
    lexer.advance @
    c = lexer.peek @


-- static ptoken_t indentifier() {
-- while (is_alpha_num(peek())) advance();
-- ptoken_type_t type = TOK_IDENTIFIER;
--
-- size_t len = Lexer.current - Lexer.token_start;
-- for(pkeyword_t *key = keywords; key->name != NULL; key++){
--   if (len == key->len && !memcmp(Lexer.token_start, key->name, len)) {
--     type = key->type;
--     break;
--   }
-- }
-- return make_token(type);
-- }

is_keyword = () =>
  if token.KEYWORD[@source\sub(@head, @tail - 1)] then return true


mk_indentifier = () =>
  while is(lexer.peek(@), '%w') do lexer.advance(@)
  if token.KEYWORD[@source\sub(@head, @tail - 1)]
    return token.new @, token.KEYWORD[@source\sub(@head, @tail - 1)]
  return token.new @, token.TOKEN.IDENTIFIER

mk_number = () =>
  while is(lexer.peek(@), '%d') do lexer.advance(@)
  -- look for fractional part
  if lexer.peek(@) == '.' and is(lexer.next(@), '%d')
    -- consume decimal
    lexer.advance @
    while is(lexer.peek(@), '%d') do lexer.advance(@)
  tok = token.new @, token.TOKEN.NUMBER
  tok.num = tonumber tok.str
  tok.str = nil
  return tok

mk_string = () =>
  while lexer.peek(@) ~= '"' and not lexer.end(@)
    if lexer.peek(@) == '\n' then @line += 1
    lexer.advance @
  -- unterminated string
  if lexer.end(@) then return token.err @, lexer.err @, 'unterminated string'
  -- the closing '"'
  lexer.advance @
  tok = token.new @, token.TOKEN.STRING
  tok.str = tok.str\match '^"(.-)"$'
  return tok

lexer.nextToken = () =>
  skip_whitespace @
  -- next token starts with current character
  @head = @tail
  if lexer.end(@) return token.new @, token.TOKEN.EOF

  char = lexer.advance @
  if is(char, '%a') then return mk_indentifier @
  if is(char, '%d') then return mk_number @

  switch char
    when '"'
      return mk_string @
    when '+'
      if lexer.match @, '=' then return token.new @, token.TOKEN.OP_ADD_ASSIGN
      return token.new @, token.TOKEN.OP_ADD
    when '-'
      if lexer.match @, '=' then return token.new @, token.TOKEN.OP_SUB_ASSIGN
      return token.new @, token.TOKEN.OP_SUB
    when '*'
      if lexer.match @, '*'
        if lexer.match @, '=' then return token.new @, token.TOKEN.OP_POW_ASSIGN
        return token.new @, token.TOKEN.OP_POW
      if lexer.match @, '=' then return token.new @, token.TOKEN.OP_MUL_ASSIGN
      return token.new @, token.TOKEN.OP_MUL
    when '/'
      if lexer.match @, '=' then return token.new @, token.TOKEN.OP_DIV_ASSIGN
      return token.new @, token.TOKEN.OP_DIV
    when '%'
      if lexer.match @, '=' then return token.new @, token.TOKEN.OP_MOD_ASSIGN
      return token.new @, token.TOKEN.OP_MOD
    when '!'
      if lexer.match @, '=' then return token.new @, token.TOKEN.OP_NOT_EQUAL
      return token.new @, token.TOKEN.OP_NOT
    when '>'
      if lexer.match @, '=' then return token.new @, token.TOKEN.OP_GREATER_EQUAL
      if lexer.match @, '>'
        if lexer.match @, '=' then return token.new @, token.TOKEN.OP_SHIFT_RIGHT_ASSIGN
        return token.new @, token.TOKEN.OP_SHIFT_RIGHT
      return token.new @, token.TOKEN.OP_GREATER
    when '<'
      if lexer.match @, '=' then return token.new @, token.TOKEN.OP_LESS_EQUAL
      if lexer.match @, '<'
        if lexer.match @, '=' then return token.new @, token.TOKEN.OP_SHIFT_LEFT_ASSIGN
        return token.new @, token.TOKEN.OP_SHIFT_LEFT
      return token.new @, token.TOKEN.OP_LESS
    when '='
      if lexer.match @, '=' then return token.new @, token.TOKEN.OP_EQUAL
      return token.new @, token.TOKEN.OP_ASSIGN
    when '|'
      if lexer.match @, '=' then return token.new @, token.TOKEN.OP_BIT_OR_ASSIGN
      return token.new @, token.TOKEN.OP_BIT_OR
    when '&'
      if lexer.match @, '=' then return token.new @, token.TOKEN.OP_BIT_AND_ASSIGN
      return token.new @, token.TOKEN.OP_BIT_AND
    when '^'
      if lexer.match @, '=' then return token.new @, token.TOKEN.OP_BIT_XOR_ASSIGN
      return token.new @, token.TOKEN.OP_BIT_XOR
    when '~'
      if lexer.match @, '=' then return token.new @, token.TOKEN.OP_BIT_NOT_ASSIGN
      return token.new @, token.TOKEN.OP_BIT_NOT
    when '.'
      if lexer.match @, '.'
        if lexer.match @, '.' then return token.new @, token.TOKEN.OP_RANGE_EXCLUDED
        return token.new @, token.TOKEN.OP_RANGE_INCLUDED
      return token.new @, token.TOKEN.OP_DOT
    when '('
      return token.new @, token.TOKEN.OP_LEFT_PAREN
    when ')'
      return token.new @, token.TOKEN.OP_RIGHT_PAREN
    when '['
      return token.new @, token.TOKEN.OP_LEFT_BRACKET
    when ']'
      return token.new @, token.TOKEN.OP_RIGHT_BRACKET
    when '{'
      return token.new @, token.TOKEN.OP_LEFT_BRACE
    when '}'
      return token.new @, token.TOKEN.OP_RIGHT_BRACE
    when ';'
      return token.new @, token.TOKEN.OP_SEMICOLON
    when ','
      return token.new @, token.TOKEN.OP_COMMA
    when ':'
      return token.new @, token.TOKEN.OP_COLON
    else
      return token.err @, lexer.err @, "unexpected symbol '#{char}'"

return lexer
