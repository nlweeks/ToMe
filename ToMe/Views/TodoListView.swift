//
//  NewTodoListView.swift
//  ToMe
//
//  Created by Noah Weeks on 3/21/25.
//

import SwiftUI
import SwiftData

// TODO: Implement custom selection edit mode so the animation entering edit/select mode is smooth...a job for another day

struct TodoListView: View {
    @State var viewModel = TodoListViewModel(
        with: SwiftDataSource(
            container: SwiftDataContextManager.shared.container,
            context: SwiftDataContextManager.shared.context)
    )
    
    @State var editMode = EditMode.inactive
    
    var body: some View {
        NavigationStack {
            List(selection: $viewModel.selectedIds) {
                ForEach(viewModel.searchResults, id: \.id) { todo in
                    HStack {
                        Button {
                            viewModel.markTodoAsCompleted(todo)
                        } label: {
                            if todo.isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                            }
                        }
                        .buttonStyle(PlainButtonStyle()) // This prevents the button styling
                        
                        Text(todo.title)
                            .foregroundColor(todo.isCompleted ? .gray : .primary)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            viewModel.deleteTodo(todo)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .selectionDisabled(!editMode.isEditing)
                }
                .onMove(perform: viewModel.moveTodo(from:to:))
            }
            .listStyle(.inset)
            .environment(\.editMode, $editMode)
            .navigationBarTitle("To-Do List")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { editButton }
                ToolbarItem(placement: .topBarTrailing) { TodoListMenu(viewModel: viewModel) }
                ToolbarItem(placement: .bottomBar) { bottomToolbar }
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
            .onChange(of: viewModel.selectedIds) { oldValue, newValue in
                if !newValue.isEmpty && !editMode.isEditing {
                    withTransaction(Transaction(animation: .spring(duration: 0.5))) {
                        editMode = .active
                    }
                }
            }
            .onChange(of: editMode) { oldValue, newValue in
                if !newValue.isEditing {
                    viewModel.selectedIds.removeAll()
                }
            }
            .onChange(of: viewModel.todos.isEmpty) { wasEmpty, isEmpty in
                if isEmpty {
                    editMode = .inactive
                }
            }
        }
    }
    
    private var bottomToolbar: some View {
        HStack {
            if editMode.isEditing && !viewModel.todos.isEmpty {
                selectAllButton
            }
            Spacer()
            if editMode.isEditing {
                Button(role: .destructive) {
                    viewModel.deleteSelectedTodos()
                } label: {
                    Text("Delete")
                }
            } else {
                addTodoButton
            }
        }
    }
    
    private var addTodoButton: some View {
        Button {
            viewModel.prepareNewTodo()
        } label: {
            Image(systemName: "plus")
        }
        .disabled(!viewModel.selectedIds.isEmpty || (editMode.isEditing && !viewModel.todos.isEmpty))
        .opacity(editMode.isEditing ? 0 : 1)
    }
    
    private var editButton: some View {
        Button(editMode.isEditing ? "Done" : "Edit") {
            withTransaction(Transaction(animation: .spring(duration: 0.5))) {
                editMode = editMode.isEditing ? .inactive : .active
            }
        }
        .opacity(viewModel.todos.isEmpty ? 0 : 1)
    }
    
    private var selectAllButton: some View {
        Button {
            if viewModel.selectedIds.count == viewModel.searchResults.count {
                viewModel.selectedIds.removeAll()
            } else {
                viewModel.selectedIds = Set(viewModel.searchResults.map(\.id))
            }
        } label: {
            Text(viewModel.selectedIds.count == viewModel.searchResults.count ? "Deselect All" : "Select All")
        }
        .disabled(!editMode.isEditing)
        .opacity(editMode.isEditing ? 1 : 0)
    }
}

struct EmptyListView: View {
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

struct TodoListMenu: View {
    @Bindable var viewModel: TodoListViewModel

    var body: some View {
        Menu(content:{
            Menu(content: {
                Button("Title") {
                    viewModel.fetchTodos(sortedBy: .title)
                }
                Button("Created") {
                    viewModel.fetchTodos(sortedBy: .created)
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

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TodoItem.self, configurations: config)
    let viewModel = TodoListViewModel(with: SwiftDataSource(container: container, context: ModelContext(container)))
    
    TodoListView(viewModel: viewModel)
        .onAppear {
            viewModel.preloadSampleData()
        }
}
