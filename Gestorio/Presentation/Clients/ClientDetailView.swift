import SwiftUI

struct ClientDetailView: View {
    let client: Client
    let onSaved: () -> Void
    @State private var isEditing = false

    var body: some View {
        Form {
            Section("Datos fiscales") {
                LabeledContent("Nombre", value: client.name)
                LabeledContent("NIF / CIF", value: client.taxID)
            }

            Section("Dirección de facturación") {
                LabeledContent("Calle", value: displayed(client.billingAddress.street))
                LabeledContent("Código postal", value: displayed(client.billingAddress.postalCode))
                LabeledContent("Ciudad", value: displayed(client.billingAddress.city))
                LabeledContent("Provincia", value: displayed(client.billingAddress.province))
            }

            Section("Contacto") {
                LabeledContent("Email", value: displayed(client.email))
                LabeledContent("Teléfono", value: displayed(client.phone))
            }

            if let notes = client.notes {
                Section("Notas") {
                    Text(notes)
                }
            }
        }
        .navigationTitle(client.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Editar") { isEditing = true }
            }
        }
        .sheet(isPresented: $isEditing) {
            ClientFormView(client: client, onSave: onSaved)
        }
    }

    private func displayed(_ value: String?) -> String {
        guard let value, !value.isEmpty else { return "—" }
        return value
    }
}
