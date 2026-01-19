import SwiftUI
import KMPNativeCoroutinesAsync
import Shared

struct ListView: View {
    @StateObject private var viewModelStoreOwner = IosViewModelStoreOwner()

    @State private var objects: [MuseumObject] = []

    // Android: GridCells.Adaptive(180.dp)
    let columns = [
        GridItem(.adaptive(minimum: 180), alignment: .top)
    ]

    private var viewModel: ListViewModel {
        viewModelStoreOwner.viewModel {
            ListViewModel(museumRepository: KoinDependencies().museumRepository)
        }
    }

    var body: some View {
        ZStack {
            if !objects.isEmpty {
                NavigationStack {
                    // Android: LazyVerticalGrid with contentPadding = WindowInsets.safeDrawing.asPaddingValues()
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 0) {
                            ForEach(objects, id: \.self) { item in
                                NavigationLink(value: item.objectID) {
                                    ObjectFrame(obj: item)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .navigationDestination(for: Int32.self) { objectId in
                        DetailView(objectId: objectId)
                    }
                }
            } else {
                EmptyScreenContent()
            }
        }
        .task {
            await observeObjects()
        }
    }

    @MainActor
    private func observeObjects() async {
        do {
            let stream = asyncSequence(for: viewModel.objectsFlow)
            for try await newObjects in stream {
                self.objects = newObjects
            }
        } catch {
            print("Failed observing objects: \(error)")
        }
    }
}

// Android: EmptyScreenContent(Modifier.fillMaxSize())
struct EmptyScreenContent: View {
    var body: some View {
        Text("No data available")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ObjectFrame: View {
    let obj: MuseumObject

    var body: some View {
        // Android: Column(modifier.padding(8.dp).clickable { onClick() })
        VStack(alignment: .leading) {
            // Android: AsyncImage with contentScale = ContentScale.Crop,
            //          Modifier.fillMaxWidth().aspectRatio(1f).background(Color.LightGray)
            Color(white: 0.9)
                .aspectRatio(1, contentMode: .fit)
                .overlay(
                    AsyncImage(url: URL(string: obj.primaryImageSmall)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        default:
                            EmptyView()
                        }
                    }
                )
                .clipped()

            // Android: Spacer(Modifier.height(2.dp))
            Spacer().frame(height: 2)

            // Android: Text(obj.title, style = MaterialTheme.typography.titleMedium)
            Text(obj.title)
                .font(.headline)

            // Android: Text(obj.artistDisplayName, style = MaterialTheme.typography.bodyMedium)
            Text(obj.artistDisplayName)
                .font(.subheadline)

            // Android: Text(obj.objectDate, style = MaterialTheme.typography.bodySmall)
            Text(obj.objectDate)
                .font(.caption)
        }
        .padding(8)
    }
}
