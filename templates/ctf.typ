// One CTF: the writeups solved at it. The rows come from the build's own view of
// the content tree, so a new writeup appears here by existing.

#import "@baudelaire/html:0.1.0": h
#import "@baudelaire/pages:0.1.0": pages
#import "/templates/parts.typ": pill, prose

#let ctf(page, body) = prose(page, {
  h("h1", page.frontmatter.title)
  body

  // Everything under this page's own url, minus the page itself.
  let here = pages(page.lang).filter(one => one.url.starts-with(page.url) and one.url != page.url)

  if here.len() == 0 {
    h("p", class: "text-muted-foreground", "No writeups yet.")
  } else {
    h("ul", for entry in here {
      h("li", class: "flex items-center gap-2 md:gap-4 flex-wrap", {
        h("a", href: entry.url, entry.label)
        if entry.at("date", default: none) != none {
          h("span", class: "text-sm text-muted-foreground", entry.display)
        }
        for term in entry.at("taxonomies", default: (:)).at("categories", default: ()) { pill(term) }
      })
    })
  }
})
