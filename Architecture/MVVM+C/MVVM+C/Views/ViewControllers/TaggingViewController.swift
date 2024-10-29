//
//  TaggingViewController.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 10/21/24.
//

import UIKit

struct ImageData: Codable {
    let originalImagePath: String
    let imagePath: String
    let buttons: [ButtonData]
}

struct ButtonData: Codable {
    let x: Double
    let y: Double
}

class TaggingViewController: UIViewController {
    lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    var imageArray: [ImageData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        loadExampleData()
    }
    
    func fetchExampleData() -> [ImageData]? {
        if let url = Bundle.main.url(forResource: "Tagging", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let response = try decoder.decode([ImageData].self, from: data)
                return response
            } catch let DecodingError.dataCorrupted(context) {
                print("Data corrupted: \(context.debugDescription)")
            } catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key)' not found:", context.debugDescription)
                print("CodingPath:", context.codingPath)
            } catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("CodingPath:", context.codingPath)
            } catch let DecodingError.typeMismatch(type, context) {
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("CodingPath:", context.codingPath)
            } catch {
                print("Error fetching json data: \(error.localizedDescription)")
            }
        } else {
            print("Error: JSON file not found")
        }
        return nil
    }

    func loadExampleData() {
        // Now we just handle the successfully fetched and decoded data
        guard let jsonData = fetchExampleData() else { return }
//        print("Decoded data: \(jsonData)")
        imageArray = jsonData
    }
}

extension TaggingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        imageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        if indexPath.row == 0 {
            cell.textLabel?.text = "Portrait"
        } else {
            cell.textLabel?.text = "Square"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = imageArray[indexPath.row]
        if indexPath.row == 0 {
            present(TaggingImageViewController(imageData: data, cropType: .none), animated: true, completion: nil)
        } else {
            present(TaggingImageViewController(imageData: data, cropType: .top), animated: true, completion: nil)
        }
    }
}
