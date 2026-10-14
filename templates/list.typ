// Every generated listing: the paginated writeup archive, and one page per
// category.
//
// The rows come from the build as `page.frontmatter.entries`, so this renders a
// taxonomy term and a paginated collection with the same code. The page's own
// `body` is deliberately dropped: a generated listing's body is the build's own
// fallback markup for these same rows, and rendering both listed everything
// twice.

#import "@baudelaire/html:0.1.0": h
#import "/templates/parts.typ": rows, say, sheet

#let list(page, body) = sheet(page, {
  let entries = page.frontmatter.at("entries", default: ())
  let nav = page.frontmatter.at("nav", default: (:))
  let prev = nav.at("prev", default: none)
  let next = nav.at("next", default: none)
  let whole = prev == none and next == none

  h(
    "header",
    class: "flex items-baseline justify-between gap-4 border-b border-border pb-2 mb-2",
    {
      h("h1", class: "text-xl md:text-2xl font-black tracking-tight", page.frontmatter.title)
      // Only when this page is the whole listing. On a paginated one the number
      // counts the rows in front of the reader, which is not what a count beside
      // a title is read as.
      if whole { h("span", class: "text-xs text-muted-foreground tabular-nums shrink-0", str(entries.len())) }
    },
  )

  if entries.len() == 0 {
    h("p", class: "text-sm text-muted-foreground py-4", say(page, "nothing-here", fallback: "Nothing here yet."))
  }

  rows(entries)

  // Pagination, when the build split the listing. `nav` holds the neighbouring
  // page's url, and the label is the build's own vocabulary, so a French reader
  // gets a French one. Two quiet links on one rule, not two buttons: this is the
  // foot of a table and the reader is already looking at the bottom of it.
  if not whole {
    let step(url, label) = h(
      "a",
      href: url,
      class: "text-sm text-muted-foreground no-underline hover:text-foreground transition-colors",
      label,
    )
    h("nav", class: "flex items-center justify-between gap-4 border-t border-border mt-2 pt-2", {
      if prev != none { step(prev, say(page, "previous", fallback: "\u{2190} Previous")) } else { h("span", "") }
      if next != none { step(next, say(page, "next", fallback: "Next \u{2192}")) } else { h("span", "") }
    })
  }
})
