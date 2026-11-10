import SwiftUI

struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if let balance = viewModel.balance {
                        balanceCard(balance)
                    }
                    upcomingSection
                }
                .padding()
            }
            .navigationTitle("Inicio")
            .navigationDestination(for: Appointment.self) { appointment in
                AppointmentDetailView(
                    appointment: appointment,
                    clientName: viewModel.clientName(for: appointment)
                )
            }
        }
        .task {
            viewModel.load()
        }
    }

    private func balanceCard(_ balance: QuarterBalance) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(balance.quarter)T \(balance.year.formatted(.number.grouping(.never)))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(balance.invoiced.formatted(.currency(code: "EUR")))
                .font(.largeTitle.bold())
            Text("Facturado en el trimestre")
                .font(.caption)
                .foregroundStyle(.secondary)
            Divider()
            LabeledContent("Pendiente de facturar", value: balance.pendingToInvoice.formatted(.currency(code: "EUR")))
                .font(.subheadline)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 16))
    }

    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Próximas citas")
                .font(.title3.bold())

            if viewModel.upcomingAppointments.isEmpty {
                ContentUnavailableView("Sin citas próximas", systemImage: "calendar", description: Text("No tienes citas pendientes."))
            } else {
                ForEach(viewModel.upcomingAppointments) { appointment in
                    NavigationLink(value: appointment) {
                        UpcomingAppointmentRow(
                            appointment: appointment,
                            clientName: viewModel.clientName(for: appointment)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    DashboardView()
}
