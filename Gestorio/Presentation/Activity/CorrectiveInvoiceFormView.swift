import SwiftUI

struct CorrectiveInvoiceFormView: View {
    @State private var viewModel: CorrectiveInvoiceFormViewModel
    @Environment(\.dismiss) private var dismiss
    private let onSave: () -> Void

    init(original: Invoice, onSave: @escaping () -> Void) {
        _viewModel = State(initialValue: CorrectiveInvoiceFormViewModel(original: original))
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("La factura original no se modifica: se emite una factura rectificativa que la referencia.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Factura original") {
                    LabeledContent("Número", value: viewModel.original.number)
                    LabeledContent("Total", value: viewModel.original.totalPrice.formatted(.currency(code: "EUR")))
                }

                Section("Rectificación") {
                    Picker("Tipo", selection: $viewModel.mode) {
                        ForEach(CorrectiveInvoiceFormViewModel.Mode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)

                    if viewModel.mode == .partial {
                        HStack {
                            Text("Importe a restar")
                            TextField("0,00", text: $viewModel.amountText)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .onChange(of: viewModel.amountText) { viewModel.sanitizeAmountText() }
                            Text("€").foregroundStyle(.secondary)
                        }
                    }

                    TextField("Motivo", text: $viewModel.concept, axis: .vertical)
                        .lineLimit(1...3)

                    if let total = viewModel.correctionTotal {
                        LabeledContent("Importe de la rectificativa") {
                            Text(total.formatted(.currency(code: "EUR"))).bold()
                        }
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage).foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Rectificar factura")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Emitir") {
                        if viewModel.save() {
                            onSave()
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.canSave)
                }
            }
        }
    }
}
