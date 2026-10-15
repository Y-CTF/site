// Fills the events list from the club app's public endpoint.
//
// The site is static, so the list is read in the reader's browser: it is never
// older than the club's own calendar, and nobody has to rebuild the site when
// a committee adds an event. The strings come from the page (`data-*`), so the
// translations stay in config.kdl.

const root = document.querySelector("[data-events]");

if (root) {
	const { api, none, failed, until } = root.dataset;
	const lang = document.documentElement.lang || "en";
	// The club is in Vaud. Without this, a reader abroad sees the hours shifted.
	const zone = "Europe/Zurich";
	const day = new Intl.DateTimeFormat(lang, { timeZone: zone, weekday: "short", day: "numeric", month: "short" });
	const dayLong = new Intl.DateTimeFormat(lang, { timeZone: zone, day: "numeric", month: "short", year: "numeric" });
	const hour = new Intl.DateTimeFormat(lang, { timeZone: zone, hour: "2-digit", minute: "2-digit" });

	const el = (tag, cls, text) => {
		const node = document.createElement(tag);
		if (cls) node.className = cls;
		if (text) node.textContent = text;
		return node;
	};

	const sameDay = (a, b) => dayLong.format(a) === dayLong.format(b);

	const row = (event) => {
		const start = new Date(event.startsAt);
		const end = event.endsAt ? new Date(event.endsAt) : null;
		// An end before the start is a typo in the calendar, not a reason to print it.
		const span = end && end > start;

		const item = el("li", "grid grid-cols-[5.5rem_minmax(0,1fr)] gap-x-4 gap-y-1 py-3 border-t border-border first:border-t-0");

		const when = el("time", "text-sm tabular-nums text-muted-foreground");
		when.dateTime = event.startsAt;
		when.append(el("span", "block font-bold text-foreground", day.format(start)));
		when.append(el("span", "block", hour.format(start)));
		item.append(when);

		const body = el("div", "min-w-0 space-y-1");
		const head = el("div", "flex flex-wrap items-baseline gap-x-2");
		head.append(el("span", "font-bold", event.title));
		if (event.kind) head.append(el("span", "bg-accent text-accent-foreground px-1.5 py-0.5 rounded text-[11px] leading-none font-bold", event.kind));
		body.append(head);

		if (event.location) body.append(el("div", "text-sm text-muted-foreground", event.location));
		if (span && !sameDay(start, end)) body.append(el("div", "text-sm text-muted-foreground", `${until} ${dayLong.format(end)}`));

		const note = event.description;
		if (note && /^https?:\/\/\S+$/.test(note)) {
			const link = el("a", "text-sm underline underline-offset-2 decoration-2 break-all", note.replace(/^https?:\/\//, ""));
			link.href = note;
			link.rel = "noopener";
			body.append(link);
		} else if (note) {
			body.append(el("div", "text-sm", note));
		}

		item.append(body);
		return item;
	};

	const show = (node) => root.replaceChildren(node);

	fetch(api, { headers: { accept: "application/json" } })
		.then((response) => {
			if (!response.ok) throw new Error(String(response.status));
			return response.json();
		})
		.then(({ events }) => {
			if (!events.length) return show(el("p", "text-muted-foreground", none));
			const list = el("ul", "list-none m-0 p-0");
			list.append(...events.map(row));
			show(list);
		})
		.catch(() => show(el("p", "text-muted-foreground", failed)));
}
