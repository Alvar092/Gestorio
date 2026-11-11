import SwiftUI

struct ActivityEntryFormView: View {
    @State private var viewModel: ActivityEntryFormViewModel
    @State private var isEditingProfile = false
    @Environment(\.dismiss) private var dismiss
    private let onSave: () -> Void

    init(kind: ActivityKind, editing expense: Expense? = nil, onSave: @escaping () -> Void) {
        _viewModel = State(initialValue: ActivityEntryFormViewModel(kind: kind, editing: expense))
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                if viewModel.profile == nil, !viewModel.isEditing {
                    Section {
                        Text("Para crear facturas necesitas indicar tus datos fiscales.")
                            .foregroundStyle(.secondary)
                        Button("Configurar mis datos") { isEditingProfile = true }
                    }
                }

                switch viewModel.kind {
                case .income:
                    profileSection(title: "Emisor (tú)")
                    counterpartySection(title: "Destinatario", showsClientPicker: true)
                case .expense:
                    counterpartySection(title: "Emisor (proveedor)", showsClientPicker: false)
                    if !viewModel.isEditing {
                        profileSection(title: "Destinatario (tú)")
                    }
                }

                Section("Factura") {
                    DatePicker("Fecha", selection: $viewModel.date, displayedComponents: .date)
                    TextField("Razón de la factura", text: $viewModel.concept, axis: .vertical)
                        .lineLimit(1...3)
                }

                Section("Importe") {
                    if viewModel.allowsTotalInput {
                        Picker("Importe", selection: $viewModel.amountInput) {
                            ForEach(ActivityEntryFormViewModel.AmountInput.allCases) { input in
                                Text(input.title).tag(input)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    HStack {
                        Text(viewModel.allowsTotalInput ? viewModel.amountInput.title : "Base imponible")
                        TextField("0,00", text: $viewModel.baseText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: viewModel.baseText) { viewModel.sanitizeBaseText() }
                        Text("€").foregroundStyle(.secondary)
                    }
                    Picker("IVA", selection: $viewModel.vatRate) {
                        ForEach(ActivityEntryFormViewModel.vatRates, id: \.self) { rate in
                            Text("\(rate.formatted()) %").tag(rate)
                        }
                    }
                    Toggle("Retención de IRPF", isOn: $viewModel.hasIRPF)
                    if viewModel.hasIRPF {
                        Picker("% de IRPF", selection: $viewModel.irpfRate) {
                            ForEach(ActivityEntryFormViewModel.irpfRates, id: \.self) { rate in
                                Text("\(rate.formatted()) %").tag(rate)
                            }
                        }
                    }
                }

                if let breakdown = viewModel.breakdown {
                    Section("Resumen") {
                        LabeledContent("Base", value: breakdown.base.formatted(.currency(code: "EUR")))
                        LabeledContent("IVA (\(breakdown.vatRate.formatted()) %)", value: breakdown.vatAmount.formatted(.currency(code: "EUR")))
                        if breakdown.irpfRate > 0 {
                            LabeledContent("IRPF (\(breakdown.irpfRate.formatted()) %)", value: "−" + breakdown.irpfAmount.formatted(.currency(code: "EUR")))
                        }
                        LabeledContent("Total") {
                            Text(breakdown.total.formatted(.currency(code: "EUR"))).bold()
                        }
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage).foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        if viewModel.save() {
                            onSave()
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .sheet(isPresented: $isEditingProfile, onDismiss: viewModel.load) {
                IssuerProfileFormView()
            }
        }
        .task {
            viewModel.load()
        }
    }
}

private extension ActivityEntryFormView {
    @ViewBuilder
    func profileSection(title: String) -> some View {
        Section(title) {
            if let profile = viewModel.profile {
                LabeledContent("Nombre", value: profile.name)
                LabeledContent("NIF / CIF", value: profile.taxID)
            } else {
                Text("Sin configurar").foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    func counterpartySection(title: String, showsClientPicker: Bool) -> some View {
        Section(title) {
            if showsClientPicker, !viewModel.clients.isEmpty {
                Picker("Cliente", selection: $viewModel.clientID) {
                    Text("Escribir a mano").tag(UUID?.none)
                    ForEach(viewModel.clients) { client in
                        Text(client.name).tag(UUID?.some(client.id))
                    }
                }
                .onChange(of: viewModel.clientID) { viewModel.applySelectedClient() }
            }
            TextField("Nombre o razón social", text: $viewModel.counterpartyName)
            TextField("NIF / CIF", text: $viewModel.counterpartyTaxID)
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
        }
    }
}

#Preview {
    ActivityEntryFormView(kind: .income, onSave: {})
}
