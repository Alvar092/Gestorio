import Foundation

/// Formulario para rectificar una factura emitida. La original nunca se modifica:
/// se crea una `CorrectiveInvoice` que la referencia por número y hash.
@MainActor
@Observable
final class CorrectiveInvoiceFormViewModel {
    enum Mode: String, CaseIterable, Identifiable {
        case full
        case partial

        var id: String { rawValue }

        var title: String {
            switch self {
            case .full: "Anulación total"
            case .partial: "Importe parcial"
            }
        }
    }

    let original: Invoice
    private let createCorrectiveInvoiceUseCase: CreateCorrectiveInvoiceUseCaseProtocol

    var mode: Mode = .full
    var amountText = ""
    var concept: String
    var errorMessage: String?

    init(original: Invoice, createCorrectiveInvoiceUseCase: CreateCorrectiveInvoiceUseCaseProtocol) {
        self.original = original
        self.createCorrectiveInvoiceUseCase = createCorrectiveInvoiceUseCase
        self.concept = "Rectificación de la factura \(original.number)"
    }

    convenience init(original: Invoice) {
        self.init(original: original, createCorrectiveInvoiceUseCase: CreateCorrectiveInvoiceUseCase())
    }

    var amount: Decimal? { DecimalInput.parse(amountText) }

    /// Importe de la rectificativa: siempre negativo (reduce lo facturado).
    var correctionTotal: Decimal? {
        switch mode {
        case .full: -original.totalPrice
        case .partial: amount.map { -$0 }
        }
    }

    var canSave: Bool {
        guard !concept.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let total = correctionTotal else { return false }
        return total < 0 && total >= -original.totalPrice
    }

    func sanitizeAmountText() {
        let sanitized = DecimalInput.sanitize(amountText)
        if sanitized != amountText { amountText = sanitized }
    }

    /// Devuelve `true` si se guardó correctamente.
    func save() -> Bool {
        guard canSave, let total = correctionTotal else { return false }
        do {
            _ = try createCorrectiveInvoiceUseCase.create(CorrectiveInvoice(
                number: "",
                date: .now,
                clientName: original.clientName,
                clientTaxID: original.clientTaxID,
                concept: concept.trimmingCharacters(in: .whitespacesAndNewlines),
                totalPrice: total,
                originalInvoiceNumber: original.number,
                originalInvoiceHash: original.hash
            ))
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
