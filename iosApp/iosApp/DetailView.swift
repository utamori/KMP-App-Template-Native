import Foundation
import SwiftUI
import Shared
import KMPNativeCoroutinesAsync

struct DetailView: View {
    @StateObject private var viewModelStoreOwner = IosViewModelStoreOwner()

    @State private var museumObject: MuseumObject?

    let objectId: Int32

    private var viewModel: DetailViewModel {
        viewModelStoreOwner.viewModel {
            DetailViewModel(museumRepository: KoinDependencies().museumRepository)
        }
    }

    var body: some View {
        // Android: AnimatedContent(obj != null)
        ZStack {
            if let obj = museumObject {
                ObjectDetails(obj: obj)
            } else {
                EmptyScreenContent()
            }
        }
        .task {
            viewModel.setId(objectId: objectId)
            await observeMuseumObject()
        }
    }

    @MainActor
    private func observeMuseumObject() async {
        do {
            let stream = asyncSequence(for: viewModel.museumObjectFlow)
            for try await newObject in stream {
                self.museumObject = newObject
            }
        } catch {
            print("Failed observing museum object: \(error)")
        }
    }
}

struct ObjectDetails: View {
    var obj: MuseumObject

    var body: some View {
        // Android: Column(Modifier.verticalScroll(rememberScrollState()).padding(paddingValues))
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Android: AsyncImage with contentScale = ContentScale.FillWidth,
                //          Modifier.fillMaxWidth().background(Color.LightGray)
                AsyncImage(url: URL(string: obj.primaryImageSmall)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    default:
                        Color(white: 0.9)
                            .frame(height: 300)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color(white: 0.9))

                // Android: Column(Modifier.padding(12.dp))
                VStack(alignment: .leading, spacing: 0) {
                    // Android: Text(obj.title, style = MaterialTheme.typography.headlineMedium)
                    Text(obj.title)
                        .font(.title)

                    // Android: Spacer(Modifier.height(6.dp))
                    Spacer().frame(height: 6)

                    LabeledInfo(label: "Artist", data: obj.artistDisplayName)
                    LabeledInfo(label: "Date", data: obj.objectDate)
                    LabeledInfo(label: "Dimensions", data: obj.dimensions)
                    LabeledInfo(label: "Medium", data: obj.medium)
                    LabeledInfo(label: "Department", data: obj.department)
                    LabeledInfo(label: "Repository", data: obj.repository)
                    LabeledInfo(label: "Credits", data: obj.creditLine)
                }
                .padding(12)
            }
        }
    }
}

struct LabeledInfo: View {
    var label: String
    var data: String

    var body: some View {
        // Android: Column(modifier.padding(vertical = 4.dp))
        VStack(alignment: .leading) {
            // Android: Spacer(Modifier.height(6.dp))
            Spacer().frame(height: 6)

            // Android: Text with SpanStyle(fontWeight = FontWeight.Bold) for label
            Text("**\(label):** \(data)")
        }
        .padding(.vertical, 4)
    }
}
