import SwiftUI
import Firebase
import FirebaseAuth

struct SignUpView: View {
    @State private var userName: String = ""
    @State private var emailAddress: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isTermsAccepted: Bool = false
    @State private var isPasswordVisible: Bool = false
    @State private var isConfPasswordVisible: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var navigateToSignIn = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Image("socialtrails_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding(10)
                    .padding(.top,50)
                
                Text("Start Your Journey")
                    .font(.custom("Snell Roundhand", size: 20).bold())
                    .foregroundColor(Color(.purple))
                    .multilineTextAlignment(.leading)
                   
                    .padding(.leading,30)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 15) {
                    TextField("User Name", text: $userName)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    
                  
                    TextField("Email Address", text: $emailAddress)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    
                    HStack {
                        if isPasswordVisible {
                            TextField("Password", text: $password)
                                .padding()
                        } else {
                            SecureField("Password", text: $password)
                                .padding()
                        }
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                                .padding(10)
                        }
                    }
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    
                    HStack {
                        if isConfPasswordVisible {
                            TextField("Confirm Password", text: $confirmPassword)
                                .padding()
                        } else {
                            SecureField("Confirm Password", text: $confirmPassword)
                                .padding()
                        }
                        Button(action: {
                            isConfPasswordVisible.toggle()
                        }) {
                            Image(systemName: isConfPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                                .padding(10)
                        }
                    }
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                }
                .padding(.horizontal, 30)
               
                HStack {
                    Button(action: {
                        isTermsAccepted.toggle()
                    }) {
                        Image(systemName: isTermsAccepted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(isTermsAccepted ? .green : .gray)
                    }
                    Text("I accept the terms and conditions.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)
                
                Spacer()
                
                Button(action: {
                    registerUser()
                }) {
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .cornerRadius(10)
                        .padding(.horizontal, 30)
                }
                .padding(.vertical, 20)
                
                HStack {
                    Text("Got a profile?")
                        .foregroundColor(.gray)
                        .italic()
                    
                    NavigationLink(destination: SplashScreenView(), isActive: $navigateToSignIn) {
                        Text("Sign In")
                            .italic()
                            .foregroundColor(.blue)
                    }
                }
                Text("By registering, I acknowledge that I have read and accept the General Terms and conditions of Use and the privacy policy.")
                               .font(.footnote)
                               .padding(.top, 35)
                               .multilineTextAlignment(.leading)
                               .padding(.horizontal, 10)
                               .lineLimit(nil)
                               .fixedSize(horizontal: false, vertical: true)

                Spacer()
                .padding(.bottom, 90)
            }
            .background(Color.white)
            .navigationBarHidden(true) // Hide the navigation bar
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Registration Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func registerUser() {
       
        showAlert = false
        alertMessage = ""
        
        
        if userName.isEmpty {
            showAlert(message: "User name is required.")
            return
        }

        
        if emailAddress.isEmpty {
            showAlert(message: "Email is required.")
            return
        } else if !Utils.isValidEmail(emailAddress) {
            showAlert(message: "Invalid email address.")
            return
        }

       
        if password.isEmpty {
            showAlert(message: "Password is required.")
            return
        } else if password.count < 8 {
            showAlert(message: "Password should be more than 8 characters.")
            return
        } else if !Utils.isPasswordValid(password) {
            showAlert(message: "Password must contain at least one letter and one digit.")
            return
        }

    
        if confirmPassword.isEmpty {
            showAlert(message: "Please confirm your password.")
            return
        } else if password != confirmPassword {
            showAlert(message: "Passwords do not match.")
            return
        }

      
        if !isTermsAccepted {
            showAlert(message: "Please accept the terms and conditions.")
            return
        }

        
        Auth.auth().createUser(withEmail: emailAddress, password: password) { authResult, error in
            if let error = error as NSError? {
                DispatchQueue.main.async {
                    let errorCode = error.code
                    switch errorCode {
                    case AuthErrorCode.emailAlreadyInUse.rawValue:
                        showAlert(message: "The email address is already in use.")
                    case AuthErrorCode.weakPassword.rawValue:
                        showAlert(message: "The password is too weak.")
                    default:
                        showAlert(message: error.localizedDescription)
                    }
                }
                return
            }
            print("User creation started")

            if let user = authResult?.user {
                print("innside creation started")

                // Send email verification
                user.sendEmailVerification { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("failed creation started")

                            showAlert(message: "Failed to send verification email: \(error.localizedDescription)")
                            return
                        }

                        print("send creation started")

                        let userID = user.uid
                        var newUser = Users(userId: userID, username: userName, email: emailAddress, roles: UserRole.user.role)
                        UserManager().registerUser(_user: &newUser) { success in
                            if success {
                                showAlert(message: "User registered successfully. Please verify your email.")
                                navigateToSignIn = true
                            } else {
                                showAlert(message: "Failed to register user in the system.")
                            }
                        }
                    }
                }
            }
        }
    }

    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
