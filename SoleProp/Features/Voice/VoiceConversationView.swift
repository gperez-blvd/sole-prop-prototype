import SwiftUI

struct VoiceConversationView: View {
    @Environment(Router.self) private var router
    @Environment(VoiceConversationViewModel.self) private var viewModel
    @State private var draftText = ""
    @State private var placeholderMessage: String?
    @FocusState private var textFieldFocused: Bool

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if viewModel.messages.isEmpty {
                        Text("Tap the orb and ask Cue about your day — \"when is my next client?\", \"how many appointments today?\"")
                            .font(.system(size: 13.5))
                            .foregroundStyle(BUITokens.Color.disabled)
                            .padding(.top, 24)
                    }
                    ForEach(viewModel.messages) { message in
                        messageBubble(message)
                    }
                }
                .padding(24)
            }

            Divider()

            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    QuickActionButton(title: "Book", systemImage: "calendar.badge.plus", isCompact: true) {
                        placeholderMessage = "Book — not designed yet."
                    }
                    QuickActionButton(title: "Sale", systemImage: "tag", isCompact: true) {
                        placeholderMessage = "Sale — not designed yet."
                    }
                    Spacer(minLength: 0)
                }

                HStack(spacing: 12) {
                    inputModeToggle

                    if viewModel.inputMode == .voice {
                        Spacer(minLength: 0)
                        Button {
                            viewModel.toggleListening()
                        } label: {
                            VoiceOrb(size: 56, level: viewModel.audioLevel, isActive: viewModel.isListening)
                        }
                        .buttonStyle(.plain)
                        Spacer(minLength: 0)
                        // Balances the toggle's width so the orb stays centered.
                        Color.clear.frame(width: 36, height: 1)
                    } else {
                        TextField("Ask something…", text: $draftText)
                            .textFieldStyle(.roundedBorder)
                            .focused($textFieldFocused)
                            .onSubmit(submitDraft)
                        Button("Send", action: submitDraft)
                            .disabled(draftText.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .background(BUITokens.Color.background)
        .navigationTitle("Cue")
        .navigationBarTitleDisplayMode(.inline)
        .backIconButton { router.pop() }
        .alert("Cue", isPresented: .constant(viewModel.errorMessage != nil), presenting: viewModel.errorMessage) { _ in
            Button("OK") { viewModel.errorMessage = nil }
        } message: { message in
            Text(message)
        }
        .alert("Not designed yet", isPresented: .constant(placeholderMessage != nil), presenting: placeholderMessage) { _ in
            Button("OK") { placeholderMessage = nil }
        } message: { message in
            Text(message)
        }
    }

    /// Keyboard/voice icon toggle, replacing the earlier text segmented
    /// control — matches the familiar Messages-style input switcher.
    @ViewBuilder
    private var inputModeToggle: some View {
        @Bindable var viewModel = viewModel

        HStack(spacing: 2) {
            toggleIcon("keyboard", mode: .text, binding: $viewModel.inputMode)
            toggleIcon("waveform", mode: .voice, binding: $viewModel.inputMode)
        }
        .padding(3)
        .background(Capsule().fill(Color(.systemGray5)))
    }

    private func toggleIcon(_ systemImage: String, mode: ConversationInputMode, binding: Binding<ConversationInputMode>) -> some View {
        let isSelected = binding.wrappedValue == mode
        return Button {
            binding.wrappedValue = mode
            if mode == .text {
                textFieldFocused = true
            }
        } label: {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(isSelected ? .white : BUITokens.Color.textPrimary)
                .frame(width: 36, height: 36)
                .background(Circle().fill(isSelected ? BUITokens.Color.contrastPrimary : .clear))
        }
        .buttonStyle(.plain)
    }

    private func submitDraft() {
        viewModel.submitText(draftText)
        draftText = ""
    }

    private func messageBubble(_ message: ConversationMessage) -> some View {
        HStack {
            if message.role == .user { Spacer(minLength: 40) }
            Text(message.text)
                .font(.system(size: 14))
                .foregroundStyle(message.role == .user ? Color.white : BUITokens.Color.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(message.role == .user ? BUITokens.Color.contrastPrimary : Color.white)
                        .shadow(color: BUITokens.Shadow.medium, radius: 12, x: 0, y: 4)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(message.role == .system ? BUITokens.Color.bluegreen.opacity(0.6) : .clear, lineWidth: 1)
                )
            if message.role != .user { Spacer(minLength: 40) }
        }
    }
}

#Preview {
    NavigationStack {
        VoiceConversationView()
    }
    .environment(Router())
    .environment(VoiceConversationViewModel())
}
