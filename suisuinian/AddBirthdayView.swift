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
    @State private var showTimePicker = false
    @State private var hour = Calendar.current.component(.hour, from: Date())
    @State private var minute = Calendar.current.component(.minute, from: Date())

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本信息")) {
                    TextField("姓名", text: $name)
                    Toggle("农历生日", isOn: $isLunar)
                    Toggle("填写具体时间（时分）", isOn: $showTimePicker)
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
                        if showTimePicker {
                            HStack {
                                Picker("时", selection: $hour) {
                                    ForEach(0..<24) { h in Text(String(format: "%02d", h)) }
                                }.frame(width: 80)
                                Text(":")
                                Picker("分", selection: $minute) {
                                    ForEach(0..<60) { m in Text(String(format: "%02d", m)) }
                                }.frame(width: 80)
                            }
                        }
                    } else {
                        DatePicker("生日", selection: $date, displayedComponents: showTimePicker ? [.date, .hourAndMinute] : .date)
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
            let useHour = showTimePicker ? hour : Calendar.current.component(.hour, from: Date())
            let useMinute = showTimePicker ? minute : Calendar.current.component(.minute, from: Date())
            let lunar = Lunar.fromYmdHms(
                lunarYear: lunarYear,
                lunarMonth: lunarMonth,
                lunarDay: lunarDay,
                hour: useHour,
                minute: useMinute,
                second: 0
            )
            let solar = lunar.solar
            newBirthday.lunarDateString = lunar.description
            newBirthday.solarDateString = solar.fullString
            // 手动组装 Date
            let components = DateComponents(year: solar.year, month: solar.month, day: solar.day, hour: useHour, minute: useMinute)
            newBirthday.date = Calendar(identifier: .gregorian).date(from: components)
        } else {
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            let useHour = showTimePicker ? (components.hour ?? 0) : Calendar.current.component(.hour, from: Date())
            let useMinute = showTimePicker ? (components.minute ?? 0) : Calendar.current.component(.minute, from: Date())
            let solar = Solar.fromYmdHms(
                year: components.year!,
                month: components.month!,
                day: components.day!,
                hour: useHour,
                minute: useMinute,
                second: 0
            )
            let lunar = solar.lunar
            newBirthday.solarDateString = solar.fullString
            newBirthday.lunarDateString = lunar.description
            let dateComponents = DateComponents(year: solar.year, month: solar.month, day: solar.day, hour: useHour, minute: useMinute)
            newBirthday.date = Calendar(identifier: .gregorian).date(from: dateComponents)
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
