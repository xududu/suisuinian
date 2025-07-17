import SwiftUI
import CoreData

struct AddBirthdayView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var date = Date()
    @State private var isLunar = false
    @State private var relation = ""
    @State private var note = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("姓名", text: $name)
                    DatePicker("生日", selection: $date, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "zh_CN"))
                    Toggle("农历生日", isOn: $isLunar)
                    TextField("关系(如家人/朋友)", text: $relation)
                }
                Section(header: Text("备注")) {
                    TextField("备注", text: $note)
                }
            }
            .navigationTitle("添加生日")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        addBirthday()
                    }.disabled(name.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }

    private func addBirthday() {
        let newBirthday = Birthday(context: viewContext)
        newBirthday.name = name
        newBirthday.date = date
        newBirthday.isLunar = isLunar
        newBirthday.relation = relation
        newBirthday.note = note
        // 自动转换历法
        if isLunar {
            newBirthday.lunarDateString = lunarString(from: date)
            newBirthday.solarDateString = solarString(from: date)
        } else {
            newBirthday.solarDateString = solarString(from: date)
            newBirthday.lunarDateString = lunarString(from: date)
        }
        do {
            try viewContext.save()
            dismiss()
        } catch {
            // 错误处理
        }
    }

    // 公历字符串（中文月份）
    private func solarString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy年M月d日" // 显示为中文格式
        return formatter.string(from: date)
    }
    // 农历字符串（中文月份）
    private func lunarString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.calendar = Calendar(identifier: .chinese)
        formatter.dateFormat = "yyyy年M月d日" // 显示为中文格式
        return formatter.string(from: date)
    }
}
