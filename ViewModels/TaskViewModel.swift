import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class TaskViewModel: ObservableObject {
    @Published private(set) var tasks: [TaskItem] = []
    @Published private(set) var isLoading = false
    @Published var onlyMine = false
    @Published var errorMessage: String?

    private let db = Firestore.firestore()
    private var teamId = ""

    // Reference to teams/{teamId}/tasks
    private var tasksRef: CollectionReference {
        db.collection(AppConfig.teamsCollection).document(teamId).collection(AppConfig.tasksCollection)
    }

    // Loads all tasks of one team
    func load(teamId: String) async {
        guard !teamId.isEmpty else { return }
        self.teamId = teamId
        isLoading = true
        defer { isLoading = false }
        do {
            let snapshot = try await tasksRef.getDocuments()
            tasks = snapshot.documents.compactMap { try? $0.data(as: TaskItem.self) }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // Tasks with one status, soonest due first; only uid's tasks when onlyMine is on
    func tasks(with status: TaskStatus, for uid: String) -> [TaskItem] {
        tasks
            .filter { $0.status == status && (!onlyMine || $0.assignedTo == uid) }
            .sorted { $0.dueDate < $1.dueDate }
    }

    // Saves a new task with status "todo"
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
            await load(teamId: teamId)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // Changes the status of one task in Firestore and in the local list
    func updateStatus(_ task: TaskItem, to status: TaskStatus) async {
        guard let id = task.id else { return }
        do {
            try await tasksRef.document(id).updateData(["status": status.rawValue])
            if let index = tasks.firstIndex(where: { $0.id == id }) {
                tasks[index].status = status
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // Deletes one task
    func delete(_ task: TaskItem) async {
        guard let id = task.id else { return }
        do {
            try await tasksRef.document(id).delete()
            tasks.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
