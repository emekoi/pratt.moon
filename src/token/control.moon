{
  EOF: {
    rbp: 0, lbp: 0
    lit: "#<EOF>"
    str: "EOF"
  }
  ERROR: {
    rbp: 0, lbp: 0
    lit: "#<ERROR>"
    str: "ERROR"
  }
  COMMENT: {
    rbp: 0, lbp: 0
    lit: "#<COMMENT>"
    str: "COMMENT"
  }
  STRING: {
    rbp: 0, lbp: 0
    lit: "#<STRING>"
    str: "STRING"
    nud: => @str
  }
  NUMBER: {
    rbp: 0, lbp: 0
    lit: "#<NUMBER>"
    str: "NUMBER"
    nud: => @num
  }
  IDENTIFIER: {
    rbp: 0, lbp: 0
    lit: "#<IDENTIFIER>"
    str: "IDENTIFIER"
    nud: => @env[@str]
  }
}
