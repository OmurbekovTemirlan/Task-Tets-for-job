//
//  EditTaskViewController.swift
//  Task-test-for-job
//
//  Created by Apple on 1.8.2024.
//

import UIKit
import SnapKit
import Firebase

protocol EditTaskViewControllerDelegate: AnyObject {
    func didEditTask(_ task: Task)
    func didDeleteTask(_ task: Task)
}

class EditTaskViewController: BaseViewController {
    
    weak var delegate: EditTaskViewControllerDelegate?
    
    private let titleTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Название"
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    private let descriptionTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Описание"
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    private let datePicker: UIDatePicker = {
        let date = UIDatePicker()
        date.datePickerMode = .date
        return date
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Сохранить", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "orange")
        button.layer.cornerRadius = 13
        return button
    }()
    
    let db = Firestore.firestore()
    
    let sessionStore = SessionStore()
    
    var task: Task
    
    init(task: Task) {
        self.task = task
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain,
            target: self,
            action: #selector(deleteButtonTapped))
        
        loadCurrentUser()
        setup()
        
        titleTextField.text = task.title
        descriptionTextField.text = task.description
        datePicker.date = task.dueDate
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    private func setup() {
        view.addSubview(titleTextField)
        view.addSubview(descriptionTextField)
        view.addSubview(datePicker)
        view.addSubview(saveButton)
        setConstraints()
    }
    
    private func setConstraints() {
        titleTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(120)
            make.centerX.equalToSuperview()
            make.directionalHorizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(100)
        }
        descriptionTextField.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.directionalHorizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(100)
        }
        datePicker.snp.makeConstraints { make in
            make.top.equalTo(descriptionTextField.snp.bottom).offset(10)
            make.trailing.equalToSuperview().inset(40)
        }
        saveButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-70)
            make.centerX.equalToSuperview()
            make.directionalHorizontalEdges.equalToSuperview().inset(70)
            make.height.equalTo(40)
        }
    }
    
    private func loadCurrentUser() {
        sessionStore.loadCurrentUser { [weak self] user in
            if let user = user {
                print("User loaded: \(user.uid)")
            } else {
                print("Failed to load user")
            }
        }
    }
    
    @objc private func saveButtonTapped() {
        guard let user = sessionStore.user else { return }
        guard let title = titleTextField.text, !title.isEmpty, let description = descriptionTextField.text, !description.isEmpty else {
            showAlert(title: "Ошибка", massage: "Название или описание пустые")
            return
        }
        let dueDate = datePicker.date
        let data: [String: Any] = [
            "userId": user.uid,
            "title": title,
            "description": description,
            "dueDate": dueDate
        ]
        
        db.collection("tasks").document(task.id).setData(data) { [weak self] error in
            if let error = error {
                self?.showAlert(title: "Ошибка", massage: error.localizedDescription)
            } else {
                let updatedTask = Task(id: self?.task.id ?? "", title: title, description: description, dueDate: dueDate)
                self?.delegate?.didEditTask(updatedTask)
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc private func deleteButtonTapped() {
        db.collection("task").document(task.id).delete { [ weak self ] error in
            if let error = error {
                self?.showAlert(title: "Ошибка", massage: error.localizedDescription)
            } else {
                self?.showAlertDelete()
                self?.delegate?.didDeleteTask(self!.task)
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func showAlertDelete() {
        let alert = UIAlertController(
            title: "Удалить задачу",
            message: "Вы уверены, что хотите удалить эту задачу?",
            preferredStyle: .alert
        )
        
        let acceptAction = UIAlertAction(title: "Да", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.db.collection("tasks").document(self.task.id).delete { [weak self] error in
                if let error = error {
                    self?.showAlert(title: "Ошибка", massage: error.localizedDescription)
                } else {
                    self?.delegate?.didDeleteTask(self!.task)
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
        
        let declineAction = UIAlertAction(title: "Нет", style: .cancel)
        
        alert.addAction(acceptAction)
        alert.addAction(declineAction)
        
        present(alert, animated: true)
    }
}

