import SwiftUI
import CoreData

struct BirthdayDetailView: View {
    @ObservedObject var birthday: Birthday

    var body: some View {
        Form {
            Section(header: Text("姓名")) {
                Text(birthday.name ?? "无名")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            Section(header: Text("生日信息")) {
                if let date = birthday.date {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("公历：" + (birthday.solarDateString?.prefix(10) ?? "-"))
                                .font(.body)
                            Text("农历：" + (birthday.lunarDateString?.prefix(while: { $0 != " " }) ?? "-"))
                                .font(.body)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("时间：" + timeFormatter.string(from: date))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                } else {
                    Text("无日期")
                }
                HStack(spacing: 16) {
                    if let zodiac = zodiacString {
                        Label(zodiac, systemImage: "hare")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                    if let constellation = constellationString {
                        Label(constellation, systemImage: "star")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
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

    // 生肖
    var zodiacString: String? {
        guard let date = birthday.date else { return nil }
        let calendar = Calendar(identifier: .gregorian)
        let year = calendar.component(.year, from: date)
        let zodiacs = ["鼠", "牛", "虎", "兔", "龙", "蛇", "马", "羊", "猴", "鸡", "狗", "猪"]
        return "生肖：" + zodiacs[(year - 4) % 12]
    }
    // 星座
    var constellationString: String? {
        guard let date = birthday.date else { return nil }
        let calendar = Calendar(identifier: .gregorian)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let constellations = [
            (20, "水瓶座"), (19, "双鱼座"), (21, "白羊座"), (20, "金牛座"), (21, "双子座"), (22, "巨蟹座"),
            (23, "狮子座"), (23, "处女座"), (23, "天秤座"), (24, "天蝎座"), (23, "射手座"), (22, "摩羯座")
        ]
        let index = (month - 1 + (day >= constellations[month - 1].0 ? 1 : 0)) % 12
        return "星座：" + constellations[index].1
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter
}()

private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter
}()
