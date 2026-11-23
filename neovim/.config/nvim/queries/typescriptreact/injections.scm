; extends

(call_expression
 function: ((identifier) @_name
   (#eq? @_name "gql"))
 arguments: ((template_string) @injection.content
   (#offset! @injection.content 0 1 0 -1)
   (#set! injection.language "graphql")))

(call_expression
 function: ((identifier) @_name
   (#eq? @_name "graphql"))
 arguments: ((template_string) @injection.content
   (#offset! @injection.content 0 1 0 -1)
   (#set! injection.language "graphql")))

; ((comment) @_gql_comment
;   (#eq? @_gql_comment "/* GraphQL */")
;   (template_string) @graphql)

((template_string) @injection.content
  (#lua-match? @injection.content "^`#graphql")
  (#offset! @injection.content 0 1 0 -1)
  (#set! injection.language "graphql"))
