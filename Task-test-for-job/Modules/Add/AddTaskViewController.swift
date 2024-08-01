//
//  MainViewController.swift
//  Task-test-for-job
//
//  Created by Apple on 1.8.2024.
//

import UIKit
import SnapKit
import Firebase
import FirebaseFirestore

protocol AddTaskViewControllerDelegate: AnyObject {
    func didAddTask(_ task: Task)
}

class AddTaskViewController: BaseViewController {
    
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
    
    let sessionStore = SessionStore()
    
    weak var delegate: AddTaskViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Добавить"
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        loadCurrentUser()
        setup()
    }
    
    private func setup() {
        setAddSubviews()
        setConstraints()
    }
    
    private func setAddSubviews() {
        view.addSubview(titleTextField)
        view.addSubview(descriptionTextField)
        view.addSubview(datePicker)
        view.addSubview(saveButton)
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
                self?.showAlert(title: "Ошибка", massage: "Пользователь не найден")
            }
        }
    }
    
    @objc private func saveButtonTapped() {
        guard let user = sessionStore.user else {
            showAlert(title: "Ошибка", massage: "Пользователь не найден")
            return
        }
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
        
        Firestore.firestore().collection("tasks").addDocument(data: data) { [weak self] error in
            if let error = error {
                self?.showAlert(title: "Ошибка", massage: error.localizedDescription)
            } else {
                Firestore.firestore().collection("tasks").whereField("userId", isEqualTo: user.uid).getDocuments { querySnapshot, error in
                    if let error = error {
                        self?.showAlert(title: "Ошибка", massage: error.localizedDescription)
                    } else if let document = querySnapshot?.documents.last {
                        let task = Task(id: document.documentID, title: title, description: description, dueDate: dueDate)
                        self?.delegate?.didAddTask(task)
                        DispatchQueue.main.async {
                            self?.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }
}
