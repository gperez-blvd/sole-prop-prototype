#!/usr/bin/env python3
"""Render the Boulevard Secret Service CTA Matrix (objects x roles) as on-brand HTML.

Brand tokens mirror the OOUX Brand Style Guide (skill: ooux-brand-style), Section 1 + 3.
Green = CTAs ("green for go"). Blue = objects. Pink = eyebrow labels / role markers.

Authority markers apply to the DETAIL (System) row only:
    *  = may act without asking      (threshold-governed, silent)
    ~  = must ask first              (threshold-governed, spoken)
    x  = never, by design            (a standing product commitment)
"""
import json, html, pathlib

# --- brand tokens (ooux-brand-style v2) ---
BLUE, BLUE_T = "#68CFF9", "#C5EFFF"
YELLOW, YELLOW_T = "#FFE25B", "#FFF1B0"
PINK, PINK_T = "#F10768", "#F887B6"
GREEN, GREEN_T = "#31B588", "#9CDBC6"
INK, SUB, HINT = "#1A1A1A", "#555555", "#999999"
BORDER, BORDER_M = "#DDDDDD", "#BBBBBB"

TITLE = "Boulevard Secret Service"
SUBTITLE = "CTA Matrix — objects across, user roles down"

OBJECTS = [
    "OPERATOR", "BUSINESS", "DETAIL", "PERSONA", "PATTERN", "THRESHOLD",
    "SIGNAL", "CUE DECISION", "CUE", "DAY", "BRIEFING", "ACTION", "PROPOSAL",
    "CAPABILITY", "CLIENT", "CHART", "CHART ENTRY", "FORM", "APPOINTMENT", "SERVICE", "PRODUCT", "PRODUCT USAGE RULE", "PRODUCT USAGE", "PRODUCT CREDIT", "ORDER", "ORDER LINE ITEM", "PAYMENT", "PAYOUT", "OPENING", "WAITLIST REQUEST", "MESSAGE",
    "CAMPAIGN", "SEGMENT", "REVIEW",
]

ROLES = [
    ("OPERATOR", "Jazz. Solo provider, owner, front desk, entire staff."),
    ("DETAIL", "The System / AI role. CTAs manifest as speech, not buttons."),
    ("CLIENT", "Her customer. Generates most of the day's signals."),
]

# cta text, optional authority marker ("*", "~", "x")
M = {
    ("OPERATOR", "OPERATOR"): ["Edit profile", "Add a credential", "Set working hours", "Pause my day"],
    ("DETAIL", "OPERATOR"): [],
    ("CLIENT", "OPERATOR"): [],

    ("OPERATOR", "BUSINESS"): ["Edit brand", "Edit hours", "Add a service", "Close for a day", "Share booking link"],
    ("DETAIL", "BUSINESS"): [("Refresh brand from Instagram", "~"), ("Update hours from observed pattern", "~")],
    ("CLIENT", "BUSINESS"): [],

    ("OPERATOR", "DETAIL"): ["Rename", "Switch persona", "Tune voice", "Mute for an hour", "Mute for the day", "Pause entirely", "Wake"],
    ("DETAIL", "DETAIL"): [("Change my own voice", "x"), ("Expand my own autonomy", "x")],
    ("CLIENT", "DETAIL"): [],

    ("OPERATOR", "PERSONA"): ["Audition", "Select"],
    ("DETAIL", "PERSONA"): [("Recommend one", "~")],
    ("CLIENT", "PERSONA"): [],

    ("OPERATOR", "PATTERN"): ["Confirm", "\u201cThat\u2019s not true\u201d", "Ask for the evidence", "Act on it", "Mute"],
    ("DETAIL", "PATTERN"): [("Observe", "*"), ("Strengthen", "*"), ("Let it decay", "*"), ("Cite in a proposal", "*"), ("Announce once", "~")],
    ("CLIENT", "PATTERN"): [],

    ("OPERATOR", "THRESHOLD"): ["Confirm", "Adjust", "Tighten", "Loosen", "Decline", "Revert this instance", "Pause", "Delete"],
    ("DETAIL", "THRESHOLD"): [("Apply", "*"), ("Infer silently", "*"), ("Propose a change", "~"), ("Retire a stale one", "~")],
    ("CLIENT", "THRESHOLD"): [],

    ("OPERATOR", "SIGNAL"): ["“Should have told me”", "“Didn’t need this”", "Escalate to a cue"],
    ("DETAIL", "SIGNAL"): [("Evaluate against thresholds", "*"), ("Suppress", "*"), ("Defer", "*"), ("Escalate", "*")],
    ("CLIENT", "SIGNAL"): [],

    ("OPERATOR", "CUE DECISION"): ["Disagree with this call"],
    ("DETAIL", "CUE DECISION"): [("Decide", "*"), ("Reverse a decision", "~")],
    ("CLIENT", "CUE DECISION"): [],

    ("OPERATOR", "CUE"): ["Answer", "Acknowledge", "Defer", "Dismiss", "Replay", "Act on it in-app", "“Too late”"],
    ("DETAIL", "CUE"): [("Compose", "*"), ("Speak", "*"), ("Queue", "*"), ("Withhold", "*"), ("Expire", "*"), ("Suppress a clinical flag", "x")],
    ("CLIENT", "CUE"): [],

    ("OPERATOR", "DAY"): ["Add a note", "Block time", "Close early", "Reopen"],
    ("DETAIL", "DAY"): [("Compile the brief", "*"), ("Compile the debrief", "*"), ("Flag a conflict", "*")],
    ("CLIENT", "DAY"): [],

    ("OPERATOR", "BRIEFING"): ["Play", "Replay", "Skip", "Act on an item", "Move delivery time"],
    ("DETAIL", "BRIEFING"): [("Compose", "*"), ("Deliver", "*")],
    ("CLIENT", "BRIEFING"): [],

    ("OPERATOR", "ACTION"): ["Undo", "Approve", "Reject"],
    ("DETAIL", "ACTION"): [("Execute", "*"), ("Queue for approval", "~"), ("Revert on failure", "*")],
    ("CLIENT", "ACTION"): [],

    ("OPERATOR", "PROPOSAL"): ["Accept", "Decline", "Snooze", "Ask for the math", "Run as a test", "Roll back"],
    ("DETAIL", "PROPOSAL"): [("Raise", "~"), ("Withdraw", "*"), ("Re-raise with new evidence", "~")],
    ("CLIENT", "PROPOSAL"): [],

    ("OPERATOR", "CAPABILITY"): ["Activate", "Connect", "Disconnect", "Decline"],
    ("DETAIL", "CAPABILITY"): [("Detect availability", "*"), ("Propose activation", "~")],
    ("CLIENT", "CAPABILITY"): [],

    ("OPERATOR", "CLIENT"): ["Add", "Edit", "Add a note", "Merge duplicates", "Message", "Charge a fee", "Waive a fee", "Block"],
    ("DETAIL", "CLIENT"): [("Create from a booking", "*"), ("Update from intake", "*"), ("Message in her voice", "*"), ("Merge duplicates", "~"), ("Charge a fee", "x"), ("Offer a discount", "x")],
    ("CLIENT", "CLIENT"): ["Edit own details", "Fill intake form"],

    ("OPERATOR", "CHART"): ["Open", "Review before treatment", "Amend", "Export", "Share with a provider", "Lock"],
    ("DETAIL", "CHART"): [("Surface it before a treatment", "*"), ("Flag a contraindication", "*"), ("Summarize for her eyes", "*"), ("Read clinical detail aloud", "x"), ("Disclose to a third party", "x")],
    ("CLIENT", "CHART"): ["Request a copy"],

    ("OPERATOR", "CHART ENTRY"): ["Create", "Dictate", "Attach a photo", "Sign", "Amend", "Discard a draft"],
    ("DETAIL", "CHART ENTRY"): [("Transcribe from her dictation", "*"), ("Pre-fill from the service", "*"), ("Remind her to sign", "*"), ("Sign on her behalf", "x")],
    ("CLIENT", "CHART ENTRY"): [],

    ("OPERATOR", "FORM"): ["Send", "Resend", "Mark complete on paper", "Fill on her behalf", "Waive", "Review the flags"],
    ("DETAIL", "FORM"): [("Send at booking", "*"), ("Remind the client", "*"), ("Flag a contraindication", "*"), ("Mark complete", "*"), ("Waive a required form", "x"), ("Answer for the client", "x")],
    ("CLIENT", "FORM"): ["Fill", "Sign", "Update", "Request a copy"],

    ("OPERATOR", "APPOINTMENT"): ["Book", "Reschedule", "Cancel", "Check in", "Complete", "Charge", "Add a note", "Rebook in the room"],
    ("DETAIL", "APPOINTMENT"): [("Confirm", "*"), ("Send a reminder", "*"), ("Check in", "*"), ("Reschedule inside threshold", "*"), ("Reschedule beyond threshold", "~"), ("Cancel", "x"), ("Charge", "x")],
    ("CLIENT", "APPOINTMENT"): ["Book", "Reschedule", "Cancel", "Confirm", "Check in"],

    ("OPERATOR", "SERVICE"): ["Add", "Edit", "Set price", "Set consent requirement", "Mark non-discountable", "Retire"],
    ("DETAIL", "SERVICE"): [("Import at onboarding", "~"), ("Propose a price test", "~"), ("Change price", "x")],
    ("CLIENT", "SERVICE"): [],

    ("OPERATOR", "PRODUCT"): ["Add", "Edit", "Set retail price", "Set unit cost", "Adjust quantity", "Receive stock", "Sell at checkout", "Deactivate"],
    ("DETAIL", "PRODUCT"): [("Track depletion", "*"), ("Flag low stock", "*"), ("Recommend at checkout", "~"), ("Queue a reorder", "~"), ("Change retail price", "x"), ("Place a purchase order", "x")],
    ("CLIENT", "PRODUCT"): ["Buy"],

    ("OPERATOR", "PRODUCT USAGE RULE"): ["Create", "Set price per item", "Set default quantity", "Deactivate", "Remove"],
    ("DETAIL", "PRODUCT USAGE RULE"): [("Suggest a default from history", "~"), ("Change price per item", "x")],
    ("CLIENT", "PRODUCT USAGE RULE"): [],

    ("OPERATOR", "PRODUCT USAGE"): ["Record units used", "Adjust units", "Dictate", "Redeem prepaid units", "Correct after checkout"],
    ("DETAIL", "PRODUCT USAGE"): [("Pre-fill from the default", "*"), ("Transcribe from her dictation", "*"), ("Deplete stock", "*"), ("Flag a variance", "*"), ("Charge for units", "x"), ("Disclose unit counts to the client", "x")],
    ("CLIENT", "PRODUCT USAGE"): [],

    ("OPERATOR", "PRODUCT CREDIT"): ["Sell prepaid units", "Apply a bulk discount", "Redeem", "Refund", "Adjust the balance"],
    ("DETAIL", "PRODUCT CREDIT"): [("Surface the balance before checkout", "*"), ("Remind her at checkout", "*"), ("Redeem without asking", "x"), ("Sell prepaid units", "x")],
    ("CLIENT", "PRODUCT CREDIT"): ["Buy prepaid units", "Request a refund"],

    ("OPERATOR", "ORDER"): ["Open", "Add a line item", "Apply a discount", "Take payment", "Close", "Void", "Refund", "Reopen", "Email a receipt"],
    ("DETAIL", "ORDER"): [("Open it at check-in", "*"), ("Pre-fill from the appointment", "*"), ("Flag an unclosed order", "*"), ("Take a payment", "x"), ("Apply a discount", "x"), ("Close it", "x"), ("Void or refund", "x")],
    ("CLIENT", "ORDER"): ["Pay", "Tip", "Request a receipt"],

    ("OPERATOR", "ORDER LINE ITEM"): ["Add", "Edit quantity", "Adjust price", "Discount", "Remove"],
    ("DETAIL", "ORDER LINE ITEM"): [("Add from product usage", "*"), ("Adjust price", "x"), ("Discount", "x")],
    ("CLIENT", "ORDER LINE ITEM"): [],

    ("OPERATOR", "PAYMENT"): ["Take", "Split the tender", "Retry", "Refund", "Void"],
    ("DETAIL", "PAYMENT"): [("Flag a decline", "*"), ("Take a payment", "x"), ("Retry a payment", "x"), ("Refund", "x")],
    ("CLIENT", "PAYMENT"): ["Pay", "Retry", "Dispute"],

    ("OPERATOR", "PAYOUT"): ["Connect a bank account", "Change the destination", "Change the schedule"],
    ("DETAIL", "PAYOUT"): [("Report the timing", "*"), ("Flag a failure", "*"), ("Change the destination", "x"), ("Initiate", "x")],
    ("CLIENT", "PAYOUT"): [],

    ("OPERATOR", "OPENING"): ["Offer to waitlist", "Post publicly", "Fill manually", "Block"],
    ("DETAIL", "OPENING"): [("Detect", "*"), ("Hold", "*"), ("Offer to waitlist", "~"), ("Post publicly", "~")],
    ("CLIENT", "OPENING"): ["Claim", "Join waitlist"],

    ("OPERATOR", "WAITLIST REQUEST"): ["Add for a client", "Edit", "Offer a slot", "Fulfil manually", "Re-rank", "Expire", "Remove"],
    ("DETAIL", "WAITLIST REQUEST"): [("Create from a DM or call", "*"), ("Match to an opening", "*"), ("Re-rank the queue", "*"), ("Expire a stale one", "*"), ("Offer", "~")],
    ("CLIENT", "WAITLIST REQUEST"): ["Request", "Update", "Withdraw", "Accept an offer", "Decline an offer"],

    ("OPERATOR", "MESSAGE"): ["Send", "Draft", "Edit a draft", "Approve", "Reply", "Delete"],
    ("DETAIL", "MESSAGE"): [("Draft in her voice", "*"), ("Send inside threshold", "*"), ("Auto-reply an FAQ", "*"), ("Send outside threshold", "~")],
    ("CLIENT", "MESSAGE"): ["Send", "Reply"],

    ("OPERATOR", "CAMPAIGN"): ["Create", "Edit the copy", "Approve", "Schedule", "Send now", "Pause", "Cancel", "Duplicate"],
    ("DETAIL", "CAMPAIGN"): [("Draft in her voice", "*"), ("Measure", "*"), ("Stop on an unsubscribe spike", "*"), ("Propose", "~"), ("Send to a matched shortlist", "*"), ("Send to a segment", "~"), ("Send without consent", "x"), ("Discount to fill a gap", "x")],
    ("CLIENT", "CAMPAIGN"): ["Book from it", "Reply", "Unsubscribe"],

    ("OPERATOR", "SEGMENT"): ["Create", "Name", "Edit criteria", "Exclude a client", "Delete"],
    ("DETAIL", "SEGMENT"): [("Refresh membership", "*"), ("Exclude the unreachable", "*"), ("Flag fatigue", "*"), ("Propose a segment", "~")],
    ("CLIENT", "SEGMENT"): ["Opt out of marketing", "Update contact preferences"],

    ("OPERATOR", "REVIEW"): ["Reply", "Approve a drafted reply", "Flag", "Share"],
    ("DETAIL", "REVIEW"): [("Draft a reply", "*"), ("Tag themes", "*"), ("Flag", "*"), ("Send a reply", "~")],
    ("CLIENT", "REVIEW"): ["Write", "Edit own"],
}

MARK = {
    "*": ("●", "acts without asking", GREEN),
    "~": ("◐", "must ask first", "#B8860B"),
    "x": ("○", "never, by design", PINK),
}


def esc(s):
    return html.escape(str(s))


def chip(item):
    if isinstance(item, tuple):
        text, mk = item
        glyph, label, col = MARK[mk]
        cls = {"*": "silent", "~": "asks", "x": "never"}[mk]
        return (f'<span class="cta {cls}" title="{esc(label)}">'
                f'<b class="mk">{glyph}</b>{esc(text)}</span>')
    return f'<span class="cta">{esc(item)}</span>'


def cell(role, obj):
    items = M.get((role, obj), [])
    if not items:
        return '<td class="empty"><span class="none">no CTAs</span></td>'
    return '<td>' + "".join(chip(i) for i in items) + '</td>'


def counts():
    s = a = n = tot = 0
    for (role, obj), items in M.items():
        for i in items:
            tot += 1
            if isinstance(i, tuple):
                s += i[1] == "*"; a += i[1] == "~"; n += i[1] == "x"
    return tot, s, a, n


def render():
    tot, s, a, n = counts()
    head = "".join(f'<th class="obj">{esc(o)}</th>' for o in OBJECTS)
    rows = []
    for role, desc in ROLES:
        cells = "".join(cell(role, o) for o in OBJECTS)
        rows.append(
            f'<tr><th class="role"><span class="rname">{esc(role)}</span>'
            f'<span class="rdesc">{esc(desc)}</span></th>{cells}</tr>')
    return f"""<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>{esc(TITLE)} — CTA Matrix</title>
<link href="https://fonts.googleapis.com/css2?family=Ubuntu:wght@300;400;500;700&display=swap" rel="stylesheet">
<style>
  *{{box-sizing:border-box}}
  body{{margin:0;padding:40px 32px 64px;background:#fff;color:{INK};
       font-family:Ubuntu,-apple-system,sans-serif;font-weight:400;line-height:1.5}}
  .eyebrow{{font-weight:700;font-size:11px;letter-spacing:.13em;text-transform:uppercase;
       color:{PINK};margin:0 0 10px}}
  h1{{font-family:'Cooper Black',Ubuntu,serif;font-weight:700;letter-spacing:.01em;
       font-size:40px;line-height:1.15;margin:0 0 8px}}
  .sub{{font-weight:300;font-size:17px;color:{SUB};margin:0 0 28px;max-width:70ch}}
  .legend{{display:flex;flex-wrap:wrap;gap:10px 22px;align-items:center;
       border:2px dashed {BLUE};border-radius:12px;padding:16px 20px;margin:0 0 10px;background:#fafdff}}
  .legend .lt{{font-weight:700;font-size:11px;letter-spacing:.12em;text-transform:uppercase;color:{PINK}}}
  .lg{{display:flex;align-items:center;gap:7px;font-size:13px;color:{SUB};font-weight:400}}
  .lg b{{font-size:15px;line-height:1}}
  .note{{font-size:13px;font-weight:300;color:{HINT};margin:0 0 22px}}
  .scroll{{overflow-x:auto;border:1px solid {BORDER};border-radius:14px;background:#fff}}
  table{{border-collapse:separate;border-spacing:0;min-width:100%}}
  th,td{{vertical-align:top;border-right:1px solid {BORDER};border-bottom:1px solid {BORDER}}}
  th.obj{{position:sticky;top:0;z-index:3;background:{BLUE_T};color:{INK};
       font-weight:700;font-size:12.5px;letter-spacing:.07em;text-align:left;
       padding:14px 12px;min-width:196px;width:196px;border-bottom:3px solid {BLUE}}}
  th.corner{{position:sticky;left:0;top:0;z-index:5;background:#fff;min-width:190px;width:190px;
       border-bottom:3px solid {BLUE};border-right:2px solid {BORDER_M};padding:14px 14px}}
  th.corner span{{display:block;font-weight:700;font-size:11px;letter-spacing:.12em;
       text-transform:uppercase;color:{PINK}}}
  th.role{{position:sticky;left:0;z-index:2;background:#fff;padding:16px 14px;text-align:left;
       min-width:190px;width:190px;border-right:2px solid {BORDER_M}}}
  .rname{{display:block;font-weight:700;font-size:15px;letter-spacing:.04em;color:{INK};margin-bottom:5px}}
  .rdesc{{display:block;font-weight:300;font-size:12px;line-height:1.45;color:{SUB}}}
  td{{padding:12px 10px}}
  tr:nth-child(even) td{{background:#fcfcfc}}
  .cta{{display:block;background:{GREEN_T};border:1px solid {GREEN};border-radius:7px;
       padding:5px 8px;margin:0 0 5px;font-size:12.5px;font-weight:500;color:{INK}}}
  .cta.silent{{background:{GREEN_T};border-color:{GREEN}}}
  .cta.asks{{background:{YELLOW_T};border-color:{YELLOW}}}
  .cta.never{{background:#fff;border-style:dashed;border-color:{PINK};color:{SUB};
       text-decoration:line-through;text-decoration-color:{PINK}}}
  .mk{{display:inline-block;margin-right:6px;font-size:11px;line-height:1}}
  .cta.silent .mk{{color:{GREEN}}} .cta.asks .mk{{color:#B8860B}} .cta.never .mk{{color:{PINK}}}
  td.empty{{background:#fbfbfb}}
  .none{{font-size:11.5px;font-weight:300;color:#c4c4c4;font-style:italic}}
  .foot{{margin-top:26px;font-size:12px;font-weight:300;color:{HINT}}}
  .stats{{margin:22px 0 0;font-size:13px;color:{SUB};font-weight:400}}
  .stats b{{color:{INK};font-weight:700}}
</style></head><body>
<p class="eyebrow">OOUX · ORCA · C Pillar</p>
<h1>{esc(TITLE)}</h1>
<p class="sub">{esc(SUBTITLE)}. Green for go. The DETAIL row is the autonomy specification — read it as what the system may do on its own, what it must ask about, and what it may never do.</p>

<div class="legend">
  <span class="lt">DETAIL row</span>
  <span class="lg"><b style="color:{GREEN}">●</b> acts without asking</span>
  <span class="lg"><b style="color:#B8860B">◐</b> must ask first</span>
  <span class="lg"><b style="color:{PINK}">○</b> never, by design</span>
</div>
<p class="note">Strong, transactional CTAs only — view / search / sort / filter are deliberately absent.</p>

<div class="scroll">
<table>
  <thead><tr><th class="corner"><span>Role × Object</span></th>{head}</tr></thead>
  <tbody>{''.join(rows)}</tbody>
</table>
</div>

<p class="stats"><b>{tot}</b> CTAs across 34 objects and 3 roles &nbsp;·&nbsp;
DETAIL: <b>{s}</b> silent, <b>{a}</b> ask-first, <b>{n}</b> never</p>
<p class="foot">rewiredux.com · ooux.com</p>
</body></html>"""


out = pathlib.Path(__file__).parent
(out / "cta-matrix.html").write_text(render(), encoding="utf-8")

data = {"title": TITLE, "objects": OBJECTS,
        "roles": [{"name": r, "description": d} for r, d in ROLES],
        "cells": [{"role": r, "object": o,
                   "ctas": [{"cta": i[0], "authority": i[1]} if isinstance(i, tuple)
                            else {"cta": i} for i in v]}
                  for (r, o), v in M.items()]}
(out / "cta-matrix.json").write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

t, s, a, n = counts()
print(f"wrote cta-matrix.html + cta-matrix.json | {t} CTAs | DETAIL {s} silent / {a} ask / {n} never")
