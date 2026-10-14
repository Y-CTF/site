// An ordinary page: about, committee, inscription. Title then words.

#import "@baudelaire/html:0.1.0": h
#import "/templates/parts.typ": prose

#let page(page, body) = prose(page, {
  h("h1", page.frontmatter.title)
  body
})
