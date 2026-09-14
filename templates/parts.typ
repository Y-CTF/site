// The pieces every layout is built from: the shell, the prose wrapper, and the
// two rows a writeup carries. Kept at the project root rather than under
// `templates/`, because only `templates/` is bound by name and this is shared.

#import "@baudelaire/html:0.1.0": classes, h, svg
#import "@baudelaire/site:0.1.0": feeds, feed-url
#import "@baudelaire/sources:0.1.0": banner, logo

// A UI label, from the language's own table, so a template never spells one.
#let say(page, key, fallback: "") = page.strings.at(key, default: fallback)

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

// The column every page's words are set in. The typography plugin does the rest.
#let prose(page, body) = shell(page, h("article", class: "prose dark:prose-invert mx-auto lg:prose-lg", body))

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

// The feed buttons under the home page's list. The feeds are asked for rather
// than named, so a format turned off in config does not leave a dead link.
#let button(href, label) = h(
  "a",
  href: href,
  class: "no-underline bg-accent px-3 py-1 md:py-2 h-fit hover:bg-primary/90 transition-colors duration-200",
  h("span", class: "text-muted-foreground text-sm sm:text-base", label),
)

#let subscribe(page) = h(
  "div",
  class: "flex gap-4 sm:gap-6 items-center justify-center mt-8 md:mt-12",
  {
    for feed in feeds {
      let url = feed-url(feed, page.lang)
      if url != none {
        button(url, say(page, "rss-feed", fallback: "Subscribe") + " (" + upper(feed.format) + ")")
      }
    }
    button("/writeups/", say(page, "archive", fallback: "Archive"))
  },
)
