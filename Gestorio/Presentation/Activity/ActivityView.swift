import SwiftUI

struct ActivityView: View {
    @State private var viewModel = ActivityViewModel()
    @State private var creatingKind: ActivityKind?
    @State private var isEditingProfile = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Tipo", selection: $viewModel.selectedKind) {
                    ForEach(ActivityKind.allCases) { kind in
                        Text(kind.title).tag(kind)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                content
            }
            .navigationTitle("Actividad")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Mis datos fiscales", systemImage: "person.text.rectangle") {
                        isEditingProfile = true
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu("Nuevo", systemImage: "plus") {
                        ForEach(ActivityKind.allCases) { kind in
                            Button(kind.newTitle) { creatingKind = kind }
                        }
                    }
                }
            }
            .sheet(item: $creatingKind) { kind in
                ActivityEntryFormView(kind: kind, onSave: viewModel.load)
            }
            .sheet(isPresented: $isEditingProfile) {
                IssuerProfileFormView()
            }
        }
        .task {
            viewModel.load()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.selectedKind {
        case .income:
            if viewModel.invoices.isEmpty {
                ContentUnavailableView("Sin ingresos", systemImage: "arrow.down.circle", description: Text("Pulsa + para crear tu primera factura."))
            } else {
                List(viewModel.invoices) { invoice in
                    ActivityRow(
                        title: invoice.concept,
                        subtitle: "\(invoice.number) · \(invoice.clientName)",
                        date: invoice.date,
                        amount: invoice.totalPrice
                    )
                }
            }
        case .expense:
            if viewModel.expenses.isEmpty {
                ContentUnavailableView("Sin gastos", systemImage: "arrow.up.circle", description: Text("Pulsa + para registrar tu primer gasto."))
            } else {
                List(viewModel.expenses) { expense in
                    ActivityRow(
                        title: expense.concept,
                        subtitle: expense.issuerName,
                        date: expense.date,
                        amount: -expense.totalPrice
                    )
                }
            }
        }
    }
}

private struct ActivityRow: View {
    let title: String
    let subtitle: String
    let date: Date
    let amount: Decimal

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).lineLimit(1)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(amount.formatted(.currency(code: "EUR")))
                .foregroundStyle(amount < 0 ? Color.red : Color.primary)
        }
    }
}

#Preview {
    ActivityView()
}
