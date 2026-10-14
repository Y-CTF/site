// One CTF: the writeups solved at it. The rows come from the build's own view of
// the content tree, so a new writeup appears here by existing.

#import "@baudelaire/html:0.1.0": h
#import "@baudelaire/pages:0.1.0": pages
#import "/templates/parts.typ": prose, rows, say

#let ctf(page, body) = prose(page, {
  h("h1", page.frontmatter.title)
  body

  // Everything under this page's own url, minus the page itself. The competition
  // is the page, so the rows do not repeat its name back.
  let here = pages(page.lang).filter(one => one.url.starts-with(page.url) and one.url != page.url)

  if here.len() == 0 {
    h("p", class: "text-muted-foreground", say(page, "nothing-here", fallback: "No writeups yet."))
  } else {
    h("div", class: "not-prose", rows(here, event: false))
  }
})
