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

import Foundation

struct EditBirthdayView: View {
    @ObservedObject var birthday: Birthday
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var isLunar: Bool
    @State private var relation: String
    @State private var note: String
    @State private var date: Date
    @State private var lunarYear: Int
    @State private var lunarMonth: Int
    @State private var lunarDay: Int
    @State private var showTimePicker: Bool
    @State private var hour: Int
    @State private var minute: Int

    init(birthday: Birthday) {
        self.birthday = birthday
        _name = State(initialValue: birthday.name ?? "")
        _isLunar = State(initialValue: birthday.isLunar)
        _relation = State(initialValue: birthday.relation ?? "")
        _note = State(initialValue: birthday.note ?? "")
        _date = State(initialValue: birthday.date ?? Date())
        let calendar = Calendar(identifier: .gregorian)
        let date = birthday.date ?? Date()
        let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        _hour = State(initialValue: comps.hour ?? 0)
        _minute = State(initialValue: comps.minute ?? 0)
        _showTimePicker = State(initialValue: (comps.hour ?? 0) != 0 || (comps.minute ?? 0) != 0)
        if birthday.isLunar, let lunarStr = birthday.lunarDateString, lunarStr.count >= 5 {
            // 简单解析农历年、月、日
            let year = Int(lunarStr.prefix(4)) ?? comps.year ?? 1990
            let rest = lunarStr.dropFirst(4)
            let monthDay = rest.components(separatedBy: "月")
            let month = Int(monthDay.first?.replacingOccurrences(of: "年", with: "") ?? "1") ?? 1
            let day = Int(monthDay.last?.replacingOccurrences(of: "日", with: "") ?? "1") ?? 1
            _lunarYear = State(initialValue: year)
            _lunarMonth = State(initialValue: month)
            _lunarDay = State(initialValue: day)
        } else {
            _lunarYear = State(initialValue: comps.year ?? 1990)
            _lunarMonth = State(initialValue: comps.month ?? 1)
            _lunarDay = State(initialValue: comps.day ?? 1)
        }
    }

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
            .navigationTitle("编辑生日")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveEdit()
                    }.disabled(name.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
    }

    private func saveEdit() {
        birthday.name = name
        birthday.isLunar = isLunar
        birthday.relation = relation
        birthday.note = note
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
            birthday.lunarDateString = lunar.description
            birthday.solarDateString = solar.fullString
            let components = DateComponents(year: solar.year, month: solar.month, day: solar.day, hour: useHour, minute: useMinute)
            birthday.date = Calendar(identifier: .gregorian).date(from: components)
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
            birthday.solarDateString = solar.fullString
            birthday.lunarDateString = lunar.description
            let dateComponents = DateComponents(year: solar.year, month: solar.month, day: solar.day, hour: useHour, minute: useMinute)
            birthday.date = Calendar(identifier: .gregorian).date(from: dateComponents)
        }
        do {
            try viewContext.save()
            dismiss()
        } catch {
            // 错误处理
        }
    }
}
