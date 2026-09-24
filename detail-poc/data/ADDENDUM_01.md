# Addendum 01 — Products and Checkout

Supplements `HANDOFF.md`. `object-map.json` and `cta-matrix.json` were regenerated and supersede
the versions loaded for the original 26-object build.

| | was | now |
|---|---|---|
| Objects | 26 | **34** |
| CTAs | 265 | **355** |
| DETAIL: never-by-design | 15 | **33** |

Nothing was removed and nothing was renamed. Eight new objects, plus new nesties on existing
ones.

## Part 1 — Products (4 new objects)

Modelled against Boulevard's live product documentation. Two source articles:
[Products and Inventory](https://support.boulevard.io/en/articles/5941416-products-and-inventory)
and [Tracking and charging for products used during
services](https://support.boulevard.io/en/articles/5941350-tracking-and-charging-for-products-used-during-services).

### PRODUCT — one object, not two

Two independent booleans: `Sellable as Retail?` (only products whose `Category` is "Retail"
appear at checkout) and `Usable in a Service?`. A Botox vial is typically both. `Default Unit
Cost` depletes first-in first-out; `Active at Location?` is off by default on create; `△ Expiry`
is not tracked by Boulevard today.

### PRODUCT USAGE RULE — junction on SERVICE × PRODUCT

`Price Per Item` and `Default Quantity` belong to the relationship, not either object.
`Default Quantity` drives the self-booking overlay price, which booking deposits and
cancellation fees are calculated from — not cosmetic.

### PRODUCT USAGE — junction on APPOINTMENT × PRODUCT

`Quantity Expected` (set at booking, editable) vs. `Quantity Used` (actual) — the difference
resolves at checkout. Tax, gratuity and commission calculate on the service total *after* usage
is folded in.

### PRODUCT CREDIT — prepaid units

Balance lives in the client's Wallet. Refunding an order deducts the balance; refunding a
redemption returns units. Treat the balance as a liability.

## Part 2 — Checkout (4 new objects)

Added because five things already in the model dangled without it: `DAY.Collected` had no
source, `PRODUCT USAGE.Amount Charged` had nowhere to resolve, `PRODUCT CREDIT` had no purchase
event, "charge a fee" / "waive a fee" on `CLIENT` had nothing to charge against, and "connect
payouts" activated nothing.

- **ORDER** — the transaction. Opens at check-in, closes on payment. `has 0-1 CLIENT` (a
  retail-only walk-in has no client record).
- **ORDER LINE ITEM** — a discriminated union: `Kind` is service / retail product / prepaid
  units / fee, exactly one corresponding FK set — enforce the discriminant, don't model five
  nullable columns. `Unit Price at Sale` is a snapshot, not a live lookup.
- **PAYMENT** — separate from ORDER because one order can take several tenders. `Status`
  includes `declined`, the one payment state that produces a cue.
- **PAYOUT** — money leaving Boulevard for her bank. Different from a client paying her. This is
  what the `connect payouts` CAPABILITY now actually unlocks.

## What this changes for DETAIL

New signal sources: product depletion, low stock, usage variance, payment succeeded, **payment
declined**, order left unclosed, payout initiated, payout failed. Most are suppressed —
volume is the point.

**The ones that earn a cue:** payment declined while the client is still in the room; an
unclosed order at end of day; a prepaid balance at checkout (silent surfacing, not spoken); low
stock on her schedule — *"neurotoxin, 2 vials, covers Thursday, reorder Friday"* — the cue
**waits for Friday** because a threshold says so (not today's simulation).

**New PATTERN/PROPOSAL material:** usage variance, cost drift, retail attach (`Recommend at
checkout` is `◐ ask first`, not silent).

**Eighteen new nevers**, not all money: take/retry/refund a payment, void, close an order, apply
an order discount, adjust a line price, change retail price, place a purchase order, change the
payout destination, initiate a payout, redeem prepaid units without asking, sell prepaid units,
discount to fill a gap. Two are disclosure rules, same family as the clinical ones:
`○ Disclose unit counts to the client` (clients see the total charged, never the units used) and
`○ Change price per item` on a usage rule.

## Seed data additions

Two products (Botox vial, usable-in-service only; retail serum, retail-only); a usage rule
tying neurotoxin to the vial; Maya's 11:00 consuming units (expected vs. used differing, so
variance runs); a PRODUCT CREDIT for one client, partially redeemed; closed orders for all seven
appointments summing to `$3,180`; one declined payment that succeeds on a second tender; one
order left unclosed; a payout initiated at 2:10 PM, arriving Thursday.

## Two things to flag back, not fix

**Boulevard cannot track product expiry**, but CHART ENTRY's `Products & Lots` carries an
expiry in its own example — clinical documentation is a separate requirement from inventory
management. Both are correct as modelled; it's a real gap between what a medspa must record and
what the platform holds.

**Usage-based pricing is Premier/Enterprise only** — a CAPABILITY instance, not a given. Seeded
`active` so the usage path runs, but the gate is real.

## Still open (plus one)

Everything in `HANDOFF.md`'s "Known open items" still stands, plus: **INVENTORY ADJUSTMENT** is
probably a ninth object, deliberately deferred — Boulevard keeps a historical record of every
change on a product (Received Stock, Usage, Re-count, Damage, Theft, Loss, Return) and the
model currently has `PRODUCT.Quantity on Hand` with no audit trail behind it.
