//
//  ContentView.swift
//  suisuinian
//
//  Created by 徐文兴 on 2025/7/17.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: Birthday.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Birthday.date, ascending: true)],
        animation: .default)
    private var birthdays: FetchedResults<Birthday>

    @State private var showingAdd = false

    var body: some View {
        NavigationView {
            List {
                ForEach(birthdays) { birthday in
                    NavigationLink(destination: BirthdayDetailView(birthday: birthday)) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(birthday.name ?? "无名")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Spacer()
                                if let relation = birthday.relation, !relation.isEmpty {
                                    Text(relation)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                }
                            }
                            HStack(spacing: 12) {
                                if birthday.isLunar {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("农历：" + (birthday.lunarDateString?.prefix(while: { $0 != " " }) ?? "-"))
                                            .font(.body)
                                        Text("公历：" + (birthday.solarDateString?.prefix(10) ?? "-"))
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                    }
                                } else {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("公历：" + (birthday.solarDateString?.prefix(10) ?? "-"))
                                            .font(.body)
                                        Text("农历：" + (birthday.lunarDateString?.prefix(while: { $0 != " " }) ?? "-"))
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            if let (days, age) = daysAndAgeToNextBirthday(birthday: birthday) {
                                Text("\(days)天后\(age)岁生日")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.accentColor)
                                    .cornerRadius(10)
                                    .padding(.top, 2)
                            }
                            if let note = birthday.note, !note.isEmpty {
                                Text("备注：" + note)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                    .padding(.top, 2)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(14)
                        .shadow(color: Color(.black).opacity(0.04), radius: 2, x: 0, y: 1)
                    }
                    .listRowSeparator(.hidden)
                    .padding(.vertical, 4)
                }
                .onDelete(perform: deleteBirthdays)
            }
            .listStyle(.plain)
            .navigationTitle("生日列表")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingAdd = true }) {
                        Label("添加生日", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddBirthdayView().environment(\.managedObjectContext, viewContext)
            }
        }
    }

    private func deleteBirthdays(offsets: IndexSet) {
        withAnimation {
            offsets.map { birthdays[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    // 返回距离下一个生日多少天，以及下一个生日的年龄
    func daysAndAgeToNextBirthday(birthday: Birthday) -> (Int, Int)? {
        guard let date = birthday.date else { return nil }
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        let nowComponents = calendar.dateComponents([.year, .month, .day], from: now)
        let birthComponents = calendar.dateComponents([.year, .month, .day], from: date)
        var nextBirthdayComponents = DateComponents()
        nextBirthdayComponents.year = nowComponents.year
        nextBirthdayComponents.month = birthComponents.month
        nextBirthdayComponents.day = birthComponents.day
        var age = (nowComponents.year ?? 0) - (birthComponents.year ?? 0)
        // 今年的生日
        if let nextBirthday = calendar.date(from: nextBirthdayComponents) {
            if nextBirthday >= now {
                let days = calendar.dateComponents([.day], from: now, to: nextBirthday).day ?? 0
                if days == 0 { age += 1 } // 今天生日，年龄+1
                return (days, age + 1)
            } else {
                // 明年的生日
                nextBirthdayComponents.year! += 1
                if let nextBirthday = calendar.date(from: nextBirthdayComponents) {
                    let days = calendar.dateComponents([.day], from: now, to: nextBirthday).day ?? 0
                    return (days, age + 2)
                }
            }
        }
        return nil
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
