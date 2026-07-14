;; extends

((raw_string_literal
  (raw_string_literal_content) @injection.content)
 (#match? @injection.content "^[\n\r\t ]*([Ss][Ee][Ll][Ee][Cc][Tt]|[Ww][Ii][Tt][Hh]|[Ii][Nn][Ss][Ee][Rr][Tt]|[Uu][Pp][Dd][Aa][Tt][Ee]|[Dd][Ee][Ll][Ee][Tt][Ee]|[Cc][Rr][Ee][Aa][Tt][Ee]|[Aa][Ll][Tt][Ee][Rr]|[Dd][Rr][Oo][Pp])")
 (#set! injection.language "sql"))
