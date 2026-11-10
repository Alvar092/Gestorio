import SwiftUI

struct AppointmentsCalendarView: View {
    @State private var viewModel = AppointmentsCalendarViewModel()
    @State private var navigationPath = NavigationPath()
    @State private var isCreating = false

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    MonthCalendarView(
                        displayedMonth: $viewModel.displayedMonth,
                        markedDates: viewModel.datesWithAppointments,
                        selectedDate: nil,
                        onSelect: { date in
                            navigationPath.append(date)
                        }
                    )
                    upcomingSection
                }
                .padding()
            }
            .navigationTitle("Calendario")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Nuevo evento", systemImage: "plus") {
                        isCreating = true
                    }
                }
            }
            .sheet(isPresented: $isCreating) {
                AppointmentFormView(onSave: viewModel.load)
            }
            .navigationDestination(for: Date.self) { date in
                DayAppointmentsView(
                    date: date,
                    appointments: viewModel.appointments(on: date),
                    clientName: viewModel.clientName(for:)
                )
            }
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
}

private extension AppointmentsCalendarView {
    var upcomingSection: some View {
        let upcoming = viewModel.upcomingAppointments()
        return VStack(alignment: .leading, spacing: 12) {
            Text("Próximas citas")
                .font(.title3.bold())

            if upcoming.isEmpty {
                Text("No tienes citas pendientes.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(upcoming) { appointment in
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
    AppointmentsCalendarView()
}
