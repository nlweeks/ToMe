//
//  Untitled.swift
//  ToMe
//
//  Created by Noah Weeks on 3/22/25.
//
//  ContentView.swift
import SwiftUI

struct CustomListData: Identifiable {
    let id = UUID()
    let title: String
}

struct CustomListView: View {
    @State var customListData = [
        CustomListData(title: "One"),
        CustomListData(title: "Two"),
        CustomListData(title: "Three"),
        CustomListData(title: "Four"),
        CustomListData(title: "Five")
    ]
    
    var body: some View {
        VStack {
            List {
                ForEach(customListData) { item in
                    Text(item.title)
                }
                .onDelete(perform: deleteItems)
            }
            
            HStack {
                Spacer()
                EditButton()
                
                Button {
                    customListData.append(CustomListData(title: "New Item"))
                } label: {
                    Text("Add")
                }
            }.padding()
        }
    }
    
    func deleteItems(at offsets: IndexSet) {
        customListData.remove(atOffsets: offsets)
    }
}

#Preview {
    CustomListView()
}
