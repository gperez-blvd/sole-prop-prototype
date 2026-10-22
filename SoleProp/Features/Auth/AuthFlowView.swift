import SwiftUI

/// The one entry point before anything else — a single continuous
/// screen, not a forked "create account vs. log in" choice: enter a
/// phone or email, continue, verify a one-time code, and (only if that
/// contact is new) finish with a short profile. Modeled on Airbnb's own
/// mobile sign-in — one "Log in or sign up" door, not two — adapted
/// here for the same reason the rest of this session's Airbnb research
/// got adapted rather than copied: the pattern (defer the new-vs
/// -returning fork to verification, not to a button the person has to
/// pre-answer) is worth it, the literal screen isn't.
///
/// An OTP step is also the more honest security shape for a prototype
/// to model, not just a style choice: a password someone types in
/// directly at signup is a credential that can be set by anyone who
/// knows (or guesses) that email — proving control of the inbox or
/// phone first is what makes the account's identity actually mean
/// something.
///
/// `onCreateAccount` fires once a new contact finishes the profile step
/// (into Day 0 onboarding); `onLogIn` fires from Apple/Google, which —
/// same as real social sign-in — already proves identity on its own, so
/// it skips straight in rather than running through OTP + profile.
///
/// Forces `.environment(\.colorScheme, .dark)` on everything below it:
/// the atmosphere behind this screen is *always* dark, independent of
/// the app's own light/dark appearance setting (a deliberate choice —
/// see `AtmosphereBackground`), so anything here reading an adaptive
/// `Tokens.Color` (which `OnboardingField`/`PillButton.primary` do)
/// needs to be forced into dark's values too, or it risks resolving to
/// light-mode ink-on-ink when the app's own setting is Light.
struct AuthFlowView: View {
    var onCreateAccount: () -> Void
    var onLogIn: () -> Void

    private enum Step: Equatable {
        case entry
        case otp
        case profile
    }

    @State private var step: Step = .entry

    @State private var contact = ""
    @State private var code = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var dateOfBirth = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
    @State private var password = ""

    @State private var isWorking = false
    @State private var placeholderMessage: String?

    /// 0 = nothing traced yet, 1 = the full word is traced.
    @State private var traceProgress: CGFloat = 0
    /// The solid wordmark underneath fades in as the trace finishes
    /// rather than snapping on, so the hand-off doesn't look like a cut.
    @State private var fillOpacity: Double = 0
    /// The traced line itself fades away once the fill has fully taken
    /// over, so it doesn't linger as a stray outline.
    @State private var traceOpacity: Double = 1

    /// Slow and deliberate on purpose — this is the one moment in the
    /// app meant to look considered rather than efficient. A quick trace
    /// reads as a loading spinner; this should read as handwriting.
    private let titleDrawDuration: Double = 2.6
    /// A strong deceleration curve (fast start, long confident settle)
    /// rather than plain `.easeInOut` — a pen stroke slowing into its
    /// own finish reads as intentional; symmetric easing at this length
    /// reads as mechanical.
    private var traceCurve: Animation {
        .timingCurve(0.16, 1, 0.3, 1, duration: titleDrawDuration)
    }
    private var contentStartDelay: Double { titleDrawDuration * 0.78 }

    private var titleFont: UIFont {
        UIFont(name: "DMSans-9ptRegular", size: 100) ?? .systemFont(ofSize: 100, weight: .semibold)
    }

    var body: some View {
        ZStack {
            AtmosphereBackground(style: .dark).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                // A fixed size throughout — the fields and button never
                // change enough between steps to need the wordmark to
                // get out of their way, so there's nothing for it to
                // transition. Scaled down slightly from the splash's
                // full size (1) just so it reads as "settled" rather
                // than "still arriving" once content is on screen.
                wordmark
                    .scaleEffect(0.74)
                    .padding(.top, -14)
                    .padding(.bottom, -6)

                if step == .entry {
                    Text("The Secret Behind Your Service")
                        .font(Tokens.Typography.body)
                        .foregroundStyle(Tokens.Color.fog.opacity(0.65))
                        .tracking(-0.2)
                        .staggerAppear(0, baseDelay: 0.12, startDelay: contentStartDelay)
                        .padding(.top, 8)
                }

                Spacer(minLength: step == .entry ? 0 : 28)

                if step != .entry {
                    backButton
                        .padding(.horizontal, Tokens.Spacing.lg)
                        .padding(.bottom, Tokens.Spacing.sm)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                stepContent
                    .padding(.horizontal, Tokens.Spacing.lg)

                if step == .entry {
                    Spacer()
                } else {
                    Spacer(minLength: 24)
                }

                footer
                    .padding(.horizontal, Tokens.Spacing.lg)
                    .padding(.bottom, Tokens.Spacing.xl)
            }
        }
        .environment(\.colorScheme, .dark)
        .animation(Tokens.Motion.standard, value: step)
        .onAppear {
            withAnimation(traceCurve) {
                traceProgress = 1
            }
            // The fill eases in across the trace's own final third,
            // finishing right as the trace does, rather than popping on
            // all at once at the end.
            withAnimation(.easeOut(duration: titleDrawDuration * 0.45).delay(titleDrawDuration * 0.55)) {
                fillOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.6).delay(titleDrawDuration + 0.1)) {
                traceOpacity = 0
            }
        }
        .alert("Not designed yet", isPresented: .constant(placeholderMessage != nil), presenting: placeholderMessage) { _ in
            Button("OK") { placeholderMessage = nil }
        } message: { message in
            Text(message)
        }
    }

    // MARK: - Wordmark

    /// **A lesson worth keeping from getting this wrong once:** the fill
    /// used to be a plain `Text("Cue")` layered under the traced
    /// `GlyphPathShape`. Those are two independent layout systems — a
    /// `Font`'s own metrics versus a CoreText path fitted to a given
    /// `rect` — with no guarantee they'd ever land at the same size or
    /// position, and in practice they didn't: it rendered as two visibly
    /// different "Cue"s on top of each other. The fix is to never let a
    /// traced outline and its own fill be two different views in the
    /// first place — fill and stroke the *same* `GlyphPathShape` value,
    /// so there's only one geometry to ever go out of sync with itself.
    private var wordmark: some View {
        ZStack {
            GlyphPathShape(text: "Cue", font: titleFont)
                .fill(Tokens.Color.fog)
                .opacity(fillOpacity)

            GlyphPathShape(text: "Cue", font: titleFont)
                .trim(from: 0, to: traceProgress)
                .stroke(Tokens.Color.ochre, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                .opacity(traceOpacity)
        }
        .frame(width: 220, height: 100)
    }

    // MARK: - Back

    private var backButton: some View {
        Button {
            goBack()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 13, weight: .semibold))
                Text("Back")
                    .font(Tokens.Typography.caption)
            }
            .foregroundStyle(Tokens.Color.fog.opacity(0.7))
        }
        .buttonStyle(.plain)
        .disabled(isWorking)
    }

    // MARK: - Steps

    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case .entry:
            entryStep
        case .otp:
            otpStep
        case .profile:
            profileStep
        }
    }

    private var entryStep: some View {
        VStack(spacing: Tokens.Spacing.md) {
            Text("Log in or sign up")
                .font(Tokens.Typography.title)
                .foregroundStyle(Tokens.Color.fog)
                .staggerAppear(1, baseDelay: 0.12, startDelay: contentStartDelay)

            OnboardingField(label: "Phone or email", text: $contact, keyboardType: .emailAddress, textContentType: .username)
                .staggerAppear(2, baseDelay: 0.12, startDelay: contentStartDelay)

            PillButton(
                title: isWorking ? "Sending code…" : "Continue",
                style: .primaryLight,
                isDisabled: contact.trimmingCharacters(in: .whitespaces).isEmpty || isWorking
            ) {
                sendCode()
            }
            .staggerAppear(3, baseDelay: 0.12, startDelay: contentStartDelay)

            HStack(spacing: 10) {
                Rectangle().fill(Tokens.Color.hairline).frame(height: 1)
                Text("or")
                    .font(Tokens.Typography.label)
                    .foregroundStyle(Tokens.Color.fog.opacity(0.5))
                Rectangle().fill(Tokens.Color.hairline).frame(height: 1)
            }
            .staggerAppear(4, baseDelay: 0.12, startDelay: contentStartDelay)

            // Floating, icon-only — social sign-in already proves who
            // this is on its own, so it doesn't need the label a plain
            // button would, and it doesn't run through OTP/profile at
            // all; see the type-level doc for why.
            HStack(spacing: 20) {
                SocialIconButton(systemImage: "apple.logo", isDisabled: isWorking) {
                    authenticate(onLogIn)
                }
                SocialIconButton(mark: "G", isDisabled: isWorking) {
                    authenticate(onLogIn)
                }
            }
            .staggerAppear(5, baseDelay: 0.12, startDelay: contentStartDelay)
        }
    }

    private var otpStep: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Enter the code")
                    .font(Tokens.Typography.title)
                    .foregroundStyle(Tokens.Color.fog)
                Text("We sent a code to \(contact).")
                    .font(Tokens.Typography.caption)
                    .foregroundStyle(Tokens.Color.fog.opacity(0.6))
            }

            OnboardingField(label: "Verification code", text: $code, keyboardType: .numberPad)

            Button {
                placeholderMessage = "Resending a code — not designed yet."
            } label: {
                Text("Didn't get a code? Resend")
                    .font(Tokens.Typography.caption)
                    .foregroundStyle(Tokens.Color.fog.opacity(0.6))
                    .underline()
            }
            .buttonStyle(.plain)

            PillButton(
                title: isWorking ? "Verifying…" : "Verify",
                style: .primaryLight,
                isDisabled: code.trimmingCharacters(in: .whitespaces).isEmpty || isWorking
            ) {
                verifyCode()
            }
            .padding(.top, 2)
        }
    }

    private var profileStep: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
            Text("Finish creating your account")
                .font(Tokens.Typography.title)
                .foregroundStyle(Tokens.Color.fog)

            HStack(spacing: 8) {
                OnboardingField(label: "First name", text: $firstName)
                OnboardingField(label: "Last name", text: $lastName)
            }

            OnboardingDateField(label: "Date of birth", date: $dateOfBirth)

            OnboardingField(label: "Password", text: $password, textContentType: .newPassword)

            (
                Text("By continuing, you agree to Cue's ")
                    + Text("Terms of Service").underline()
                    + Text(" and ")
                    + Text("Privacy Policy").underline()
                    + Text(".")
            )
            .font(Tokens.Typography.caption)
            .foregroundStyle(Tokens.Color.fog.opacity(0.55))
            .onTapGesture {
                placeholderMessage = "Terms of Service / Privacy Policy — not designed yet."
            }

            PillButton(
                title: isWorking ? "Creating…" : "Agree and continue",
                style: .primaryLight,
                isDisabled: firstName.trimmingCharacters(in: .whitespaces).isEmpty
                    || lastName.trimmingCharacters(in: .whitespaces).isEmpty
                    || password.isEmpty
                    || isWorking
            ) {
                authenticate(onCreateAccount)
            }
            .padding(.top, 2)
        }
    }

    // MARK: - Footer

    private var footer: some View {
        Text("powered by Boulevard")
            .font(.dmSans(14, weight: .medium))
            .foregroundStyle(Tokens.Color.fog.opacity(0.45))
            .frame(maxWidth: .infinity)
            // This view's identity persists across step changes (it's
            // always rendered, never removed), so `.staggerAppear`'s
            // one-shot `onAppear` only ever fires once, at launch — the
            // footer settles in with the rest of the splash and then
            // just stays put through every later step change.
            .staggerAppear(6, baseDelay: 0.12, startDelay: contentStartDelay)
    }

    // MARK: - Actions

    private func sendCode() {
        guard !isWorking else { return }
        isWorking = true
        Task {
            try? await Task.sleep(for: .milliseconds(500))
            isWorking = false
            withAnimation(Tokens.Motion.standard) { step = .otp }
        }
    }

    private func verifyCode() {
        guard !isWorking else { return }
        isWorking = true
        Task {
            try? await Task.sleep(for: .milliseconds(500))
            isWorking = false
            // No real backend to check "does this contact already have
            // an account" against — the OTP step is the same either
            // way, so this is the one place that distinction would be
            // made in a real build. Every contact that comes through
            // here is treated as new and walks into profile completion.
            withAnimation(Tokens.Motion.standard) { step = .profile }
        }
    }

    private func authenticate(_ completion: @escaping () -> Void) {
        guard !isWorking else { return }
        isWorking = true
        Task {
            try? await Task.sleep(for: .milliseconds(500))
            completion()
        }
    }

    /// Steps back one at a time rather than all the way to entry —
    /// unlike the old tap-the-logo reset, a typo in a six-digit code or
    /// a half-filled profile is worth going back to fix, not losing.
    private func goBack() {
        guard !isWorking else { return }
        switch step {
        case .entry:
            break
        case .otp:
            withAnimation(Tokens.Motion.standard) { step = .entry }
            code = ""
        case .profile:
            withAnimation(Tokens.Motion.standard) { step = .otp }
            firstName = ""
            lastName = ""
            password = ""
        }
    }
}

/// A floating, icon-only circle for social sign-in — Apple/Google here
/// don't need a label the way a plain `PillButton` would; the mark
/// alone is the whole point of it being recognizable at a glance.
private struct SocialIconButton: View {
    var systemImage: String? = nil
    var mark: String? = nil
    var isDisabled: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 20, weight: .medium))
                } else if let mark {
                    Text(mark)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                }
            }
            .foregroundStyle(Tokens.Color.fog)
            .frame(width: 52, height: 52)
        }
        .buttonStyle(.plain)
        .overlay(Circle().strokeBorder(Tokens.Color.fog.opacity(0.4), lineWidth: 1))
        .opacity(isDisabled ? 0.4 : 1)
        .disabled(isDisabled)
    }
}

/// A labeled date picker in the same filled-shell shape as
/// `OnboardingField`, for the one field here that isn't free text.
private struct OnboardingDateField: View {
    var label: String
    @Binding var date: Date

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                TrackedLabel(text: label)
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(Tokens.Typography.value)
                    .foregroundStyle(Tokens.Color.textPrimary)
            }
            Spacer()
            DatePicker("", selection: $date, displayedComponents: .date)
                .labelsHidden()
                .colorScheme(.dark)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Tokens.Color.accentTint, in: RoundedRectangle(cornerRadius: Tokens.Radius.md))
    }
}

#Preview {
    AuthFlowView(onCreateAccount: {}, onLogIn: {})
}
