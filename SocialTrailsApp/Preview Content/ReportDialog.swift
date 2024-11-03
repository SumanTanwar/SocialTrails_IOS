import SwiftUI

struct ReportPopup: View {
    @Binding var isPresented: Bool
    @State private var reportReason: String = ""
    @State private var alertMessage: String?
    @State private var showAlert = false
    var reportedId: String
    var reportType: String
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Text("Report Issue")
                    .font(.headline)
                    .padding()

                Text("Why are you reporting?")
                    .font(.subheadline)

                Text("Your report is anonymous. If someone is in immediate danger, call the local emergency service.")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true) 

                
                    TextEditor(text: $reportReason)
                        .frame(height: 100)
                        .padding(5)
                        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                

                HStack {
                    Button("Report") {
                        addReport()
                    }
                    .buttonStyle(.bordered)
                    .disabled(reportReason.trimmingCharacters(in: .whitespaces).isEmpty)

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

    private func addReport() {
        if reportReason.trimmingCharacters(in: .whitespaces).isEmpty {
            alertMessage = "Please enter a reason for reporting."
            showAlert = true
            return
        }

        let report = Report(reporterId: SessionManager.shared.getCurrentUser()?.id ?? "",
                            reportedId: reportedId,
                                                       reportType: reportType,
                            reason: reportReason)

        let reportService = ReportService()
        reportService.addReport(data: report) { result in
            switch result {
            case .success:
                alertMessage = "Report submitted successfully!"
                showAlert = true
                isPresented = false
            case .failure(let error):
                alertMessage = "Failed to submit report: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
}


