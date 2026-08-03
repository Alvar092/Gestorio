import SwiftUI

struct ClientsView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView("Próximamente", systemImage: "person.2", description: Text("La gestión de clientes estará disponible pronto."))
                .navigationTitle("Clientes")
        }
    }
}

#Preview {
    ClientsView()
}
