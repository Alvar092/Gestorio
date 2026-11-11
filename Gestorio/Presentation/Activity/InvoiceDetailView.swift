import SwiftUI

/// Detalle de una factura emitida. Es append-only: el botón superior abre la rectificación.
struct InvoiceDetailView: View {
    let invoice: Invoice
    let correctiveInvoices: [CorrectiveInvoice]
    let onChanged: () -> Void
    @State private var isCorrecting = false

    var body: some View {
        Form {
            Section("Factura") {
                LabeledContent("Número", value: invoice.number)
                LabeledContent("Fecha", value: invoice.date.formatted(date: .long, time: .omitted))
                Text(invoice.concept)
            }

            Section("Emisor") {
                LabeledContent("Nombre", value: invoice.issuerName)
                LabeledContent("NIF / CIF", value: invoice.issuerTaxID)
            }

            Section("Destinatario") {
                LabeledContent("Nombre", value: invoice.clientName)
                LabeledContent("NIF / CIF", value: invoice.clientTaxID)
            }

            Section("Importe") {
                TaxBreakdownRows(
                    breakdown: TaxBreakdown(base: invoice.taxBase, vatRate: invoice.vatRate, irpfRate: invoice.irpfRate)
                )
            }

            if !correctiveInvoices.isEmpty {
                Section("Rectificativas") {
                    ForEach(correctiveInvoices) { corrective in
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text(corrective.number)
                                Spacer()
                                Text(corrective.totalPrice.formatted(.currency(code: "EUR")))
                                    .foregroundStyle(.red)
                            }
                            Text(corrective.concept)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(corrective.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section("Registro RRSIF") {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Huella").font(.caption).foregroundStyle(.secondary)
                    Text(invoice.hash).font(.caption.monospaced()).textSelection(.enabled)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Huella anterior").font(.caption).foregroundStyle(.secondary)
                    Text(invoice.previousHash).font(.caption.monospaced()).textSelection(.enabled)
                }
            }
        }
        .navigationTitle(invoice.number)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if correctiveInvoices.isEmpty {
                ToolbarItem(placement: .primaryAction) {
                    Button("Rectificar") { isCorrecting = true }
                }
            }
        }
        .sheet(isPresented: $isCorrecting) {
            CorrectiveInvoiceFormView(original: invoice, onSave: onChanged)
        }
    }
}

/// Filas base / IVA / IRPF / total, compartidas por los detalles de ingreso y gasto.
struct TaxBreakdownRows: View {
    let breakdown: TaxBreakdown

    var body: some View {
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
