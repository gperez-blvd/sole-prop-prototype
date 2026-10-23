import SwiftUI

/// The one branded segmented control — a filled `primaryFill` pill for
/// the selected option inside a `silt`-filled track. Used anywhere a
/// screen switches between equally-weighted views of the same content
/// (Schedule's Day/Week, Wallet's Wallet/Transactions) — never the
/// system `.pickerStyle(.segmented)`, whose gray capsule and
/// system-tinted highlight don't read as this app's own design language
/// (see DESIGN_SYSTEM.md's Components section).
///
/// Promoted from `ScheduleView`'s own `modeToggle`, which had this exact
/// look before `WalletView` needed the same switch and reached for the
/// system picker instead — the kind of drift a shared component exists
/// to prevent (see ENGINEERING_LESSONS.md's note on deciding a shared
/// treatment once rather than letting sibling screens reinvent it).
struct SegmentedToggle<Option: Hashable>: View {
    var options: [Option]
    @Binding var selection: Option
    var label: (Option) -> String

    var body: some View {
        HStack(spacing: 2) {
            ForEach(options, id: \.self) { option in
                let isSelected = option == selection
                Button {
                    withAnimation(Tokens.Motion.quick) { selection = option }
                } label: {
                    Text(label(option))
                        .font(Tokens.Typography.body)
                        .foregroundStyle(isSelected ? Tokens.Color.onPrimaryFill : Tokens.Color.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: Tokens.Radius.md).fill(isSelected ? Tokens.Color.primaryFill : Color.clear))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(RoundedRectangle(cornerRadius: Tokens.Radius.card).fill(Tokens.Color.silt))
    }
}

extension SegmentedToggle where Option: RawRepresentable, Option.RawValue == String {
    /// The common case — an enum whose raw value is already its own
    /// display label (`case day = "Day"`), which is how both of this
    /// control's call sites are modeled. Spelling out `label:` per call
    /// site would just repeat `{ $0.rawValue }` forever.
    init(options: [Option], selection: Binding<Option>) {
        self.init(options: options, selection: selection, label: \.rawValue)
    }
}
