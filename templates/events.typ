// The club's events.
//
// They are not written here any more. `club.yctf.ch` is where a committee adds
// an event, and this page shows what it holds: one owner, and a calendar that
// cannot be out of date because somebody forgot to edit a TOML file. The frame
// is the club's own widget, which carries no script and is allowed to be framed
// by this site and no other.

#import "@baudelaire/html:0.1.0": h
#import "/templates/parts.typ": prose, say

#let CLUB = "https://club.yctf.ch"
// Tall enough for the five events the widget shows, on a phone.
#let HEIGHT = "420"

#let events(page, body) = prose(page, {
  h("h1", page.frontmatter.title)
  body

  h(
    "iframe",
    src: CLUB + "/api/embed/events",
    title: say(page, "upcoming-events", fallback: "Upcoming events"),
    height: HEIGHT,
    loading: "lazy",
    class: "w-full border-0 not-prose",
  )

  h("p", h("a", href: CLUB + "/join", say(page, "inscription", fallback: "Join us")))
})
