//
//  TodoListView.swift
//  ToMe
//
//  Created by Noah Weeks on 3/21/25.
//

import SwiftUI
import SwiftData

struct TodoListView: View {
    @State var viewModel = TodoListViewModel(
        with: SwiftDataLocalSource(
            container: SwiftDataContextManager.shared.container,
            context: SwiftDataContextManager.shared.context)
    )
    
    var body: some View {
        NavigationStack {
            Group {
                List {
                    ForEach(viewModel.todos) { todo in
                        Text(todo.title)
                    }
                    .onDelete(perform: viewModel.deleteTodos(at:))
                    .onMove(perform: viewModel.moveTodo(from:to:))
                }
                .navigationBarTitle("To-Do List")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        EditButton()
                            .opacity(viewModel.todos.isEmpty ? 0 : 1)
                        
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu(content:{
                            Menu(content: {
                                Button("Title") {
                                    // TODO: Make sorting by title function
                                }
                            }, label: {
                                Label("Sort", systemImage: "arrow.up.arrow.down")
                            })
                        }, label: {
                            Label("Options", systemImage: "ellipsis.circle")
                        })
                        .menuStyle(.button)
                    }
                    
                    ToolbarItem(placement: .bottomBar) {
                        HStack {
                            Spacer()
                            Button {
                                viewModel.prepareNewTodo()
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
                }
                .overlay {
                    if viewModel.todos.isEmpty {
                        EmptyListView()
                    }
                }
                .sheet(isPresented: $viewModel.isAddingTodo) {
                    AddTodoView(viewModel: viewModel)
                        .interactiveDismissDisabled()
                }
            }
        }
    }
    
    private struct EmptyListView: View {
        @State private var isAppearing: Bool = false
        
        var body: some View {
            ContentUnavailableView {
                Label(title: { Text("You're all done!") }, icon: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 50))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.blue)
                        .opacity(isAppearing ? 1 : 0)
                        .scaleEffect(isAppearing ? 1 : 0.5)
                        .animation(.spring(duration: 0.7), value: isAppearing)
                        .onAppear {
                            isAppearing = true
                        }
                })
            } description: {
                Text("Take a breather, then add what's next")
            }
        }
    }
}



#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TodoItem.self, configurations: config)
    
    TodoListView(viewModel: TodoListViewModel(with: SwiftDataLocalSource(container: container, context: ModelContext(container))))
}
