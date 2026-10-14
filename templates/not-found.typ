// The page a wrong URL lands on.

#import "@baudelaire/html:0.1.0": h
#import "/templates/parts.typ": prose

#let not-found(page, body) = prose(page, {
  h("h1", page.frontmatter.title)
  body
  h("p", h("a", href: "/", "Back to the front page"))
})
