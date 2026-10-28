# UI branch

## When to use

- "What should this page look like?"
- "I want to see a few options for this screen before deciding."
- "Try a different layout for this view."
- Any situation where the user would otherwise spend time choosing between three vague options in their head.

## Two sub-forms — strongly prefer sub-form A

A UI prototype is much easier to judge when it **sits against the rest of the app** — real header, real navigation, real data, real density. An isolated throwaway route is a vacuum: every variant looks good on its own. Prefer sub-form A whenever there is a plausible existing page to host the variants. Use sub-form B only if the prototype genuinely has nowhere to live.

**Sub-form A — tweak an existing page (preferred)**

The route already exists. The variants render **on the same route**, controlled by a `?variant=` search param. The existing data fetching, params and auth stay as they are — only what gets rendered changes. This is the default; pick it unless there's a specific reason not to.

If the prototype is for something that doesn't have a page yet but *would naturally live inside one* (a new section on the history screen, a new card in the settings screen, a new step in an existing flow) — it's still sub-form A. Mount the variants inside the host page.

**Sub-form B — new page (last resort)**

Use only when what's being prototyped genuinely has no existing page to live in — e.g. a brand-new top-level surface, or a flow that can't reasonably be embedded anywhere.

Create a **throwaway route** following the project's routing convention — don't invent new top-level structure. Name it so it's obvious it's a prototype (e.g. include the word `prototype` in the path or file name). Same `?variant=` pattern.

Before settling on sub-form B, check: is there really no existing page where this could be embedded? An empty route hides design problems that a populated one would expose.

In both sub-forms the floating switcher bar is identical.

## U1 — State the question and pick N

Default to **3 variants**. More than 5 stops being radically different and turns into noise — cap it there.

Write the plan in one line, in a comment at the top of the file or in the prototype folder:

> "Three variants of the routine editor, switchable via `?variant=`, on the existing `/routines/:id` route."

This works whether or not the user is around to push back.

## U2 — Identify the repository's stack

Before writing any code, identify the stack of the repository being prototyped from its `CLAUDE.md` and `package.json`:

| Stack | Where in this workspace | Routing | Dev server |
|---|---|---|---|
| React 19 + Vite + Tailwind + TypeScript | `gym-app` (PWA in the browser); `newcord` desktop renderer (Electron) | The router listed in `package.json` (e.g. React Router's `useSearchParams`). No router → read/write `window.location.search` with `URLSearchParams` + `history.replaceState` | The repo's `dev` script (Vite defaults to port 5173) |
| Angular + TypeScript | None today — kept for future Angular repos | Angular Router (`ActivatedRoute`, `Router.navigate`) | `ng serve` (default port 4200) |

If the repository isn't covered here, identify its stack from `package.json` before continuing.

**Electron renderer:** there's no address bar, so the floating bar is the only way to switch and the URL can't be shared — but the variant still lives in the renderer URL's search params (or hash, if the app uses a hash router), so a renderer reload keeps it. Run the desktop app through its usual dev script so the variants render inside the real window chrome. In sub-form B, the throwaway route must be registered in the renderer's router.

## U3 — Generate radically different variants

Sketch each variant. Each one must respect:

- The page's purpose and the data it has access to.
- The project's component and styling system — Tailwind utility classes plus whatever component library the repo already uses (see `{root}/.claude/docs/knowledge/ui-ux-patterns.md`). Don't pull in a new UI library for a prototype.
- TypeScript in every case — no plain JavaScript.
- A clear exported component name: `VariantA`, `VariantB`, `VariantC`.

The variants must be **structurally different** — different layout, different information hierarchy, different primary affordance. Not just swapped colors or copy. Three slightly tweaked card grids aren't a UI prototype, they're wallpaper. If two drafts come out too similar, redo one with the explicit instruction "don't use a card grid".

## U4 — Mount the switcher

**React:**

```tsx
// pseudo-code — adapt to the project
const [searchParams, setSearchParams] = useSearchParams();
const variant = searchParams.get('variant') ?? 'A';

return (
  <>
    {variant === 'A' && <VariantA {...data} />}
    {variant === 'B' && <VariantB {...data} />}
    {variant === 'C' && <VariantC {...data} />}
    <PrototypeSwitcher variants={['A', 'B', 'C']} current={variant} onChange={(v) => setSearchParams({ variant: v })} />
  </>
);
```

Without a router, replace `useSearchParams` with a small piece of state initialized from `new URLSearchParams(window.location.search)` and written back with `history.replaceState`.

**Angular:**

```typescript
// pseudo-code — adapt to the project
// In the host component:
variant = this.route.snapshot.queryParams['variant'] ?? 'A';

setVariant(v: string) {
  this.router.navigate([], { queryParams: { variant: v }, queryParamsHandling: 'merge' });
}
```

```html
<!-- In the host template: -->
@if (variant === 'A') { <app-variant-a /> }
@if (variant === 'B') { <app-variant-b /> }
@if (variant === 'C') { <app-variant-c /> }
<app-prototype-switcher [variants]="['A', 'B', 'C']" [current]="variant" (change)="setVariant($event)" />
```

Sub-form A: keep all data fetching above the switcher; only the rendered subtree changes per variant.

Sub-form B: the throwaway route at `prototype/<name>` mounts the same switcher.

## U5 — Build the floating bar

A small bar fixed at the bottom center of the screen, with three parts:

- **Left arrow** — cycles to the previous variant (wraps around at the end).
- **Variant label** — shows the current key and, if the variant exports a name, that too. E.g. `B — Side panel layout`.
- **Right arrow** — cycles forward (wraps around at the end).

Behavior:
- Clicking an arrow updates the search param through the framework's router — the param survives a reload and can be shared by URL (in the browser).
- Keyboard: `←` and `→` also cycle. Don't intercept the arrows while an `<input>`, `<textarea>` or `[contenteditable]` is focused.
- Visually distinct from the page (e.g. high-contrast pill, subtle shadow) — it must be obvious it isn't part of the design being evaluated.
- **Hidden in production:** React/Vite — gate on `import.meta.env.DEV`; if the repo ever produces a dev bundle via `vite build --mode development` (where `DEV` is `false`), gate on `import.meta.env.MODE === 'development'` instead. Angular — gate on `!environment.production`.

Put the switcher in a single shared component so both sub-forms can reuse it. Place it wherever shared components live in the project.

## U6 — Hand it to the user

Give the user the URL (or, in the Electron renderer, the run command and the screen to open) and the `?variant=` keys. They'll browse when it suits them. The interesting feedback is usually **"I want B's header with C's navigation"** — that's the real design they're after.

## U7 — Capture the answer

Once the prototype has done its job, go to the [Closing step](SKILL.md#closing-step--capture-the-answer-and-clean-up) in `SKILL.md`.

## Anti-patterns

- **Don't create variants that differ only in color or copy.** That's tweaking, not prototyping. Real variants disagree about structure.
- **Don't share too much between variants.** A shared `<Header>` is fine; a shared `<Layout>` defeats the purpose. Each variant must be free to throw out the layout.
- **Don't promote the prototype straight to production.** Variant code was written under prototype constraints — no tests, minimal error handling. Rewrite it properly when folding it in.
