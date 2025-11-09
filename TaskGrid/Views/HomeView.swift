import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: TaskStore
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @State private var selectedBoard: String = "Personal"
    @State private var showingAdd = false
    @State private var showingNewBoardAlert = false
    @State private var newBoardName: String = ""
    @State private var boardToDelete: String? = nil
    @State private var showingBoardDeleteConfirm: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                // background follows system color scheme (light/dark toggle)
                Color(UIColor.systemBackground).ignoresSafeArea()

                VStack(spacing: 0) {
                    // header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("TaskGrid").font(.largeTitle).bold().foregroundColor(.primary)
                            Text("Organize your day with style").font(.subheadline).foregroundColor(Color.secondary)
                        }
                        Spacer()
                        HStack(spacing: 12) {
                            Button(action: {
                                isDarkMode.toggle()
                                Haptics.selection()
                            }) {
                                Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                                    .foregroundColor(Color("Primary"))
                                    .padding(8)
                                    .background(Circle().fill(Color("Primary").opacity(0.08)))
                            }

                            Button(action: { showingAdd = true }) {
                                Image(systemName: "plus")
                                    .foregroundColor(Color("Primary"))
                                    .padding(10)
                                    .background(Circle().fill(Color("Primary").opacity(0.12)))
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.vertical, 8)
                    .background(
                        // subtle material behind header for premium feel
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color(UIColor.systemBackground).opacity(0.8))
                            .background(.ultraThinMaterial)
                            .blur(radius: 0.6)
                            .shadow(color: Color(UIColor.separator).opacity(0.06), radius: 8, x: 0, y: 6)
                    )
                    .padding(.horizontal)

                    VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(store.boards, id: \.self) { b in
                            BoardPill(title: b, isSelected: b == selectedBoard)
                                .onTapGesture {
                                    withAnimation(.spring()) { selectedBoard = b }
                                    Haptics.selection()
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        // request confirmation via state
                                        boardToDelete = b
                                        showingBoardDeleteConfirm = true
                                    } label: {
                                        Label("Delete Board", systemImage: "trash")
                                    }
                                    .disabled(store.boards.count <= 1)
                                }
                        }
                        Button(action: { showingNewBoardAlert = true; Haptics.selection() }) {
                            HStack { Image(systemName: "plus.circle"); Text("Board") }
                        }
                        .buttonStyle(AppButtonStyle())
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }

                Divider().background(Color(UIColor.separator)).padding(.horizontal)

                BoardView(boardName: selectedBoard)
                    .environmentObject(store)
                    .padding(.top, 6)
            }
            }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAdd) {
                AddTaskView(prefillBoard: selectedBoard) { newTask in
                    store.add(newTask)
                    showingAdd = false
                }
                .environmentObject(store)
            }
            .alert("New Board", isPresented: $showingNewBoardAlert, actions: {
                TextField("Board name", text: $newBoardName)
                Button("Create") {
                    let name = newBoardName.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !name.isEmpty else { return }
                    if !store.boards.contains(name) { store.boards.append(name) }
                    newBoardName = ""
                }
                Button("Cancel", role: .cancel) { newBoardName = "" }
            }, message: { Text("Create a new board to organize tasks") })
            .alert("Delete Board", isPresented: $showingBoardDeleteConfirm, actions: {
                Button("Delete", role: .destructive) {
                    if let name = boardToDelete {
                        store.removeBoard(name)
                        // ensure selectedBoard moves to an existing board
                        selectedBoard = store.boards.first ?? "Personal"
                        Haptics.notification(.success)
                    }
                    boardToDelete = nil
                }
                Button("Cancel", role: .cancel) { boardToDelete = nil }
            }, message: { Text("Delete this board? Tasks on this board will be moved to another board.") })
            .onAppear {
                if !store.boards.contains(selectedBoard) { selectedBoard = store.boards.first ?? "Personal" }
            }
        }
    }
}

struct BoardPill: View {
    var title: String
    var isSelected: Bool
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Text(title)
            .font(.system(size: 15, weight: .semibold))
            .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(
                            Group {
                                    if isSelected {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(LinearGradient(colors: [Color("Primary"), Color("Secondary")], startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .opacity(colorScheme == .dark ? 0.16 : 0.95)
                                    } else {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color(UIColor.systemBackground).opacity(0.06))
                                    }
                            }
                        )
            .foregroundColor(isSelected ? Color.white : Color.primary)
            .scaleEffect(isSelected ? 1.03 : 1.0)
            .animation(.spring(), value: isSelected)
    }
}
