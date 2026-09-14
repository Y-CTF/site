// Joining the club.
//
// One page with one thing to do on it, so the button is the page rather than a
// link buried in a paragraph. What the club is and who may join is prose; what
// happens after pressing it is the club app's business and is written here,
// because it is the same sentence in every language and the page should not have
// to repeat it.

#import "@baudelaire/html:0.1.0": h
#import "/templates/parts.typ": prose, say

#let CLUB = "https://club.yctf.ch"

#let join(page, body) = prose(page, {
  h("h1", page.frontmatter.title)
  body

  h("p", class: "not-prose my-8 text-center", h(
    "a",
    href: CLUB + "/join",
    class: "inline-block bg-primary text-primary-foreground px-8 py-4 text-lg font-bold "
      + "no-underline hover:opacity-90 transition-opacity duration-200",
    say(page, "inscription", fallback: "Join us"),
  ))

  h("p", class: "text-center text-sm text-muted-foreground", say(page, "join-note"))
})
