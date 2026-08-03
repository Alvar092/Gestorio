import SwiftUI

struct AppointmentsCalendarView: View {
    @State private var viewModel = AppointmentsCalendarViewModel()
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                MonthCalendarView(
                    displayedMonth: $viewModel.displayedMonth,
                    markedDates: viewModel.datesWithAppointments,
                    selectedDate: nil,
                    onSelect: { date in
                        navigationPath.append(date)
                    }
                )
                .padding()
            }
            .navigationTitle("Calendario")
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

#Preview {
    AppointmentsCalendarView()
}
