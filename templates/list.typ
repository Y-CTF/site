// Every generated listing: the writeup archive, and one page per category.
//
// The rows come from the build as `page.frontmatter.entries`, so this renders a
// taxonomy term and a paginated collection with the same code.

#import "@baudelaire/html:0.1.0": h
#import "/templates/parts.typ": pill, prose

#let list(page, body) = prose(page, {
  h("h1", page.frontmatter.title)
  body

  let entries = page.frontmatter.at("entries", default: ())
  if entries.len() == 0 {
    h("p", class: "text-muted-foreground", "Nothing here yet.")
  } else {
    h("ul", for entry in entries {
      h("li", class: "flex items-center gap-2 md:gap-4 flex-wrap", {
        h("a", href: entry.url, entry.label)
        if entry.at("date", default: none) != none {
          h("span", class: "text-sm text-muted-foreground", entry.display)
        }
        for term in entry.at("taxonomies", default: (:)).at("categories", default: ()) { pill(term) }
      })
    })
  }

  // Pagination, when the build split the listing.
  let nav = page.at("nav", default: (:))
  h("div", class: "flex gap-4 mt-8", {
    if nav.at("prev", default: none) != none { h("a", href: nav.prev.url, "← " + nav.prev.title) }
    if nav.at("next", default: none) != none { h("a", href: nav.next.url, nav.next.title + " →") }
  })
})
