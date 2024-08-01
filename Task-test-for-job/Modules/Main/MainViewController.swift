//
//  MainViewController.swift
//  Task-test-for-job
//
//  Created by Apple on 1.8.2024.
// Омурбек уулу Темирлан

import UIKit
import SnapKit
import Firebase
import Combine

class MainViewController: BaseViewController {
    
    private let tableView = UITableView()
    
    var tasks: [Task] = []
    
    private let sessionStore = SessionStore()
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBarComponents()
        setupTableView()
        loadCurrentUser()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.directionalEdges.equalToSuperview()
        }
    }
    
    private func setupNavBarComponents() {
        view.backgroundColor = .systemBackground
        title = "Главная"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addTaskTapped))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "iphone.and.arrow.forward"),
            style: .plain,
            target: self,
            action: #selector(loginOutTapped))
    }

    private func fetchTasks(for user: User) {
        TaskManager.shared.fetchTasks(for: user) { [weak self] result in
            switch result {
            case .success(let tasks):
                self?.tasks = tasks
                self?.tableView.reloadData()
            case .failure(let error):
                print("Error fetching tasks: \(error.localizedDescription)")
            }
        }
    }
    
    private func loadCurrentUser() {
        sessionStore.loadCurrentUser { [weak self] user in
            if let user = user {
                self?.fetchTasks(for: user)
            } else {
                print("Failed to load user")
            }
        }
    }
    
    @objc private func addTaskTapped() {
        let addTaskVC = AddTaskViewController()
        addTaskVC.delegate = self
        navigationController?.pushViewController(addTaskVC, animated: true)
    }
    
    @objc private func loginOutTapped() {
        sessionStore.signOut(from: self)
        
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        let editTaskVC = EditTaskViewController(task: task)
        editTaskVC.delegate = self
        navigationController?.pushViewController(editTaskVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
           return .delete
       }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = tasks[indexPath.row]
            TaskManager.shared.deleteTask(task) { [weak self] error in
                if let error = error {
                    print("Error deleting document: \(error)")
                } else {
                    self?.tasks.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true 
        }
}

extension MainViewController: AddTaskViewControllerDelegate, EditTaskViewControllerDelegate {
    
    func didEditTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            tableView.reloadData()
        }
    }
    
    func didAddTask(_ task: Task) {
        tasks.append(task)
        tableView.reloadData()
    }
    
    func didDeleteTask(_ task: Task) {
            if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                tasks.remove(at: index)
                tableView.reloadData()
            }
        }
}
