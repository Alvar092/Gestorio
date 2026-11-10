import SwiftUI

struct UpcomingAppointmentRow: View {
    let appointment: Appointment
    let clientName: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(clientName)
                    .font(.headline)
                Text(appointment.service)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(appointment.date, format: .dateTime.day().month(.abbreviated))
                    .font(.subheadline.bold())
                Text(appointment.date, format: .dateTime.hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 12))
    }
}
