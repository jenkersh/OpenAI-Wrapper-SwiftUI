import SwiftUI

struct HomeView: View {
    @State private var savedChats: [ChatModel] = []
    @State private var path = NavigationPath()

    let spacing: CGFloat = 30

    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { geometry in
                let sidePadding = spacing
                let columns = [
                    GridItem(.flexible(), spacing: spacing),
                    GridItem(.flexible(), spacing: spacing)
                ]

                // Calculate tile width to fit 2 columns with spacing and padding
                let totalSpacing = spacing + sidePadding * 2
                let tileWidth = (geometry.size.width - totalSpacing) / 2

                ZStack {
                    ScrollView {
                        VStack(alignment: .leading, spacing: spacing) {
                            Text("My Antiques")
                                .font(.system(size: geometry.size.width * 0.08, weight: .bold, design: .rounded))
                                .padding(.top)
                                .padding(.horizontal, sidePadding)

                            if savedChats.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "shippingbox.fill")
                                        .font(.system(size: 48))
                                        .foregroundColor(.gray)
                                    Text("No antiques yet.")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                    Text("Tap 'Identify!' to start.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, geometry.size.height * 0.1)
                            } else {
                                LazyVGrid(columns: columns, spacing: spacing) {
                                    ForEach(savedChats) { chat in
                                        NavigationLink(destination: ChatView(isPresented: .constant(false), chat: chat)) {
                                            ZStack(alignment: .bottom) {
                                                if let image = chat.messages.first?.image {
                                                    Image(uiImage: image)
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width: tileWidth, height: tileWidth)
                                                        .clipped()
                                                } else {
                                                    ZStack {
                                                        Rectangle()
                                                            .fill(Color.gray.opacity(0.1))
                                                        Image(systemName: "photo")
                                                            .font(.largeTitle)
                                                            .foregroundColor(.gray)
                                                    }
                                                    .frame(width: tileWidth, height: tileWidth)
                                                }

                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(chat.title ?? "Untitled")
                                                        .font(.headline)
                                                        .lineLimit(1)
                                                        .foregroundColor(.white)
                                                    Text(chat.date.formatted(date: .abbreviated, time: .shortened))
                                                        .font(.caption2)
                                                        .foregroundColor(.white.opacity(0.8))
                                                }
                                                .padding(8)
                                                .frame(width: tileWidth, alignment: .leading)
                                                .background(Color.black.opacity(0.5).blur(radius: 10))
                                            }
                                            .cornerRadius(12)
                                            .shadow(radius: 3)
                                        }
                                    }
                                }
                                .padding(.horizontal, sidePadding)
                                .padding(.bottom, 100) // space for bottom bar
                            }

                            Spacer(minLength: 80)
                        }
                        .padding(.top)
                    }

                    // Bottom overlay bar with Identify button centered
                    VStack {
                        Spacer()
                        ZStack {
                            BlurView(style: .systemUltraThinMaterialLight)
                                .frame(height: 100)
                                .edgesIgnoringSafeArea(.bottom)
                            Button(action: {
                                path.append("identify")
                            }) {
                                Label("Identify!", systemImage: "camera.viewfinder")
                                    .font(.headline)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 32)
                                    .background(Color.accentColor)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                                    .shadow(radius: 5)
                            }
                            .padding(.bottom, 20)
                        }
                        
                    }
                    .ignoresSafeArea(edges: .bottom)
                }
                .navigationDestination(for: String.self) { value in
                    if value == "identify" {
                        ContentView()
                    }
                }
                .onAppear {
                    var chats = ChatStorage.shared.loadChats()

                    // Load image for each chat if missing
                    for i in chats.indices {
                        if chats[i].messages.first?.image == nil,
                           let message = chats[i].messages.first {
                            let filename = "\(message.id).jpg"
                            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                                let url = documentsDirectory.appendingPathComponent(filename)
                                if let data = try? Data(contentsOf: url),
                                   let image = UIImage(data: data) {
                                    chats[i].messages[0].image = image
                                }
                            }
                        }
                    }

                    savedChats = chats
                }
            }
        }
    }

    func deleteChats(at offsets: IndexSet) {
        offsets.forEach { i in
            ChatStorage.shared.deleteChat(savedChats[i])
        }
        savedChats.remove(atOffsets: offsets)
    }
}

// Helper for blur background
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemMaterial

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

#Preview {
    HomeView()
}
