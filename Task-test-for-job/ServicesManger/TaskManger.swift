//
//  TaskManger.swift
//  Task-test-for-job
//
//  Created by Apple on 1.8.2024.
//

import Firebase

final class TaskManager {
    static let shared = TaskManager()
    private let sessionStore = SessionStore()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func fetchTasks(for user: User, completion: @escaping (Result<[Task], Error>) -> Void) {
        db.collection("tasks").whereField("userId", isEqualTo: user.uid).getDocuments { querySnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                completion(.success([]))
                return
            }
            
            let tasks = documents.map { queryDocumentSnapshot -> Task in
                let data = queryDocumentSnapshot.data()
                let id = queryDocumentSnapshot.documentID
                let title = data["title"] as? String ?? ""
                let description = data["description"] as? String ?? ""
                let dueDate = data["dueDate"] as? Timestamp ?? Timestamp()
                return Task(id: id, title: title, description: description, dueDate: dueDate.dateValue())
            }
            completion(.success(tasks))
        }
    }
    
    func addTask(user: User, title: String, description: String, dueDate: Date, completion: @escaping (Result<Void, Error>) -> Void) {
            let data: [String: Any] = [
                "userId": user.uid,
                "title": title,
                "description": description,
                "dueDate": dueDate
            ]
            
            db.collection("tasks").addDocument(data: data) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    
    func deleteTask(_ task: Task, completion: @escaping (Error?) -> Void) {
        db.collection("tasks").document(task.id).delete(completion: completion)
    }
}
