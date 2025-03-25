////
////  TodoListView.swift
////  ToMe
////
////  Created by Noah Weeks on 3/21/25.
////
//
//import SwiftUI
//import SwiftData
//
//struct OLDTodoListView: View {
//    @State var viewModel = TodoListViewModel(
//        with: SwiftDataSource(
//            container: SwiftDataContextManager.shared.container,
//            context: SwiftDataContextManager.shared.context)
//    )
//    
//    @State var editMode = EditMode.inactive
//    
//    var body: some View {
//        NavigationView {
//            List(selection: $viewModel.selectedIds) {
//                ForEach(viewModel.searchResults, id: \.id) { todo in
//                    HStack {
//                        // Display completion status when not in edit mode
//                        if editMode.isEditing == false {
//                            Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
//                                .foregroundColor(todo.isCompleted ? .blue : .gray)
//                        }
//                        
//                        Text(todo.title)
//                    }
//                    .swipeActions(edge: .trailing) {
//                        Button(role: .destructive) {
//                            viewModel.deleteTodo(todo)
//                        } label: {
//                            Label("Delete", systemImage: "trash")
//                        }
//                    }
//                }
//                .onMove(perform: viewModel.moveTodo(from:to:))
//            }
//            .navigationBarTitle("To-Do List")
//            .toolbar {
//                ToolbarItem(placement: .topBarLeading) { editButton }
//                ToolbarItem(placement: .topBarTrailing) { TodoListMenu(viewModel: viewModel) }
//                ToolbarItem(placement: .bottomBar) { bottomToolbar }
//            }
//            .overlay {
//                if viewModel.todos.isEmpty {
//                    EmptyListView()
//                }
//            }
//            .sheet(isPresented: $viewModel.isAddingTodo) {
//                AddTodoView(viewModel: viewModel)
//                    .interactiveDismissDisabled()
//                    .presentationDetents([.medium])
//            }
//            .onAppear {
//                viewModel.preloadSampleData()
//            }
//            .environment(\.editMode, $editMode)
//            .onChange(of: editMode) { oldValue, newValue in
//                if !newValue.isEditing {
//                    viewModel.selectedIds.removeAll()
//                }
//            }
//            .animation(.default, value: editMode)
//        }
//    }
//    
//    private var bottomToolbar: some View {
//        HStack {
//            selectAllButton
//            Spacer()
//            addTodoButton
//        }
//    }
//    
//    private var addTodoButton: some View {
//        Button {
//            viewModel.prepareNewTodo()
//        } label: {
//            Image(systemName: "plus")
//        }
//        .disabled(!viewModel.selectedIds.isEmpty || editMode.isEditing)
//    }
//    
//    private var editButton: some View {
//        Button(editMode.isEditing ? "Done" : "Edit") {
//            editMode = editMode.isEditing ? .inactive : .active
//        }
//        .opacity(viewModel.todos.isEmpty ? 0 : 1)
//    }
//    
//    private var selectAllButton: some View {
//        Button {
//            if viewModel.selectedIds.count == viewModel.searchResults.count {
//                viewModel.selectedIds.removeAll()
//            } else {
//                viewModel.selectedIds = Set(viewModel.searchResults.map(\.id))
//            }
//        } label: {
//            Text(viewModel.selectedIds.count == viewModel.searchResults.count ? "Deselect All" : "Select All")
//        }
//        .disabled(!editMode.isEditing)
//        .opacity(editMode.isEditing ? 1 : 0)
//    }
//    
//    //    private var selectAllButton: some View {
//    //        Button {
//    //            viewModel.toggleSelectAll()
//    //        } label: {
//    //            Text(viewModel.areAllItemsSelected ? "Deselect All" : "Select All")
//    //        }
//    //        .disabled(!editMode.isEditing)
//    //        .opacity(editMode.isEditing ? 1 : 0)
//    //    }
//}
//
//private struct EmptyListView: View {
//    @State private var isAppearing: Bool = false
//    
//    var body: some View {
//        ContentUnavailableView {
//            Label(title: { Text("You're all done!") }, icon: {
//                Image(systemName: "checkmark")
//                    .font(.system(size: 50))
//                    .symbolRenderingMode(.hierarchical)
//                    .foregroundStyle(.blue)
//                    .opacity(isAppearing ? 1 : 0)
//                    .scaleEffect(isAppearing ? 1 : 0.5)
//                    .animation(.spring(duration: 0.7), value: isAppearing)
//                    .onAppear {
//                        isAppearing = true
//                    }
//            })
//        } description: {
//            Text("Take a breather, then add what's next")
//        }
//    }
//}
//
//private struct TodoListMenu: View {
//    @Bindable var viewModel: TodoListViewModel
//    
//    var body: some View {
//        Menu(content:{
//            Menu(content: {
//                Button("Title") {
//                    viewModel.fetchTodos(sortedBy: .title)
//                }
//                Button("Created") {
//                    viewModel.fetchTodos(sortedBy: .created)
//                }
//            }, label: {
//                Label("Sort", systemImage: "arrow.up.arrow.down")
//            })
//        }, label: {
//            Label("Options", systemImage: "ellipsis.circle")
//        })
//        .menuStyle(.button)
//    }
//}
//
//#Preview {
//    let config = ModelConfiguration(isStoredInMemoryOnly: true)
//    let container = try! ModelContainer(for: TodoItem.self, configurations: config)
//    let viewModel = TodoListViewModel(with: SwiftDataSource(container: container, context: ModelContext(container)))
//    
//    OLDTodoListView(viewModel: viewModel)
//        .onAppear {
//            viewModel.preloadSampleData()
//        }
//}
//
//
////import SwiftUI
////import SwiftData
////
////struct TodoListView: View {
////    @State var viewModel = TodoListViewModel(
////        with: SwiftDataSource(
////            container: SwiftDataContextManager.shared.container,
////            context: SwiftDataContextManager.shared.context)
////    )
////
////    @State var editMode = EditMode.inactive
////    @State var selectedRows = Set<UUID>()
////    @State private var selectionState = true
////
////
////    var body: some View {
////        NavigationView {
////            todoList
////                .navigationBarTitle("To-Do List")
////                .toolbar {
////                    ToolbarItem(placement: .topBarLeading) { editButton }
////                    ToolbarItem(placement: .topBarTrailing) { TodoListMenu(viewModel: viewModel) }
////                    ToolbarItem(placement: .bottomBar) { bottomToolbar }
////                }
////                .overlay {
////                    if viewModel.todos.isEmpty {
////                        EmptyListView()
////                    }
////                }
////                .sheet(isPresented: $viewModel.isAddingTodo) {
////                    AddTodoView(viewModel: viewModel)
////                        .interactiveDismissDisabled()
////                        .presentationDetents([.medium])
////                }
////                .onAppear {
////                    viewModel.preloadSampleData()
////                }
////                .environment(\.editMode, $editMode)
////                .onChange(of: selectedRows) { oldValue, newValue in
////                    if !newValue.isEmpty && !editMode.isEditing {
////                        editMode = .active
////                    }
////                }
////                .animation(.default, value: editMode)
////                .id(selectionState)
////        }
////    }
////
////    private var bottomToolbar: some View {
////        HStack {
////            selectAllButton
////            Spacer()
////            addTodoButton
////        }
////    }
////
////    private var addTodoButton: some View {
////        Button {
////            viewModel.prepareNewTodo()
////        } label: {
////            Image(systemName: "plus")
////        }
////        .disabled(!selectedRows.isEmpty || editMode.isEditing)
////    }
////
////    private var editButton: some View {
////        Button(editMode.isEditing ? "Done" : "Edit") {
////            editMode = editMode.isEditing ? .inactive : .active
////            if !editMode.isEditing {
////                selectedRows.removeAll()
////            }
////        }
////        .opacity(viewModel.todos.isEmpty ? 0 : 1)
////    }
////
////    private var todoList: some View {
////        List(selection: $selectedRows) {
////            ForEach(viewModel.searchResults, id: \.id) { todo in
////                Text(todo.title)
////                    .swipeActions(edge: .trailing) {
////                        Button(role: .destructive) {
////                            viewModel.deleteTodo(todo)
////                        } label: {
////                            Label("Delete", systemImage: "trash")
////                        }
////                    }
////                    .id(todo.id)
////            }
////            .onMove(perform: viewModel.moveTodo(from:to:))
////        }
////        .environment(\.editMode, $editMode)
////    }
////
////    private struct EmptyListView: View {
////        @State private var isAppearing: Bool = false
////
////        var body: some View {
////            ContentUnavailableView {
////                Label(title: { Text("You're all done!") }, icon: {
////                    Image(systemName: "checkmark")
////                        .font(.system(size: 50))
////                        .symbolRenderingMode(.hierarchical)
////                        .foregroundStyle(.blue)
////                        .opacity(isAppearing ? 1 : 0)
////                        .scaleEffect(isAppearing ? 1 : 0.5)
////                        .animation(.spring(duration: 0.7), value: isAppearing)
////                        .onAppear {
////                            isAppearing = true
////                        }
////                })
////            } description: {
////                Text("Take a breather, then add what's next")
////            }
////        }
////    }
////
////    private struct TodoListMenu: View {
////        @Bindable var viewModel: TodoListViewModel
////
////        var body: some View {
////            Menu(content:{
////                Menu(content: {
////                    Button("Title") {
////                        viewModel.fetchTodos(sortedBy: .title)
////                    }
////                    Button("Created") {
////                        viewModel.fetchTodos(sortedBy: .created)
////                    }
////                }, label: {
////                    Label("Sort", systemImage: "arrow.up.arrow.down")
////                })
////            }, label: {
////                Label("Options", systemImage: "ellipsis.circle")
////            })
////            .menuStyle(.button)
////        }
////    }
////
////    private var selectAllButton: some View {
////        Button {
////            if selectedRows.count == viewModel.searchResults.count {
////                // Deselect all
////                selectedRows.removeAll()
////                selectionState.toggle()
////            } else {
////                // Select all
////                selectedRows = Set(viewModel.searchResults.map(\.id))
////                selectionState.toggle()
////            }
////        } label: {
////            Text(selectedRows.count == viewModel.searchResults.count ? "Deselect All" : "Select All")
////        }
////        .disabled(!editMode.isEditing)
////        .opacity(editMode.isEditing ? 1 : 0)
////    }
////}
////
////
////
////#Preview {
////    let config = ModelConfiguration(isStoredInMemoryOnly: true)
////    let container = try! ModelContainer(for: TodoItem.self, configurations: config)
////    let viewModel = TodoListViewModel(with: SwiftDataSource(container: container, context: ModelContext(container)))
////
////    TodoListView(viewModel: viewModel)
////        .onAppear {
////            viewModel.preloadSampleData()
////        }
////}
