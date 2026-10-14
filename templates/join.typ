// Joining the club.
//
// One page with one thing to do on it, so the button is the page rather than a
// link buried in a paragraph. What the club is and who may join is prose; what
// happens after pressing it is the club app's business and is left to it.

#import "@baudelaire/html:0.1.0": h
#import "/templates/parts.typ": cta, prose, say

#let CLUB = "https://club.yctf.ch"

#let join(page, body) = prose(page, {
  h("h1", page.frontmatter.title)
  body

  cta(CLUB + "/join", say(page, "inscription", fallback: "Join us"))
})
