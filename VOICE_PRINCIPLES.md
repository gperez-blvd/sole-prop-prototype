# VOICE_PRINCIPLES.md — how DETAIL is meant to sound and behave, hands-free

This file is hand-maintained, not generated. It's the record of a product-strategy
conversation about proactive voice — not a bug that got fixed, a direction that got decided.
`ENGINEERING_LESSONS.md` is for mistakes made while building; this is for principles agreed
before building, so the next session (or the Android build, or a future hardware integration)
doesn't have to re-litigate them from scratch. Treat every "Decided" below as a real constraint
on future work, not a suggestion — and update this file the next time a voice-interaction
decision gets made, the same discipline `ENGINEERING_LESSONS.md` asks for its own entries.

---

## The core bet: this is a phone app, not a wearable, and that's fine

**Decided:** no custom hardware (a ring, a wearable, a dedicated device). The original pitch for
this — "an Oura-style two-experience product" — doesn't actually hold up on inspection: Oura's
two experiences are a ring with *no screen at all* (true zero-friction, hardware-level) and a
phone app, not two UI personalities on the same screen. Cue has no ring-equivalent. Whatever
"hands-free" means here, it has to be solved without assuming a second device exists.

**Why this matters going forward:** don't reach for "what if there were a wearable" as the
answer to a hands-free gap. The honest constraint is phone-only, and every principle below is
written to hold under that constraint.

---

## There is no "conversation mode" vs. "dashboard mode"

**Decided:** this app does not have two rival experiences a provider allocates her day between.
It has one app with a four-tier disclosure system (see CLAUDE.md: Spoken → Glanceable → Full →
Behind) and a voice-conversation screen reached by navigating to it, the same way Wallet or
Clients are reached by navigating to them. That screen is not a parallel personality for the
app — it's one more altitude of the same disclosure ladder.

**Why "mode" is the wrong word, even informally:** a mode implies a thing you have to remember
you're "in," with its own state that can drift out of sync with the other mode. That's a real,
well-documented failure pattern in dual-surface products (Facebook Paper, every "classic vs.
new" toggle). It also overstates how present the phone actually is during hands-on time: the
product's own target metric — fewer than five touches across seven clients — means the honest
baseline during a shift isn't "mostly voice mode, occasionally dashboard mode," it's **mostly
nothing**. The phone is dormant and silent most of the day, punctuated by short spoken
exchanges, plus separate occasional admin sessions. That's one assistant with an episodic voice
layer and one app opened on her own initiative — not two experiences to switch between.

---

## The wake-word layer belongs to Siri, not to this app

**Decided:** true hands-free activation ("Hey Cue, ...") should be built on Apple's own App
Intents / App Shortcuts surfaced through Siri, not as a custom always-listening wake-word
engine inside this app.

**Why:** a third-party app cannot run continuous background microphone capture waiting for a
wake phrase the way Siri does — it requires either an active foreground audio session for the
whole shift or fragile/battery-costly background-audio workarounds that risk App Store
rejection. It also means a **persistent mic-in-use indicator for the entire appointment** —
which is a trust problem specific to this industry, not just a battery one: a client on the
table can see (or later learn) that the provider's phone was recording-indicator-on the whole
session. Siri's own wake-word system already solves this at the OS level, with a trust model
clients and providers already accept, at zero extra battery/engineering cost to us. Building a
worse, proprietary version of something Apple already ships is not a differentiator here.

**How to apply:** when this becomes real work, the task is "expose the right actions via App
Intents," not "build a wake-word detector."

---

## Proactive speech is the unfinished half of a principle that already exists

**Decided:** CLAUDE.md's "Spoken" tier — *"One sentence... This is the product. Everything below
is fallback"* — already means DETAIL is supposed to speak cues aloud, not just surface a silent
card. As of this conversation, that's only half-built: the daily brief is spoken (a bundled
audio clip) and conversational replies are spoken (real ElevenLabs TTS via
`VoiceConversationViewModel.speak`), but an ad-hoc `CueCard`/`ThresholdProposalCard` appearing on
Home (a running-late notice, a reschedule) is silent and visual-only today, even though the
product's own stated principle says it shouldn't be. This is a gap to close, not a new feature
to design from zero — the TTS pipeline already works, it's just not wired to `momentQueue`.

### When to speak vs. leave as a silent card
**Decided:** gate on whether the information **decays before she'd next see it**, not on a
vague "importance" scale. "Priya's running 10 minutes late" has to be said now or it's stale by
the time she next glances at the phone — speak it. "A client left a review" doesn't decay —
leave it as a card, no interruption earned. This is the same restraint principle already in
CLAUDE.md, extended with one crisp question instead of a new gradient.

### No permission-gate, no "Excuse me"
**Decided:** don't ask "you have 2 updates, do you want to hear them?" before speaking, and
don't preface a cue with an apology ("Excuse me, Jazz..."). The Siri phone-call pattern
("someone's calling, answer?") earns its permission-step because answering opens a live channel
with another person — a Cue update is one sentence of information that already cleared the
~5-a-day threshold bar before it ever reached this point. Asking permission a second time is a
redundant gate that turns one calm sentence into two audio events plus an unanswerable pause (her
hands are on a client; she can't reply). CLAUDE.md's own example is already the right shape and
the right tone — stated directly, no question, no preamble: *"Your 1:30 is running twelve
minutes late. I moved your cleanup window and texted your 2:30. Nothing you need to do."*
Adding Siri-style formality undercuts the calm, confident voice already established everywhere
else in this spec.

### Batch, don't queue permission requests
**Decided:** if more than one decaying cue lands in a short window, say them together in one
sentence rather than asking about each in turn — *"Priya's running 10 late, and I moved your
2:30's cleanup window — nothing you need to do."* One utterance, still no response required.

---

## Proactive speech requires a private output channel — and that's a real (lighter) hardware dependency

**Decided:** DETAIL should never speak proactively through the phone's open speaker during an
appointment. A silent card in her pocket is invisible to the client on the table; a phone that
*speaks out loud* — "your 2:30 just canceled" — is audible to whoever's in the room. That's a
genuine spa-atmosphere problem this industry can't absorb the way a louder trade could. Treat
"speaks privately, never through the open speaker mid-session" as close to a hard requirement.

**Why this isn't the hardware dependency we already ruled out:** a custom ring/wearable was
rejected because it requires new, bespoke hardware this product would have to design, ship, and
support. An earbud is neither custom nor bespoke — it's a thing providers already commonly wear,
and the dependency is soft: the feature degrades gracefully (falls back to a silent card) rather
than failing outright when one isn't present.

**How to apply, including for demos:** gate proactive speech on `AVAudioSession`'s current
output route being headphones, not on a settings toggle written for demo purposes. In the real
world, no earbud in means it silently falls back to a card, exactly as intended — correct
behavior, not a degraded one. For a demo, popping an earbud in or leaving it out exercises the
exact same code path either way; there is no separate "demo mode" to maintain alongside the real
behavior.
