import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Privacy Policy")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)

                Text("Last updated: 30-09-2024")
                    .font(.system(size: 14, weight: .bold))

                Text("SocialTrails collects, uses, and protects your information when you use our app.")
                    .font(.system(size: 14))

                Text("Information We Collect")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)

                Text("""
                - We may collect personal information such as your name, email address, and profile information when you create an account or interact with our app.
                - We use cookies and similar technologies to enhance your experience and analyze usage patterns.
                """)

                Text("How We Use Your Information")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)

                Text("""
                - To provide and maintain our app
                - To notify you about changes to our app
                - To allow you to participate in interactive features
                - To provide customer support
                - To gather analysis so we can improve our app
                """)

                Text("Sharing Your Information")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)

                Text("We do not sell or rent your personal information to third parties. We may share your information in the following circumstances:")

                Text("""
                - With service providers to assist us in operating our app
                - To comply with legal obligations
                - To protect and defend our rights
                """)

                Text("Data Security")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)

                Text("We take data security seriously and implement reasonable measures to protect your information from unauthorized access, use, or disclosure.")

                Text("Changes to the Privacy Policy")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)

                Text("We may update our Privacy Policy from time to time.")

                Text("Contact Information")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)

                Text("For questions, contact us at: \n - Email: socialtrails2024@gmail.com")

                Button(action: {
                                   presentationMode.wrappedValue.dismiss() // Dismiss the current view
                               }) {
                                   Text("Back")
                                       .font(.system(size: 15, weight: .bold))
                                       .foregroundColor(.purple)
                               }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .padding(10)
        }
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyView()
    }
}
