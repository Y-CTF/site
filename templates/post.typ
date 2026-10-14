// One writeup: who solved it, when, how long it reads, and what it was.

#import "@baudelaire/html:0.1.0": h
#import "/templates/parts.typ": pill, prose, say

#let post(page, body) = prose(page, {
  let front = page.frontmatter
  let authors = front.at("authors", default: ())

  h("h1", {
    front.title
    if authors.len() > 0 {
      h("span", class: "text-muted-foreground text-xl", " by " + authors.join(", "))
    }
  })

  h("div", class: "flex flex-row gap-4 items-center flex-wrap", {
    if page.date != none {
      // ISO, as the old site wrote it: these are dated records, not prose.
      h("span", h("strong", h("time", datetime: page.date.iso, page.date.iso)))
    }
    h("span", class: "text-muted-foreground", "(" + str(page.reading.minutes) + " min. read)")
    h("span", class: "flex flex-row gap-2", for term in page.taxonomies.at("categories", default: ()) {
      pill(term)
    })
  })

  body

  // The files that came with the writeup, after it rather than before: the old
  // site kept them behind a toggle that started closed, and `details` is the same
  // thing without a script.
  let files = page.assets.pairs()
  if files.len() > 0 {
    h("details", class: "not-prose my-6 text-sm", {
      h("summary", class: "cursor-pointer text-muted-foreground", "Files")
      h("div", class: "flex flex-row gap-4 flex-wrap mt-2", {
        for (name, url) in files { h("a", href: url, name) }
      })
    })
  }
})
