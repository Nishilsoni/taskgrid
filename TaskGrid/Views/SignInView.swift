import SwiftUI

struct SignInView: View {
    @AppStorage("isSignedIn") private var isSignedIn: Bool = false
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        VStack(spacing: 18) {
            // modern glass card
            VStack(spacing: 14) {
                

                // email field
                HStack(spacing: 12) {
                    Image(systemName: "mail")
                        .foregroundColor(.secondary)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

                // password field
                HStack(spacing: 12) {
                    Image(systemName: "lock")
                        .foregroundColor(.secondary)
                    if showPassword {
                        TextField("Password", text: $password)
                            .autocapitalization(.none)
                    } else {
                        SecureField("Password", text: $password)
                    }
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

                // forgot + sign in
                HStack {
                    Button(action: {
                        // placeholder for forgot
                    }) {
                        Text("Forgot password?").font(.caption).foregroundColor(.secondary)
                    }
                    Spacer()
                }

                Button(action: signIn) {
                    HStack { Spacer(); Text("Sign In"); Spacer() }
                }
                .buttonStyle(AppButtonStyle(color: Color("Primary")))
                .disabled(email.isEmpty || password.isEmpty)

            }
            .padding(18)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 16).fill(Color.white)
                    RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial).opacity(0.5)
                }
            )
            .padding(.horizontal, 18)
            .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 8)


        }
        .padding(.top, 8)
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func signIn() {
        // placeholder: simple validation; replace with Firebase in future
        guard email.contains("@") && password.count >= 6 else {
            alertMessage = "Please enter a valid email and a password with at least 6 characters."
            showingAlert = true
            return
        }

        // Simulate signed-in state
        Haptics.notification(.success)
        isSignedIn = true
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
