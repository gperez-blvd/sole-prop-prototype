/**
 * The app's design system — see CLAUDE.md's "Where truth lives".
 *
 * Pulled from the "Boulevard Secret Service" (DETAIL) onboarding prototype
 * artifact (claude.ai/artifact/8UrkD2W5rnV4J2M4tjTiDb): the onyx/ochre/paper
 * "director" visual language. Originally onboarding-only; now the design
 * system for the app as a whole, superseding BUI (white/black/DM Sans) —
 * screens still on BUITokens.swift haven't been migrated yet. Mirrors the
 * structure of SoleProp/DesignSystem/Tokens.swift (Swift equivalent, same
 * source); keep the two in sync.
 *
 * Per CLAUDE.md: these are implementation tokens for the ~12 screens that
 * exist, not an invitation to add surface area. Most values here back a
 * handful of recurring primitives (pill buttons, hairline dividers,
 * uppercase mono labels, cards) — not a component-per-token system.
 */

// ---------------------------------------------------------------------------
// Color
// ---------------------------------------------------------------------------

/** Raw palette — the named swatches the artifact's CSS defines on :root. */
export const palette = {
  onyx: "#000000",
  white: "#ffffff",
  ochre: "#C8AB7C",
  fog: "#F5F4F1",
  silt: "#E4E4DE",

  ink: "#0A0A0A",
  ink2: "#5F5B53",
  ink3: "#8A867C",

  paper: "#F5F4F1",

  /** Outer page shell behind the whole prototype (light chrome, not part of the dark stage). */
  shell: "#faf9f5",
  shellText: "#141413",
} as const;

/**
 * Alpha-blended variants, kept as CSS-color strings (not resolvable to a
 * single hex) so callers can drop them straight into `rgba()`-accepting
 * style props. Named after the artifact's own custom properties.
 */
export const alpha = {
  /** paper (--paper) at decreasing opacity — secondary/tertiary/quaternary text on dark surfaces. */
  paper66: "rgba(245,244,241,.66)", // --p2
  paper40: "rgba(245,244,241,.4)", // --p3
  paper18: "rgba(245,244,241,.18)", // --p4
  paper13: "rgba(245,244,241,.13)", // --p4 alt / hairlines
  paper30: "rgba(245,244,241,.3)",
  paper35: "rgba(245,244,241,.35)",

  /** hairline on dark surfaces (--line) */
  lineDark: "rgba(245,244,241,.13)",
  /** hairline on light surfaces (--lineL) */
  lineLight: "rgba(0,0,0,.13)",

  /** ochre (--oc2 / --oc3) at reduced opacity — accent borders, connective rules. */
  ochre55: "rgba(200,171,124,.55)", // --oc2
  ochre22: "rgba(200,171,124,.22)", // --oc3

  black06: "rgba(0,0,0,.06)",
  black16: "rgba(0,0,0,.16)",
  black25: "rgba(0,0,0,.25)",
  black35: "rgba(0,0,0,.35)",
  black38: "rgba(0,0,0,.38)",
  black94: "rgba(0,0,0,.94)",
} as const;

/**
 * Dark-surface layer scale used for the "car mode" ear display and the
 * below-the-surface log panel — progressively lighter blacks, not a named
 * custom property in the source but used consistently as a stack.
 */
export const surface = {
  stage: palette.onyx, // page background
  panel: "#040404", // .below log panel
  ear: "#050505", // .ear box
  phoneBody: "#0b0b0b", // .phone chassis
  carModeBg: "#0b0b0d", // .ear.carmode
  carModeMap: "#121215", // .earmap
  cueCard: "#121212", // .cuecard on lock screen
  screenDark: "#000000", // .scr.dark
  screenOff: "#050505", // .scr.off
  carBorder: "#2b2b2e",
  carBorderInset: "#17171a",
  carDivider: "#1e1e21",
} as const;

/** Semantic roles, composed from palette + alpha. This is what components should reach for. */
export const color = {
  background: palette.onyx,
  backgroundElevated: surface.panel,
  text: palette.paper,
  textSecondary: alpha.paper66,
  textTertiary: alpha.paper40,
  textQuaternary: alpha.paper18,
  accent: palette.ochre,
  accentMuted: alpha.ochre55,
  accentFaint: alpha.ochre22,
  hairline: alpha.lineDark,
  hairlineOnLight: alpha.lineLight,

  // Light-card surfaces nested inside the dark stage (phone screens, tiles,
  // the Instagram preview) flip to an ink-on-fog reading.
  onLight: {
    background: palette.white,
    surface: palette.fog,
    text: palette.ink,
    textSecondary: palette.ink2,
    textTertiary: palette.ink3,
    hairline: alpha.lineLight,
    fill: palette.silt,
  },

  /** Warm brown used for "flagged / needs review" states (gift cards, imports, pending review). Not a :root variable — a literal repeated across those states. */
  flag: "#8a6f3f",
} as const;

// ---------------------------------------------------------------------------
// Typography
// ---------------------------------------------------------------------------

export const fontFamily = {
  /** Body/UI face. Loaded as Instrument Sans; system stack is the fallback. */
  sans: "'Instrument Sans','Helvetica Neue',Helvetica,Arial,sans-serif",
  /** Uppercase tracked labels, mono numerals, timestamps. */
  mono: "'IBM Plex Mono',ui-monospace,SFMono-Regular,Menlo,Consolas,monospace",
  /** Outer page shell before the app's own fonts load. */
  systemFallback: "-apple-system,BlinkMacSystemFont,sans-serif",
} as const;

/**
 * Font sizes, named by role rather than by the raw px value — the source
 * reuses the same handful of sizes across many components. Values in px.
 */
export const fontSize = {
  micro: 8.5, // stat/card micro-labels
  labelXs: 9, // mono uppercase labels (tightest)
  labelSm: 9.5,
  label: 10, // standard mono uppercase label (.lbl)
  labelLg: 10.5,
  captionSm: 11,
  caption: 11.5,
  bodySm: 12,
  body: 12.5,
  bodyBase: 13, // root-adjacent body text
  bodyLg: 13.5,
  ui: 14, // buttons, row titles
  uiLg: 14.5,
  value: 15, // base body size set on <body>
  valueLg: 16,
  heading: 20,
  headingLg: 22,
  display: 24,
  displayLg: 26,
  stat: 30,
  statLg: 34,
  clock: 40,
  lockTime: 64,
} as const;

export const fontWeight = {
  regular: 400,
  medium: 500,
  semibold: 600,
  bold: 700,
} as const;

/** Named letter-spacing steps, in em — negative for large numerals/headlines, positive-tracked for uppercase mono labels. */
export const letterSpacing = {
  tightest: -0.04,
  tighter: -0.03,
  tight: -0.02,
  snug: -0.012,
  slight: -0.01,
  normal: 0,
  wide: 0.02,
  wider: 0.04,
  label: 0.06,
  labelWide: 0.08,
  tracked: 0.1,
  trackedMd: 0.12,
  trackedLg: 0.14,
  trackedXl: 0.16,
  trackedXxl: 0.18,
  trackedMax: 0.2,
  trackedMaxLg: 0.22,
} as const;

export const lineHeight = {
  tight: 1,
  snug: 1.1,
  headline: 1.2,
  base: 1.25,
  body: 1.3,
  relaxed: 1.35,
  loose: 1.4,
  default: 1.45,
} as const;

// ---------------------------------------------------------------------------
// Spacing
// ---------------------------------------------------------------------------

/**
 * Base 4px-ish scale inferred from recurring gap/padding/margin values.
 * The source isn't built on a strict scale (it's a hand-tuned prototype),
 * so this rounds to the nearest values actually in use.
 */
export const space = {
  xxs: 2,
  xs: 4,
  sm: 6,
  smd: 8,
  md: 10,
  mdl: 12,
  lg: 14,
  lgl: 16,
  xl: 18,
  xxl: 20,
  xxxl: 22,
  section: 24,
  block: 32,
} as const;

// ---------------------------------------------------------------------------
// Radius
// ---------------------------------------------------------------------------

export const radius = {
  xs: 1,
  sm: 2,
  smd: 4,
  md: 7,
  mdl: 10,
  lg: 12,
  lgl: 13,
  xl: 14,
  xxl: 16,
  xxxl: 20,
  /** Nested light-card radius (`.ptile`/`.card`/`.brand`/`.rev`) — mirrors Tokens.Radius.card in Tokens.swift. Same value as `xl`, named for that use. */
  card: 14,
  /** iOS share-sheet's rounded top corners (`.sheet-body`). */
  sheet: 22,
  phoneScreen: 42,
  phoneChassis: 50,
  pill: 999,
} as const;

// ---------------------------------------------------------------------------
// Shadow
// ---------------------------------------------------------------------------

export const shadow = {
  /** Bottom sheet rising from the phone screen (iOS share sheet mock). */
  sheet: "0 -8px 30px rgba(0,0,0,.18)",
  /** Selected-tile ring (payment method / provider tiles). */
  selectedRing: "0 0 0 1px currentColor",
  /** Inset bezel on the "car display" ear mock. */
  carModeInset: "inset 0 0 0 5px #17171a",
} as const;

// ---------------------------------------------------------------------------
// Layout / breakpoints
// ---------------------------------------------------------------------------

export const breakpoint = {
  /** Below this, the three-column director stage collapses to a single column. */
  stackStage: 980,
  /** Below this, the side rail narrows before it fully collapses. */
  narrowRail: 1180,
  /** Below this, control grids drop to 2 columns and the phone goes full-width. */
  compact: 560,
} as const;

export const motion = {
  fast: "150ms",
  base: "200ms",
  moderate: "280ms",
  slow: "350ms",
  slower: "420ms",
  cinematic: "600ms",
  reveal: "900ms",
} as const;

// ---------------------------------------------------------------------------
// Aggregate export
// ---------------------------------------------------------------------------

export const tokens = {
  palette,
  alpha,
  surface,
  color,
  fontFamily,
  fontSize,
  fontWeight,
  letterSpacing,
  lineHeight,
  space,
  radius,
  shadow,
  breakpoint,
  motion,
} as const;

export type Tokens = typeof tokens;
