import SwiftUI
import CoreData
// 引入LunarSwift
import LunarSwift

struct AddBirthdayView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var date = Date()
    @State private var isLunar = false
    @State private var relation = ""
    @State private var note = ""
    @State private var lunarYear = 1990
    @State private var lunarMonth = 1
    @State private var lunarDay = 1

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("姓名", text: $name)
                    Toggle("农历生日", isOn: $isLunar)
                    if isLunar {
                        Picker("年份", selection: $lunarYear) {
                            ForEach(1900...2100, id: \.self) { year in
                                Text("\(year)年")
                            }
                        }
                        Picker("月份", selection: $lunarMonth) {
                            ForEach(1...12, id: \.self) { month in
                                Text("\(month)月")
                            }
                        }
                        Picker("日期", selection: $lunarDay) {
                            ForEach(1...30, id: \.self) { day in
                                Text("\(day)日")
                            }
                        }
                    } else {
                        DatePicker("生日", selection: $date, displayedComponents: .date)
                            .environment(\.locale, Locale(identifier: "zh_CN"))
                    }
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
        newBirthday.isLunar = isLunar
        newBirthday.relation = relation
        newBirthday.note = note
        if isLunar {
            let lunar = Lunar.fromYmdHms(
                lunarYear: lunarYear,
                lunarMonth: lunarMonth,
                lunarDay: lunarDay,
                hour: 0,
                minute: 0,
                second: 0
            )
            let solar = lunar.solar
            newBirthday.lunarDateString = lunar.description
            newBirthday.solarDateString = solar.fullString
            // 手动组装 Date
            let components = DateComponents(year: solar.year, month: solar.month, day: solar.day)
            newBirthday.date = Calendar(identifier: .gregorian).date(from: components)
        } else {
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            let solar = Solar.fromYmdHms(
                year: components.year!,
                month: components.month!,
                day: components.day!,
                hour: 0,
                minute: 0,
                second: 0
            )
            let lunar = solar.lunar
            newBirthday.solarDateString = solar.fullString
            newBirthday.lunarDateString = lunar.description
            newBirthday.date = date
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
