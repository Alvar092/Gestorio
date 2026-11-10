import Foundation

@MainActor
@Observable
final class ClientFormViewModel {
    private let createClientUseCase: CreateClientUseCaseProtocol
    private let updateClientUseCase: UpdateClientUseCaseProtocol
    private let editingClient: Client?

    var name: String
    var taxID: String
    var street: String
    var postalCode: String
    var city: String
    var province: String
    var email: String
    var phone: String
    var notes: String
    var errorMessage: String?

    init(
        client: Client?,
        createClientUseCase: CreateClientUseCaseProtocol,
        updateClientUseCase: UpdateClientUseCaseProtocol
    ) {
        self.editingClient = client
        self.createClientUseCase = createClientUseCase
        self.updateClientUseCase = updateClientUseCase
        self.name = client?.name ?? ""
        self.taxID = client?.taxID ?? ""
        self.street = client?.billingAddress.street ?? ""
        self.postalCode = client?.billingAddress.postalCode ?? ""
        self.city = client?.billingAddress.city ?? ""
        self.province = client?.billingAddress.province ?? ""
        self.email = client?.email ?? ""
        self.phone = client?.phone ?? ""
        self.notes = client?.notes ?? ""
    }

    convenience init(client: Client? = nil) {
        self.init(
            client: client,
            createClientUseCase: CreateClientUseCase(),
            updateClientUseCase: UpdateClientUseCase()
        )
    }

    var isEditing: Bool { editingClient != nil }

    var title: String { isEditing ? "Editar cliente" : "Nuevo cliente" }

    var canSave: Bool {
        !trimmed(name).isEmpty && !trimmed(taxID).isEmpty
    }

    /// Devuelve `true` si se guardó correctamente.
    func save() -> Bool {
        guard canSave else { return false }
        let client = Client(
            id: editingClient?.id ?? UUID(),
            name: trimmed(name),
            taxID: trimmed(taxID),
            billingAddress: BillingAddress(
                street: trimmed(street),
                postalCode: trimmed(postalCode),
                city: trimmed(city),
                province: trimmed(province)
            ),
            email: nilIfEmpty(email),
            phone: nilIfEmpty(phone),
            notes: nilIfEmpty(notes)
        )
        do {
            if isEditing {
                _ = try updateClientUseCase.updateClient(client)
            } else {
                _ = try createClientUseCase.createClient(client)
            }
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    private func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func nilIfEmpty(_ value: String) -> String? {
        let result = trimmed(value)
        return result.isEmpty ? nil : result
    }
}
