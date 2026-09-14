// The pieces every layout is built from: the shell, the prose wrapper, and the
// two rows a writeup carries. Kept at the project root rather than under
// `templates/`, because only `templates/` is bound by name and this is shared.

#import "@baudelaire/html:0.1.0": classes, h, svg
#import "@baudelaire/site:0.1.0": feeds, feed-url
#import "@baudelaire/pages:0.1.0": pages
#import "@baudelaire/sources:0.1.0": banner, logo

// A UI label, from the language's own table, so a template never spells one.
#let say(page, key, fallback: "") = page.strings.at(key, default: fallback)

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

// The logo, fixed top left, linking home. Inlined rather than linked because
// `invert-colors` recolours it with the reader's scheme.
#let mark(page) = h(
  "a",
  href: if page.lang == "en" { "/" } else { "/" + page.lang + "/" },
  class: "top-0 left-0 fixed",
  h(
    "div",
    class: "h-18 md:h-26 lg:h-32 p-2 md:p-4",
    h(
      "div",
      class: "w-full h-full flex items-center justify-center",
      h(
        "div",
        class: "w-full h-full [&>svg]:w-full [&>svg]:h-full [&>svg]:object-contain invert-colors select-none",
        svg(logo),
      ),
    ),
  ),
)

// The other editions of this page, top right. `page.translations` only holds
// the ones that exist, so a page nobody translated shows nothing.
#let langs(page) = h(
  "div",
  class: "text-secondary-foreground mx-6 md:py-2 py-1 font-black text-lg lg:text-xl top-0 right-0 "
    + "fixed w-18 md:w-26 h-18 md:h-26 lg:h-32 p-2 md:p-4 text-center flex items-center justify-center",
  {
    for edition in page.translations {
      if edition.lang != page.lang {
        h("a", href: edition.url, hreflang: edition.lang, class: "no-underline w-full", edition.lang)
      }
    }
  },
)

// Everything a page sits inside.
//
// One element, not three: loose content at the top of a page is a paragraph as
// far as Typst is concerned, and the mark would have come out inside a `<p>`.
// The stylesheet is linked here rather than from a head this template does not
// own, which is where a theme puts it too.
#let shell(page, body) = h("div", class: "min-h-[100svh]", {
  h("link", rel: "stylesheet", href: "/assets/css/main.css")
  mark(page)
  langs(page)
  h("main", id: "scroll-element", h("div", class: "mt-24 mx-4 mb-24 sm:mx-0", body))
})

// Who made the site and on what, at the foot of every page. The year is the
// build's, which is what a copyright line means.
#let colophon(page) = h("footer", class: "pt-8 text-center", {
  h("p", class: "text-xs", say(page, "footer", fallback: "No rights reserved") + " - " + str(
    datetime.today().year(),
  ))
  h("p", class: "text-xs", {
    h("a", href: "https://baudelaire.cstef.dev", "baudelaire")
    " - "
    h("a", class: "underline-offset-2 decoration-2", href: "https://github.com/y-ctf/site", "source")
  })
})

// The column every page's words are set in. The typography plugin does the rest.
#let prose(page, body) = shell(page, h("article", class: "prose dark:prose-invert mx-auto lg:prose-lg", {
  body
  colophon(page)
}))

// One category, as the pill a writeup wears.
#let pill(term) = h(
  "a",
  href: "/categories/" + term + "/",
  class: "bg-accent text-accent-foreground px-2 py-1 rounded-md text-sm w-fit font-bold no-underline",
  term,
)

// The banner over the home page, inlined for the same reason as the logo.
#let hero() = h(
  "div",
  class: "h-48 md:h-64 p-2 md:p-4 w-full flex items-center justify-center invert-colors select-none",
  svg(banner),
)

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

// The two buttons under the home page's list. One feed, not one per format: the
// old site offered a single subscribe button and the head already advertises both
// to anything that reads them.
#let button(href, label) = h(
  "a",
  href: href,
  class: "no-underline bg-accent px-3 py-1 md:py-2 h-fit whitespace-nowrap "
    + "hover:bg-primary/90 transition-colors duration-200",
  h("span", class: "text-muted-foreground text-sm sm:text-base", label),
)

#let subscribe(page) = h(
  "div",
  class: "flex gap-4 sm:gap-6 items-center justify-center mt-8 md:mt-12",
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
