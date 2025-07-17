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
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
