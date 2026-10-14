// The front page: the banner, who the club is, and what was solved most recently.
//
// Where to go is the bar's job now. It used to be a line of dot-separated links
// here, which meant the front page was the only page with any navigation on it.

#import "@baudelaire/html:0.1.0": h
#import "/templates/parts.typ": hero, prose, rows, say, solved, subscribe

// How many writeups the front page carries before it becomes an archive.
#let RECENT = 5

#let home(page, body) = prose(page, {
  hero()

  h("p", say(page, "hero"))

  body

  h("h2", say(page, "latest-writeups"))

  let recent = solved(page.lang)
  h("div", class: "not-prose", rows(recent.slice(0, calc.min(RECENT, recent.len()))))

  subscribe(page)
})
