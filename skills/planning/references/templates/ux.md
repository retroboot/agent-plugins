# UX

_`ui` modifier at size M and larger; linked from `design.md` **Modifier: ui**. At size S these six
parts go in that modifier section of the README instead. Guidance for every part:
`skills/planning/references/ux-checklist.md`. High-fidelity mockups are linked, never embedded._

## 1. Screen inventory

| Screen | Purpose | Entry points | New or changed |
|---|---|---|---|
| <screen> | <what the user does here> | <how they arrive> | <new \| changed> |

## 2. Navigation flow

_Guidance: a Mermaid `flowchart` with one node per screen and one edge per transition, labelled with
the action that causes it._

## 3. Wireframes

_Guidance: one `text` fence per screen, showing regions, their order of visual priority and the
primary action. Layout only: no markup and no styling code._

### <Screen>

## 4. States

_Guidance: one table per screen. Every cell is specified; "No items found." alone is never
acceptable._

### <Screen>

| State | What the user sees | Action offered |
|---|---|---|
| Loading | <skeleton or indicator> | <none or cancel> |
| Empty | <message and context> | <primary action> |
| Error | <human-readable message> | <recovery action> |
| Success | <result> | <next action> |
| Partial | <what has loaded> | <load more or retry> |

## 5. Responsive behaviour

| Screen | Desktop (≥1024px) | Tablet (768–1023px) | Mobile (<768px) |
|---|---|---|---|
| <screen> | <layout> | <layout> | <layout> |

## 6. Accessibility

| Screen or component | Keyboard | Screen reader | Contrast | Touch |
|---|---|---|---|---|
| <component> | <tab order, shortcuts> | <roles, labels> | <ratio> | <hit target> |

## Mockups

_Optional. Guidance: links only, for example a design-tool URL. Delete when there are none._
