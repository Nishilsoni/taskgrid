import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: TaskStore
    @State private var selectedBoard: String = "Personal"
    @State private var showingAdd = false
    @AppStorage("isSignedIn") private var isSignedIn: Bool = false
    @State private var showingNewBoardAlert = false
    @State private var newBoardName: String = ""
    @State private var boardToDelete: String? = nil
    @State private var showingBoardDeleteConfirm: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                // background is always white
                Color.white.ignoresSafeArea()

                VStack(spacing: 0) {
                    // header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("TaskGrid").font(.largeTitle).bold().foregroundColor(.primary)
                            Text("Organize your day with style").font(.subheadline).foregroundColor(Color.secondary)
                        }
                        Spacer()
                        HStack(spacing: 12) {
                            // Profile menu using native Menu (system-like)
                            Menu {
                                Button(action: { Haptics.selection(); /* open profile */ }) {
                                    Label("Profile", systemImage: "person")
                                }
                                Button(action: { Haptics.selection(); /* open settings */ }) {
                                    Label("Settings", systemImage: "gearshape")
                                }
                                Button(action: { Haptics.selection(); /* open help */ }) {
                                    Label("Help & Feedback", systemImage: "questionmark.circle")
                                }
                                Divider()
                                Button(role: .destructive, action: {
                                    Haptics.notification(.warning)
                                    isSignedIn = false
                                }) {
                                    Label("Log out", systemImage: "arrow.backward.circle")
                                }
                            } label: {
                                Image(systemName: "person.crop.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 36, height: 36)
                                    .foregroundColor(.white)
                                    .background(Circle().fill(Color("Purple")))
                                    .overlay(Circle().fill(.ultraThinMaterial).opacity(0.25))
                                    .shadow(color: Color("Purple").opacity(0.25), radius: 6, x: 0, y: 3)
                            }

                            Button(action: { showingAdd = true }) {
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(
                                        ZStack {
                                            Circle().fill(Color("Primary"))
                                            Circle().fill(.ultraThinMaterial).opacity(0.4)
                                        }
                                    )
                                    .shadow(color: Color("Primary").opacity(0.28), radius: 6, x: 0, y: 3)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.vertical, 8)
                    .background(
                        // Apple-style frosted glass header with enhanced blur
                        ZStack {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.white.opacity(0.7))
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(.thinMaterial)
                                .opacity(0.5)
                        }
                        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 8)
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
                        .buttonStyle(AppButtonStyle(color: Color("Purple")))
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
                                            .fill(Color("Primary"))
                                    } else {
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color.white.opacity(0.6))
                                    }
                            }
                        )
            .foregroundColor(isSelected ? Color.white : Color.primary)
            .scaleEffect(isSelected ? 1.03 : 1.0)
            .animation(.spring(), value: isSelected)
    }
}
