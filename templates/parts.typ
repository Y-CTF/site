// The pieces every layout is built from: the bar, the shell, the two columns a
// page is set in, and the row a listing repeats.

#import "@baudelaire/html:0.1.0": classes, h, svg
#import "@baudelaire/site:0.1.0": feeds, feed-url, languages
#import "@baudelaire/pages:0.1.0": pages
#import "@baudelaire/sources:0.1.0": banner, logo

// A UI label, from the language's own table, so a template never spells one.
#let say(page, key, fallback: "") = page.strings.at(key, default: fallback)

// This page's language's front page, and one of the club's own pages in it. The
// pages are translated, so a French reader's link has to land on the French
// edition rather than on the English one with a language switch to press.
#let front(page) = if page.lang == "en" { "/" } else { "/" + page.lang + "/" }
#let at(page, slug) = front(page) + slug + "/"

// The writeups a reader in this language should see.
//
// They are written once, in English, and translating a challenge solution is not
// something anybody is going to do. So a language with none of its own falls back
// to the default rather than showing an empty archive: the alternative is a French
// reader being told the club has never solved anything.
#let solved(lang) = {
  let own = pages(lang).filter(one => one.collection == "writeups")
  if own.len() > 0 { own } else { pages("en").filter(one => one.collection == "writeups") }
}

// What this build was made from, for the colophon: the tag the site is on, or the
// commit when it is not on one. `sys.inputs.baudelaire` is where build metadata
// lives, and baudelaire tracks reads of it page by page.
//
// A shallow checkout has no tags to describe against, which is why the workflow
// fetches the whole history: a footer reading `e4ebdd0` where a release is
// deployed is worse than one reading nothing.
#let stamp() = {
  let git = sys.inputs.at("baudelaire", default: (:)).at("git", default: none)
  if git == none { return none }
  let name = git.at("tag", default: none)
  if name == none {
    let hash = git.at("hash", default: none)
    if hash == none { return none }
    name = hash.slice(0, 7)
  }
  if git.at("dirty", default: false) { name + "+" } else { name }
}

// The logo, linking home. Inlined rather than linked because `invert-colors`
// recolours it with the reader's scheme.
#let mark(page) = h(
  "a",
  href: front(page),
  class: "block h-9 md:h-14 shrink-0 no-underline",
  h(
    "div",
    class: "h-full [&>svg]:h-full [&>svg]:w-auto invert-colors select-none",
    svg(logo),
  ),
)

// The other languages the site is built in.
//
// Every one of them, not only the ones this page was translated into. A writeup
// is written once in English and nobody is going to translate a challenge
// solution, so keying the switch off `page.translations` made it vanish on most
// of the site: a French reader deep in the archive had no way back to French.
// An edition that exists is linked; one that does not falls back to that
// language's front page, which is somewhere rather than nowhere.
#let langs(page) = h(
  "span",
  class: "shrink-0 flex items-center gap-2 font-black text-secondary-foreground",
  {
    for other in languages {
      if other.code != page.lang {
        let editions = page.translations.filter(one => one.lang == other.code)
        let url = if editions.len() > 0 { editions.first().url } else if other.code == "en" { "/" } else {
          "/" + other.code + "/"
        }
        h(
          "a",
          href: url,
          hreflang: other.code,
          class: "no-underline uppercase hover:opacity-70 transition-opacity",
          other.code,
        )
      }
    }
  },
)

// Where a reader can go, on every page rather than only on the front one: what
// the club has solved, what it is doing, who it is, and how to join.
#let links(page) = (
  ("/writeups/", say(page, "writeups", fallback: "Writeups")),
  (at(page, "events"), say(page, "events", fallback: "Events")),
  (at(page, "about"), say(page, "about", fallback: "About")),
)

// The bar across the top. One element holding the whole of it, so the logo, the
// links and the language share a height and a gutter with the column under them
// instead of being placed in the viewport separately. `site-header` is where the
// stylesheet fades a background in once the page has been scrolled: it sits over
// the content, and over words it would otherwise be read through.
#let topbar(page) = h(
  "header",
  class: "site-header fixed top-0 inset-x-0 z-40 border-b border-transparent",
  h(
    "div",
    class: "mx-auto flex h-14 md:h-20 max-w-3xl items-center gap-3 md:gap-5 px-4 sm:px-6",
    {
      mark(page)
      h(
        "nav",
        class: "min-w-0 flex flex-1 items-center justify-end gap-3 md:gap-5 overflow-x-auto text-xs md:text-base",
        {
          for entry in links(page) {
            h(
              "a",
              href: entry.at(0),
              class: "shrink-0 no-underline font-bold hover:text-muted-foreground transition-colors",
              entry.at(1),
            )
          }
          h(
            "a",
            href: at(page, "inscription"),
            class: "shrink-0 no-underline bg-primary text-primary-foreground px-2 py-1 md:px-3 md:py-1.5 font-bold hover:opacity-90 transition-opacity",
            say(page, "inscription", fallback: "Join us"),
          )
          langs(page)
        },
      )
    },
  ),
)

// Who made the site and on what, at the foot of every page. The year is the
// build's, which is what a copyright line means.
// `not-prose`, because the colophon is under an article on one page and under a
// listing on another: inside `prose` the typography plugin sets its own margins
// on these paragraphs, and the two feet of the site were spaced differently.
#let colophon(page) = h("footer", class: "not-prose pt-8 mt-8 border-t border-border text-center space-y-1", {
  h("p", class: "text-xs", say(page, "footer", fallback: "No rights reserved") + " - " + str(
    datetime.today().year(),
  ))
  h("p", class: "text-xs", {
    h("a", href: "https://baudelaire.cstef.dev", "baudelaire")
    " - "
    h("a", class: "underline-offset-2 decoration-2", href: "https://github.com/y-ctf/site", "source")
    let build = stamp()
    if build != none {
      " - "
      h("span", class: "text-muted-foreground", build)
    }
  })
})

// Everything a page sits inside. The top padding clears the bar, which is out of
// flow; the side padding is on the scrolling column and never goes away, because
// a gutter that disappears at one breakpoint is a line of text against the edge
// of the screen at that breakpoint.
#let shell(page, body) = h("div", class: "min-h-[100svh]", {
  h("link", rel: "stylesheet", href: "/assets/css/main.css")
  topbar(page)
  h("main", class: "px-4 sm:px-6 pt-20 md:pt-28 pb-16", body)
})

// The column every page's words are set in. The typography plugin does the rest.
#let prose(page, body) = shell(page, h("article", class: "prose dark:prose-invert mx-auto lg:prose-lg", {
  body
  colophon(page)
}))

// The column a listing is set in. The same measure as `prose` and the same
// colophon under it, without the typographic scale: an archive is a dense table
// of rows, and prose sizing turned forty of them into a page of scrolling.
#let sheet(page, body) = shell(page, h("div", class: "mx-auto w-full max-w-2xl lg:max-w-3xl", {
  body
  colophon(page)
}))

// One category, as the pill a writeup wears. `compact` is the listing's size,
// where the pill sits on a single-line row and the full-size one set the row
// height.
#let pill(term, compact: false) = h(
  "a",
  href: "/categories/" + term + "/",
  class: if compact {
    "bg-accent text-accent-foreground px-1.5 py-0.5 rounded text-[11px] leading-none font-bold no-underline hover:bg-accent/70 transition-colors"
  } else {
    "bg-accent text-accent-foreground px-2 py-1 rounded-md text-sm w-fit font-bold no-underline"
  },
  term,
)

// The one thing a page wants the reader to press.
#let cta(href, label) = h("p", class: "not-prose my-8 text-center", h(
  "a",
  href: href,
  class: "inline-block bg-primary text-primary-foreground px-6 py-3 md:px-8 md:py-4 text-base md:text-lg font-bold no-underline hover:opacity-90 transition-opacity duration-200",
  label,
))

// The page a writeup sits under, which is the competition it was solved at. It is
// the entry whose url is this one's parent, so it comes from the tree rather than
// from anything a writeup has to remember to declare.
//
// It looks the parent up beside the entry rather than in the reader's language:
// a French reader is shown the English writeups, because that is what `solved`
// falls back to, and their competition pages are English too. Asking for the
// French edition of a page nobody translated left every row without its name.
#let event-of(entry) = {
  let parent = entry.url.split("/").slice(0, -2).join("/") + "/"
  let above = pages(entry.lang).filter(one => one.url == parent)
  if above.len() > 0 { above.first() } else { none }
}

// One solved challenge, wherever it is listed: the front page, the archive, a
// competition, a category, the paginated listing. All five listed the same rows
// in five slightly different ways before, and each had to be made to fit a phone
// on its own.
//
// Every row is one line, because a list of solved challenges is looked down
// rather than read. The date is the ISO one rather than the spelled-out
// `display`, because a column of them only lines up if every entry is the same
// width. `event` is what the front page adds and a competition's own page would
// only repeat.
#let row(entry, event: true) = h(
  "li",
  class: "grid grid-cols-[minmax(0,1fr)_auto] items-baseline gap-x-3 px-2 -mx-2 py-1.5 rounded hover:bg-accent/40 transition-colors",
  {
    h("span", class: "min-w-0 flex items-baseline gap-2", {
      // Dropped on a narrow screen, where the challenge's own name is the row.
      let ctf = if event { event-of(entry) } else { none }
      if ctf != none {
        h(
          "a",
          href: ctf.url,
          class: "hidden sm:block shrink-0 text-xs text-muted-foreground no-underline hover:text-foreground transition-colors",
          ctf.label,
        )
      }
      h(
        "a",
        href: entry.url,
        class: "min-w-0 truncate font-medium no-underline hover:underline underline-offset-2 decoration-2",
        entry.label,
      )
    })

    h("span", class: "flex items-center gap-2 shrink-0", {
      // The first category only: the row is one line and a writeup may carry several.
      let terms = entry.at("taxonomies", default: (:)).at("categories", default: ())
      if terms.len() > 0 { pill(terms.first(), compact: true) }
      if entry.at("date", default: none) != none {
        h("time", datetime: entry.date, class: "text-xs text-muted-foreground tabular-nums", entry.date)
      }
    })
  },
)

// A list of them, with the hairline between rows that makes it a table.
#let rows(entries, event: true) = h(
  "ul",
  class: "divide-y divide-border/60",
  for entry in entries { row(entry, event: event) },
)

// The banner over the home page, inlined for the same reason as the logo.
#let hero() = h(
  "div",
  class: "h-32 sm:h-48 md:h-64 p-2 md:p-4 w-full flex items-center justify-center invert-colors select-none",
  svg(banner),
)

// The two buttons under the home page's list. One feed, not one per format: the
// old site offered a single subscribe button and the head already advertises both
// to anything that reads them.
#let button(href, label) = h(
  "a",
  href: href,
  class: "no-underline bg-accent px-3 py-1 md:py-2 h-fit whitespace-nowrap hover:bg-primary/90 transition-colors duration-200",
  h("span", class: "text-muted-foreground text-sm sm:text-base", label),
)

#let subscribe(page) = h(
  "div",
  class: "flex flex-wrap gap-4 sm:gap-6 items-center justify-center mt-8 md:mt-12",
  {
    let atom = feeds.filter(one => one.format == "atom")
    let first = if atom.len() > 0 { atom.first() } else if feeds.len() > 0 { feeds.first() } else { none }
    if first != none {
      let url = feed-url(first, page.lang)
      if url != none { button(url, say(page, "rss-feed", fallback: "Subscribe")) }
    }
    button("/writeups/", say(page, "archive", fallback: "Archive"))
  },
)
