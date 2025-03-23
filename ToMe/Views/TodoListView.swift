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
        with: SwiftDataSource(
            container: SwiftDataContextManager.shared.container,
            context: SwiftDataContextManager.shared.context)
    )
    
    @State private var editMode: EditMode = .inactive
    @State var selectedRows = Set<TodoItem>()
    
    var body: some View {
        
        NavigationStack {
                List(selection: $selectedRows) {
                    ForEach(viewModel.searchResults) { todo in
                        Text(todo.title)
                    }
                    .onDelete(perform: viewModel.deleteTodos(at:))
                    .onMove(perform: viewModel.moveTodo(from:to:))
                }
                .navigationBarTitle("To-Do List")
                .environment(\.editMode, $editMode)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(editMode.isEditing ? "Done" : "Edit") {
                            withAnimation {
                                editMode = editMode == .active ? .inactive : .active
                            }
                        }
                            .opacity(viewModel.todos.isEmpty ? 0 : 1)
                        
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        TodoListMenu(viewModel: viewModel)
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
                        .presentationDetents([.medium])
                }
                .onAppear {
                    viewModel.preloadSampleData()
                }
                .searchable(text: $viewModel.searchQuery, placement: .navigationBarDrawer(displayMode: .automatic), prompt: "Search")
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
    
    private struct TodoListMenu: View {
        @Bindable var viewModel: TodoListViewModel
        
        var body: some View {
            Menu(content:{
                Menu(content: {
                    Button("Title") {
                        viewModel.fetchTodos(sortedBy: .title)
                    }
                    Button("Created") {
                        viewModel.fetchTodos(sortedBy: .title)
                    }
                }, label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                })
            }, label: {
                Label("Options", systemImage: "ellipsis.circle")
            })
            .menuStyle(.button)
        }
    }
}



#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TodoItem.self, configurations: config)
    let viewModel = TodoListViewModel(with: SwiftDataSource(container: container, context: ModelContext(container)))
    
    TodoListView(viewModel: viewModel)
        .onAppear {
            viewModel.preloadSampleData()
        }
}
