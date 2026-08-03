import SwiftUI

struct InvoicesView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView("Próximamente", systemImage: "doc.text", description: Text("Facturas y gastos estarán disponibles pronto."))
                .navigationTitle("Facturas")
        }
    }
}

#Preview {
    InvoicesView()
}
