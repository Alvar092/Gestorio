import SwiftUI

/// Detalle de un gasto (factura recibida). Los gastos no entran en la cadena de hash, así que son editables.
struct ExpenseDetailView: View {
    let expense: Expense
    let onSaved: () -> Void
    @State private var isEditing = false

    var body: some View {
        Form {
            Section("Factura") {
                LabeledContent("Fecha", value: expense.date.formatted(date: .long, time: .omitted))
                Text(expense.concept)
            }

            Section("Emisor (proveedor)") {
                LabeledContent("Nombre", value: expense.issuerName)
                LabeledContent("NIF / CIF", value: expense.issuerTaxID)
            }

            Section("Destinatario (tú)") {
                LabeledContent("Nombre", value: expense.recipientName)
                LabeledContent("NIF / CIF", value: expense.recipientTaxID)
            }

            Section("Importe") {
                TaxBreakdownRows(
                    breakdown: TaxBreakdown(base: expense.taxBase, vatRate: expense.vatRate, irpfRate: expense.irpfRate)
                )
            }
        }
        .navigationTitle("Gasto")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Editar") { isEditing = true }
            }
        }
        .sheet(isPresented: $isEditing) {
            ActivityEntryFormView(kind: .expense, editing: expense, onSave: onSaved)
        }
    }
}
