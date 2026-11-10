import SwiftUI

struct ClientsView: View {
    @State private var viewModel = ClientsViewModel()
    @State private var isCreating = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.clients.isEmpty {
                    ContentUnavailableView("Sin clientes", systemImage: "person.2", description: Text("Pulsa + para crear tu primer cliente."))
                } else {
                    List(viewModel.clients) { client in
                        NavigationLink(value: client.id) {
                            Text(client.name)
                        }
                    }
                }
            }
            .navigationTitle("Clientes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Nuevo cliente", systemImage: "plus") {
                        isCreating = true
                    }
                }
            }
            .navigationDestination(for: UUID.self) { id in
                if let client = viewModel.client(id: id) {
                    ClientDetailView(client: client, onSaved: viewModel.load)
                }
            }
            .sheet(isPresented: $isCreating) {
                ClientFormView(onSave: viewModel.load)
            }
        }
        .task {
            viewModel.load()
        }
    }
}

#Preview {
    ClientsView()
}
