// The club's events.
//
// They are not written here. `club.yctf.ch` is where a committee adds an event,
// and this page shows what it holds: one owner, and a calendar that cannot be
// out of date. The site is static, so `static/js/events.js` reads the club's
// public endpoint in the reader's browser and sets the rows in this site's own
// type. Without a script there is a link to the calendar instead.

#import "@baudelaire/html:0.1.0": h
#import "/templates/parts.typ": cta, prose, say

#let CLUB = "https://club.yctf.ch"
#let events(page, body) = prose(page, {
  h("h1", page.frontmatter.title)
  body

  h(
    "section",
    class: "not-prose my-8",
    {
      h(
        "h2",
        class: "text-lg font-bold mb-2",
        say(page, "upcoming-events", fallback: "Upcoming events"),
      )
      h(
        "div",
        data-events: "",
        data-api: CLUB + "/api/public/events",
        data-none: say(page, "no-upcoming-events", fallback: "No upcoming events"),
        data-failed: say(page, "events-unavailable", fallback: "The calendar could not be loaded."),
        data-until: say(page, "until", fallback: "until"),
        aria-live: "polite",
        class: "min-h-24",
        h("noscript", h(
          "a",
          href: CLUB,
          class: "underline underline-offset-2 decoration-2",
          say(page, "upcoming-events", fallback: "Upcoming events"),
        )),
      )
    },
  )
  h("script", src: "/js/events.js", defer: true)

  cta(CLUB + "/join", say(page, "inscription", fallback: "Join us"))
})
