//
//  NewTodoListView.swift
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
    
    @State var editMode = EditMode.inactive
    @FocusState private var focusedField: String?
    @State private var shouldShowCompletionOpacity: Bool = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.todos.isEmpty {
                    EmptyListView()
                } else {
                    List(selection: $viewModel.selectedIds) {
                        if !viewModel.todos.isEmpty {
                            ForEach(viewModel.todos, id: \.id) { todo in
                                HStack {
                                    if !editMode.isEditing {
                                        CompletionButton(todo: todo, isInEditMode: editMode.isEditing, viewModel: viewModel, shouldShowCompletionOpacity: shouldShowCompletionOpacity)
                                    }
                                    
                                    TodoRowView(viewModel: viewModel, todo: todo, isEditMode: editMode.isEditing, focusedField: $focusedField, fieldId: todo.id.uuidString)
                                }
                                .animation(nil, value: editMode)
                            }
                            
                            .onMove(perform: viewModel.moveTodo(from:to:))
                        }
                        
                    }
                    .listStyle(.inset)
                    .animation(nil, value: viewModel.todos)
                    
                    Color.clear
                        .frame(height: 100)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            focusedField = nil
                        }
                        .allowsHitTesting(true)
                }
            }
            .environment(\.editMode, $editMode)
            .navigationTitle("To-Do List")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { editButton }
                ToolbarItem(placement: .topBarTrailing) { TodoListMenu(viewModel: viewModel) }
                ToolbarItem(placement: .bottomBar) { bottomToolbar }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
            .sheet(isPresented: $viewModel.isAddingTodo) {
                AddTodoView(viewModel: viewModel)
                    .interactiveDismissDisabled()
                    .presentationDetents([.fraction(0.3)])
            }
            .onAppear {
                if viewModel.todos.isEmpty {
                    viewModel.preloadSampleData()
                }
            }
            .onChange(of: viewModel.selectedIds) { _, newValue in
                if !newValue.isEmpty && !editMode.isEditing {
                    // 👇 disable animation for the layout shift
                    withTransaction(Transaction(animation: nil)) {
                        editMode = .active
                    }
                }
            }
            .onChange(of: editMode) { _, newValue in
                if newValue.isEditing {
                    shouldShowCompletionOpacity = false
                } else {
                    // Delay the fade-in of the completion button
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            shouldShowCompletionOpacity = true
                        }
                    }
                }
                
                withTransaction(Transaction(animation: nil)) {
                    if !newValue.isEditing {
                        viewModel.selectedIds.removeAll()
                        focusedField = nil
                    }
                }
            }
            .onChange(of: viewModel.todos.isEmpty) { _, isEmpty in
                if isEmpty {
                    withTransaction(Transaction(animation: nil)) {
                        editMode = .inactive
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 10)
                .onEnded { _ in
                    focusedField = nil
                }
        )
    }
    
    private var bottomToolbar: some View {
        HStack {
            if editMode.isEditing && !viewModel.todos.isEmpty {
                selectAllButton
                Spacer()
                Button(role: .destructive) {
                    viewModel.deleteSelectedTodos()
                } label: {
                    Text("Delete")
                }
            } else {
                Spacer()
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
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                editMode = editMode.isEditing ? .inactive : .active
                if !editMode.isEditing {
                    focusedField = nil
                }
            }
        } label: {
            ZStack(alignment: .leading) {
                Text("Edit")
                    .opacity(editMode.isEditing ? 0 : 1)
                Text("Done")
                    .opacity(editMode.isEditing ? 1 : 0)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: editMode.isEditing)
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


struct CompletionButton: View {
    var todo: TodoItem
    var isInEditMode: Bool
    @Bindable var viewModel: TodoListViewModel
    let shouldShowCompletionOpacity: Bool
    
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.08)) {
                viewModel.markTodoAsCompleted(todo)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeInOut(duration: 0.35)) {
                    viewModel.sortTodos()
                }
            }
        } label: {
            Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(todo.isCompleted ? .blue : .gray)
                .font(.title2.weight(.light))
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(isInEditMode ? 0 : (shouldShowCompletionOpacity ? 1 : 0))
        .animation(.easeInOut(duration: 0.85), value: shouldShowCompletionOpacity)
    }
}

struct EmptyListView: View {
    @State private var isAppearing: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
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
            Spacer()
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
