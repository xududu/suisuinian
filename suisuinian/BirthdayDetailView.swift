import SwiftUI
import CoreData

struct BirthdayDetailView: View {
    @ObservedObject var birthday: Birthday

    var body: some View {
        Form {
            Section(header: Text("姓名")) {
                Text(birthday.name ?? "无名")
            }
            Section(header: Text("生日")) {
                Text(birthday.date != nil ? dateFormatter.string(from: birthday.date!) : "无日期")
                Text(birthday.isLunar ? "农历" : "公历")
            }
            if let relation = birthday.relation, !relation.isEmpty {
                Section(header: Text("关系")) {
                    Text(relation)
                }
            }
            if let note = birthday.note, !note.isEmpty {
                Section(header: Text("备注")) {
                    Text(note)
                }
            }
        }
        .navigationTitle("生日详情")
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter
}()
