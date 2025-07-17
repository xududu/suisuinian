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
                        VStack(alignment: .leading) {
                            Text(birthday.name ?? "无名")
                                .font(.headline)
                            HStack {
                                if birthday.isLunar {
                                    Text("农历：" + (birthday.lunarDateString ?? "-"))
                                    Text("(公历：" + (birthday.solarDateString ?? "-") + ")")
                                } else {
                                    Text("公历：" + (birthday.solarDateString ?? "-"))
                                    Text("(农历：" + (birthday.lunarDateString ?? "-") + ")")
                                }
                            }.font(.subheadline)
                        }
                    }
                }
                .onDelete(perform: deleteBirthdays)
            }
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
