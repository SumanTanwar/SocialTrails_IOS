import SwiftUI

struct WarningPopup: View {
    @Binding var isPresented: Bool
    @State private var warningReason: String = ""
    @State private var alertMessage: String?
    @State private var showAlert = false
    var warningId: String
    var warningType: String

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("Issue Warning")
                    .font(.headline)
                    .padding()

                Text("Why are you issuing this warning?")
                    .font(.subheadline)

                Text("Your warning is anonymous. If someone is in immediate danger, call the local emergency service.")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)

                TextEditor(text: $warningReason)
                    .frame(height: 100)
                    .padding(5)
                    .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)

                HStack {
                    Button("Submit Warning") {
                        addWarning()
                    }
                    .buttonStyle(.bordered)
                    .disabled(warningReason.trimmingCharacters(in: .whitespaces).isEmpty)

                    Button("Cancel") {
                        isPresented = false
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.bottom)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 20)
            .frame(maxWidth: 400)
            .padding(40)
            Spacer()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Notification"), message: Text(alertMessage ?? "An error occurred."), dismissButton: .default(Text("OK")))
        }
    }

    private func addWarning() {
        if warningReason.trimmingCharacters(in: .whitespaces).isEmpty {
            alertMessage = "Please enter a reason for reporting."
            showAlert = true
            return
        }

        let currentUser = SessionManager.shared.getCurrentUser() // Get the current user
        let warning = IssueWarning(
            issuewarnby: currentUser?.id ?? "", // User ID of the person issuing the warning
            issuewarnto: warningId, // User ID of the person being warned
            issuewarnId: UUID().uuidString, // Generate a new UUID for warningId
            warningtype: warningType, // Type of warning
            reason: warningReason, // Reason for the warning
            username: currentUser?.username // Pass the username if available
        )

        let warningService = IssueWarningService()
        warningService.addWarning(data: warning) { result in
            switch result {
            case .success:
                alertMessage = "Warning submitted successfully!"
                showAlert = true
                isPresented = false
            case .failure(let error):
                alertMessage = "Failed to submit warning: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
}
