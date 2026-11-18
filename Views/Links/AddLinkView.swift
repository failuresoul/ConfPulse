import SwiftUI

struct AddLinkView: View {
    @ObservedObject var viewModel: LinkViewModel
    @EnvironmentObject private var auth: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var url = ""
    @State private var type: LinkType = .paper
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Link") {
                    TextField("Title", text: $title)
                    TextField("URL, e.g. arxiv.org/abs/1234.5678", text: $url)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                Section("Type") {
                    Picker("Type", selection: $type) {
                        ForEach(LinkType.allCases, id: \.self) { type in
                            Label(type.rawValue.capitalized, systemImage: type.symbol).tag(type)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
                if let message = viewModel.errorMessage {
                    Text(message).foregroundStyle(.red)
                }
            }
            .navigationTitle("New Link")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { Task { await save() } }
                        .disabled(title.isEmpty || url.isEmpty || isSaving)
                }
            }
            .onAppear { viewModel.errorMessage = nil }
        }
    }

    // Saves the link for the signed-in user and closes the sheet on success
    private func save() async {
        guard let user = auth.currentUser else { return }
        isSaving = true
        let saved = await viewModel.addLink(title: title, url: url, type: type, me: user)
        isSaving = false
        if saved { dismiss() }
    }
}
