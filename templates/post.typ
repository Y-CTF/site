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
      h("span", h("strong", h("time", datetime: page.date.iso, page.date.display)))
    }
    h("span", class: "text-muted-foreground", "(" + str(page.reading.minutes) + " min. read)")
    h("span", class: "flex flex-row gap-2", for term in page.taxonomies.at("categories", default: ()) {
      pill(term)
    })
  })

  // A bundle's own files, offered plainly rather than behind a toggle: there is
  // no script on this site, and a list of three filenames needs none.
  let files = page.assets.pairs()
  if files.len() > 0 {
    h("div", class: "flex flex-row gap-4 flex-wrap border border-muted px-2 py-1 my-4", {
      for (name, url) in files { h("a", href: url, name) }
    })
  }

  body
})
