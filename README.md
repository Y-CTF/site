<p align="center">
    <img src="static/images/banner-red.svg" alt="Y-CTF" height="200">
</p>

---

Source code of the [yctf.ch](https://yctf.ch) website, built with [baudelaire](https://baudelaire.cstef.dev).

## Writing Content

The file structure is as follows:

```
content/
├── pages/
│   └── ...
└── writeups/
    ├── <ctf-name>/
    │   └── <challenge-name>/
    │       ├── index.md
    │       └── files/
    │           ├── <files>
    │           └── ...
    └── ...
```

### Pages

Mostly static pages like the home page, about page, etc. are stored in the `content/pages/` directory.

### Writeups

Writeups are stored in the `content/writeups/` directory. Each CTF has its own directory, and each challenge has its own directory within that. The `index.md` file contains the writeup, and any files associated with the challenge are stored in the `files/` directory.

#### Frontmatter

The frontmatter of a writeup is in TOML format and looks like this:

```toml
+++
title = "Challenge Name"
date = 2021-01-01
description = "Description of the challenge" # Optional
authors = ["Author 1", "Author 2"] # Optional
categories = ["pwn"]
+++
```

### Markdown

Standard markdown, plus [`typst`](https://typst.app) math:

```markdown
$$
lim_(x->oo) (1 + 1/x)^x = e
$$
```

Templates in `templates/` are Typst too, and the site is configured in `config.kdl`.

## Development

1. Clone the repository

```bash
git clone https://github.com/Y-CTF/site.git
cd site
```

2. Install baudelaire ([`cargo-binstall`](https://github.com/cargo-bins/cargo-binstall) or [`cargo`](https://rustup.rs))

```bash
cargo binstall baudelaire
# or from source
cargo install baudelaire
```

<small>You can also download a pre-built binary from the [releases page](https://github.com/cestef/baudelaire/releases).</small>

3. Install dependencies ([`pnpm`](https://pnpm.io))

```bash
pnpm install
```

4. Start the development server

```bash
pnpm dev
```

Styles are Tailwind v4, compiled by the `before` hook in `config.kdl` on every build. To rebuild them on change while editing `styles/`, run `pnpm css:dev` alongside.

## Deployment

Every push to `main` builds the site and publishes it to GitHub Pages, from `.github/workflows/deploy.yml`.
