import SwiftUI

struct ActivityView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView("Próximamente", systemImage: "list.bullet.rectangle", description: Text("Aquí verás tus facturas y gastos."))
                .navigationTitle("Actividad")
        }
    }
}

#Preview {
    ActivityView()
}
