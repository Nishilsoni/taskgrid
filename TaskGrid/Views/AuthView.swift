import SwiftUI

/// Simple container that switches between Sign In and Sign Up forms.
struct AuthView: View {
    @EnvironmentObject var store: TaskStore
    @AppStorage("isSignedIn") private var isSignedIn: Bool = false
    @State private var selection: Int = 0 // 0 = Sign In, 1 = Sign Up

    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer().frame(height: 40)

                    // App title / logo
                    VStack(spacing: 6) {
                        Text("TaskGrid")
                            .font(.system(size: 36, weight: .bold))
                        Text("Sign in to continue")
                            .foregroundColor(.secondary)
                    }

                    // segmented control to switch between Sign In and Sign Up
                    Picker("Auth", selection: $selection) {
                        Text("Sign In").tag(0)
                        Text("Sign Up").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 36)

                    // Forms
                    if selection == 0 {
                        SignInView()
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    } else {
                        SignUpView()
                            .transition(.move(edge: .leading).combined(with: .opacity))
                    }

                    Spacer()

                    HStack(spacing: 8) {
                        Text("By continuing you agree to our")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Button("Terms") { }
                            .font(.caption).foregroundColor(Color("Primary"))
                    }
                    .padding(.bottom, 20)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
            .environmentObject(TaskStore())
    }
}
