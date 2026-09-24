import SwiftUI

struct VoiceConversationView: View {
    @Environment(Router.self) private var router
    @State private var viewModel = VoiceConversationViewModel()
    @State private var draftText = ""
    @FocusState private var textFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if viewModel.messages.isEmpty {
                        Text("Tap the orb and ask about your day — \"who's my next appointment?\", \"how many appointments today?\"")
                            .font(Tokens.Typography.bodyRegular)
                            .foregroundStyle(Tokens.Color.textTertiary)
                            .padding(.top, 24)
                    }
                    ForEach(viewModel.messages) { message in
                        messageBubble(message)
                    }
                }
                .padding(24)
            }

            Divider()

            VStack(spacing: 14) {
                Picker("Input mode", selection: $viewModel.inputMode) {
                    Text("Voice").tag(ConversationInputMode.voice)
                    Text("Text").tag(ConversationInputMode.text)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 24)

                if viewModel.inputMode == .voice {
                    Button {
                        viewModel.isListening ? viewModel.stopListening() : viewModel.startListening()
                    } label: {
                        VoiceOrb(size: 72, level: viewModel.audioLevel)
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 24)
                } else {
                    HStack(spacing: 10) {
                        TextField("Ask something…", text: $draftText)
                            .textFieldStyle(.roundedBorder)
                            .focused($textFieldFocused)
                            .onSubmit(submitDraft)
                        Button("Send", action: submitDraft)
                            .disabled(draftText.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
            }
        }
        .background(Tokens.Color.background)
        .navigationTitle("Assistant")
        .navigationBarTitleDisplayMode(.inline)
        .backIconButton { router.pop() }
        .alert("Voice assistant", isPresented: .constant(viewModel.errorMessage != nil), presenting: viewModel.errorMessage) { _ in
            Button("OK") { viewModel.errorMessage = nil }
        } message: { message in
            Text(message)
        }
    }

    private func submitDraft() {
        viewModel.submitText(draftText)
        draftText = ""
    }

    private func messageBubble(_ message: ConversationMessage) -> some View {
        HStack {
            if message.role == .user { Spacer(minLength: 40) }
            Text(message.text)
                .font(Tokens.Typography.bodyRegular)
                .foregroundStyle(message.role == .user ? Tokens.Color.paper : Tokens.Color.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(message.role == .user ? Tokens.Color.onyx : Tokens.Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(
                            message.role == .system ? Tokens.Color.ochre.opacity(0.55)
                                : message.role == .user ? .clear : Tokens.Color.hairline
                        )
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
}
