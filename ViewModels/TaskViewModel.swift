import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class TaskViewModel: ObservableObject {
    @Published private(set) var tasks: [TaskItem] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    let isLeader: Bool
    private let teamId: String
    private let myUid: String
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    // Remembers which team this list is for and who is looking at it
    init(teamId: String, myUid: String, isLeader: Bool) {
        self.teamId = teamId
        self.myUid = myUid
        self.isLeader = isLeader
    }

    // Reference to teams/{teamId}/tasks
    private var tasksRef: CollectionReference {
        db.collection(AppConfig.teamsCollection).document(teamId).collection(AppConfig.tasksCollection)
    }

    // Leader listens to every task; a member only to tasks assigned to them
    func start() {
        guard listener == nil, !teamId.isEmpty else { return }
        isLoading = true
        let query: Query
        if isLeader {
            query = tasksRef
        } else {
            query = tasksRef.whereField("assignedTo", isEqualTo: myUid)
        }
        listener = query.addSnapshotListener { [weak self] snapshot, error in
            let tasks = snapshot?.documents.compactMap { try? $0.data(as: TaskItem.self) } ?? []
            let message = error?.localizedDescription
            Task { @MainActor in
                self?.apply(tasks: tasks, error: message)
            }
        }
    }

    // Removes the listener when the list leaves the screen
    func stop() {
        listener?.remove()
        listener = nil
    }

    // Stores the newest snapshot, soonest due date first
    private func apply(tasks: [TaskItem], error: String?) {
        isLoading = false
        if let error {
            errorMessage = error
            return
        }
        self.tasks = tasks.sorted { $0.dueDate < $1.dueDate }
    }

    // Usernames that have at least one task, A–Z (section headers for the leader)
    var assigneeNames: [String] {
        Array(Set(tasks.map(\.assignedToName))).sorted()
    }

    // Tasks of one member, still in due-date order
    func tasks(assignedTo name: String) -> [TaskItem] {
        tasks.filter { $0.assignedToName == name }
    }

    // Saves a new task with status "todo" (leader only)
    func add(title: String, details: String, assignedTo: String, assignedToName: String, dueDate: Date) async -> Bool {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty else {
            errorMessage = "Please enter a title."
            return false
        }
        guard !assignedTo.isEmpty else {
            errorMessage = "Please choose who the task is for."
            return false
        }
        let task = TaskItem(id: nil, title: cleanTitle,
                            details: details.trimmingCharacters(in: .whitespacesAndNewlines),
                            assignedTo: assignedTo, assignedToName: assignedToName,
                            status: .todo, dueDate: dueDate, createdAt: .now)
        do {
            let data = try Firestore.Encoder().encode(task)
            _ = try await tasksRef.addDocument(data: data)
            return true   // the listener adds it to the list
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // Changes the status of one task
    func updateStatus(_ task: TaskItem, to status: TaskStatus) async {
        guard let id = task.id else { return }
        do {
            try await tasksRef.document(id).updateData(["status": status.rawValue])
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // Deletes one task (leader only)
    func delete(_ task: TaskItem) async {
        guard let id = task.id else { return }
        do {
            try await tasksRef.document(id).delete()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
