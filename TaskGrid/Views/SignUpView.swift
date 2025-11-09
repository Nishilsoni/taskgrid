import SwiftUI

struct SignUpView: View {
    @AppStorage("isSignedIn") private var isSignedIn: Bool = false
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var company: String = ""
    @State private var password: String = ""
    @State private var confirm: String = ""
    @State private var acceptTerms: Bool = false
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                // card
                VStack(spacing: 12) {
                    HStack { Image(systemName: "person.crop.circle.fill").foregroundColor(Color("Primary")); TextField("Full name", text: $fullName) }
                        .padding().background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

                    HStack { Image(systemName: "envelope.fill").foregroundColor(.secondary); TextField("Email", text: $email).keyboardType(.emailAddress).autocapitalization(.none) }
                        .padding().background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

                    HStack { Image(systemName: "phone.fill").foregroundColor(.secondary); TextField("Phone (optional)", text: $phone).keyboardType(.phonePad) }
                        .padding().background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

                    HStack { Image(systemName: "lock.fill").foregroundColor(.secondary); SecureField("Password", text: $password) }
                        .padding().background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

                    HStack { Image(systemName: "lock.fill").foregroundColor(.secondary); SecureField("Confirm password", text: $confirm) }
                        .padding().background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))

                    Toggle(isOn: $acceptTerms) {
                        Text("I agree to the Terms & Privacy")
                            .font(.caption)
                    }
                    .padding(.horizontal)

                    Button(action: register) {
                        HStack { Spacer(); Text("Create account"); Spacer() }
                    }
                    .buttonStyle(AppButtonStyle(color: Color("Orange")))
                    .padding(.horizontal, 12)
                    .disabled(!formIsValid)

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

                Spacer()
            }
            .padding(.top, 8)
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private var formIsValid: Bool {
        !fullName.isEmpty && email.contains("@") && password.count >= 6 && password == confirm && acceptTerms
    }

    private func register() {
        guard formIsValid else {
            alertMessage = "Please complete the form and accept the terms."
            showingAlert = true
            return
        }
        // placeholder: replace with Firebase createUser
        Haptics.notification(.success)
        isSignedIn = true
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
