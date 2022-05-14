//
//  ViewController.swift
//  QuizMock
//
//  Created by Omeir Ahmed on 25/04/2022.
//

protocol Router {
    func start()
    func routeToNext(question: String, options: [String])
    func routeToResults()
}

class NavigationControllerRouter: Router {
    
    let navigationController: UINavigationController
    let factory: ViewControllerFactory
    var questions = [String]()
    var completeOptions = [String: [String]]()
    var userAnsweredQuestions = [String: [String]]()
    
    init(navigationController: UINavigationController, factory: ViewControllerFactory) {
        self.navigationController = navigationController
        self.factory = factory
    }
    
    func start() {
        if let firstQuestion = questions.first {
            routeToNext(question: firstQuestion, options: completeOptions[firstQuestion]!)
        }
    }
    
    func routeToNext(question: String, options: [String]) {
       let vc = factory.getViewController(for: question, options: options) { [weak self] answers in
           self?.userAnsweredQuestions[question] = answers
           if self?.userAnsweredQuestions.count == self?.questions.count {
               self?.routeToResults()
            } else {
                let currentQuestionIndex = self?.questions.firstIndex(of: question)!
                let nextQuestionIndex = (currentQuestionIndex ?? 0) + 1
                let nextQuestion = self!.questions[nextQuestionIndex]
                self?.routeToNext(question: nextQuestion, options: self!.completeOptions[nextQuestion]!)
            }
        }
        self.navigationController.pushViewController(vc, animated: true)
    }
    
    func routeToResults() {
        let resultsViewController = UIViewController()
        resultsViewController.view.backgroundColor = .systemYellow
        self.navigationController.pushViewController(resultsViewController, animated: true)
    }
    
}

class ViewControllerFactory {
    func getViewController(for question: String, options: [String], selection: @escaping ([String]) -> Void) -> UIViewController {
        let viewController = ViewController()
        let viewModel = ViewModel(question: question, options: options)
        viewModel.onSelection = { question, selectedOptions in
            print(question, selectedOptions)
            selection(selectedOptions)
        }
        viewController.viewModel = viewModel
        viewController.loadViewIfNeeded()
        viewController.view.backgroundColor = .red
        return viewController
    }
    
    func getResultViewController() -> UIViewController {
        return UIViewController()
    }
}


class ViewModel {
    
    let question: String
    let options: [String]
    var onSelection: ((_ question: String, _ selectedOption: [String]) -> Void)?
    
    init(question: String, options: [String]) {
        self.question = question
        self.options = options
    }
    
    func didSelectRows(at indexPaths: [IndexPath]) {
        onSelection?(question, indexPaths.map({options[$0.row]}))
    }
    
}

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = viewModel.options[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.options.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didSelectRows(at: tableView.indexPathsForSelectedRows!)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.allowsMultipleSelection {
            viewModel.didSelectRows(at: tableView.indexPathsForSelectedRows!)
        }
    }
    
    var viewModel: ViewModel!

    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.delegate = self
        tv.dataSource = self
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        let label = UILabel()
        label.text = viewModel.question
        label.textAlignment = .center
        label.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        tableView.tableHeaderView = label
        NSLayoutConstraint.activate([tableView.topAnchor.constraint(equalTo: view.topAnchor),
                                     tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)])
        // Do any additional setup after loading the view.
    }


}

