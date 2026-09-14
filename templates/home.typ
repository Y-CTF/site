// The front page: the banner, who the club is, where to go, and what was solved
// most recently.

#import "@baudelaire/html:0.1.0": h
#import "/templates/parts.typ": event-of, hero, pill, prose, say, solved, subscribe

// How many writeups the front page carries before it becomes an archive.
#let RECENT = 5

#let home(page, body) = prose(page, {
  hero()

  h("p", say(page, "hero"))

  // The club's own pages, as one line. `/fr/...` for a French reader, because
  // the pages are translated and the link should land on the right edition.
  let at(slug) = if page.lang == "en" { "/" + slug + "/" } else { "/" + page.lang + "/" + slug + "/" }
  h("p", class: "text-center", {
    let entries = (
      (at("about"), say(page, "about")),
      (at("events"), say(page, "events")),
      (at("inscription"), say(page, "inscription")),
      ("mailto:y-ctf@heig-vd.ch", say(page, "contact")),
      (at("committee"), say(page, "commitee")),
    )
    for (index, entry) in entries.enumerate() {
      if index > 0 { " · " }
      h("a", class: "font-bold", href: entry.at(0), entry.at(1))
    }
  })

  body

  h("h2", say(page, "latest-writeups"))

  let recent = solved(page.lang)
  h("ul", for entry in recent.slice(0, calc.min(RECENT, recent.len())) {
    h("li", h("h3", class: "flex items-center gap-2 md:gap-4 !mt-4 !text-xl", {
      // Which competition it was, from the page above it in the tree.
      let ctf = event-of(entry)
      if ctf != none {
        h("span", class: "font-normal hidden sm:block", h(
          "a",
          href: ctf.url,
          class: "no-underline text-muted-foreground",
          ctf.label + ":",
        ))
      }
      h("a", href: entry.url, class: "underline-offset-2 decoration-2 flex-grow", entry.label)
      // A fixed column, so the dates line up down the page instead of tracking
      // the length of each title.
      h("div", class: "flex flex-col items-end justify-center gap-y-2 shrink-0 w-36", {
        if entry.at("date", default: none) != none {
          h("span", class: "text-sm text-muted-foreground", entry.date)
        }
        // The first category only: the row is one line and a writeup may carry several.
        let terms = entry.at("taxonomies", default: (:)).at("categories", default: ())
        if terms.len() > 0 { pill(terms.first()) }
      })
    }))
  })

  subscribe(page)
})
