// Every writeup, by year. The listing at `/writeups/` is the paginated one; this
// is the whole archive on one page, which is what somebody looking for an old
// challenge actually wants.

#import "@baudelaire/html:0.1.0": h
#import "@baudelaire/pages:0.1.0": pages
#import "/templates/parts.typ": pill, prose

#let archive(page, body) = prose(page, {
  h("h1", page.frontmatter.title)
  body

  let solved = pages(page.lang).filter(one => one.collection == "writeups" and one.at("date", default: none) != none)

  // `pages` is already newest first, so the years come out in order by grouping
  // in the order they are met rather than by sorting again.
  let years = ()
  for entry in solved {
    let year = entry.date.slice(0, 4)
    if year not in years { years.push(year) }
  }

  for year in years {
    h("h2", year)
    h("ul", for entry in solved.filter(one => one.date.slice(0, 4) == year) {
      h("li", class: "flex items-center gap-2 md:gap-4 flex-wrap", {
        h("a", href: entry.url, entry.label)
        h("span", class: "text-sm text-muted-foreground", entry.display)
        for term in entry.at("taxonomies", default: (:)).at("categories", default: ()) { pill(term) }
      })
    })
  }
})
