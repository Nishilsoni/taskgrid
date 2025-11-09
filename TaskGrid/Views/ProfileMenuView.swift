import SwiftUI

struct ProfileMenuView: View {
    var onClose: () -> Void
    var onSettings: () -> Void
    var onProfile: () -> Void
    var onHelp: () -> Void
    var onLogout: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // header
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 44, height: 44)
                    .foregroundColor(Color("Primary"))
                    .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial).opacity(0.6))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Guest User").font(.headline)
                    Text("View & manage your profile").font(.caption).foregroundColor(.secondary)
                }
            }

            Divider()

            // menu items
            VStack(spacing: 6) {
                Button(action: { onProfile(); onClose() }) {
                    Label("Profile", systemImage: "person")
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: { onSettings(); onClose() }) {
                    Label("Settings", systemImage: "gearshape")
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: { onHelp(); onClose() }) {
                    Label("Help & Feedback", systemImage: "questionmark.circle")
                }
                .buttonStyle(PlainButtonStyle())
            }

            Divider()

            Button(action: { onLogout(); onClose() }) {
                HStack {
                    Image(systemName: "arrow.backward.circle.fill")
                    Text("Log out")
                        .foregroundColor(.red)
                }
            }
            .buttonStyle(PlainButtonStyle())

        }
        .padding(14)
        .frame(maxWidth: 260)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 14).fill(Color.white)
                RoundedRectangle(cornerRadius: 14).fill(.ultraThinMaterial).opacity(0.6)
            }
        )
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(UIColor.separator)))
        .shadow(color: Color.black.opacity(0.12), radius: 18, x: 0, y: 10)
    }
}

struct ProfileMenuView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileMenuView(onClose: {}, onSettings: {}, onProfile: {}, onHelp: {}, onLogout: {})
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
