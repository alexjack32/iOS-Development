//
//  HomeViewController.swift
//  MVVM+C
//
//  Created by Alexander Jackson on 8/28/24.
//

import DD4Y_UIKit
import UIKit
import Combine

struct HomeViewModel {
    let text: String
    let viewController: UIViewController
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = items[indexPath.row].text
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedViewController = items[indexPath.row].viewController
        coordinator?.presentNextViewController(viewController: selectedViewController)
    }
}

class HomeViewController: UIViewController {
    weak var coordinator: MainCoordinator?
    var cancellable = Set<AnyCancellable>()

    let tableView: UITableView
    let displayView = BaseView()
    let items: [HomeViewModel] = [
        HomeViewModel(text: "Pokemon", viewController: PokemonViewController()
                     ),
        HomeViewModel(text: "Pexels", viewController: PexelsViewController()
                     ),
        HomeViewModel(text: "Pexels Videos", viewController: PexelsVideoViewController()
                     ),
        HomeViewModel(text: "Diffable Data Source", viewController: DiffableDataSourceViewController()
                     ),
        HomeViewModel(text: "Content Insets", viewController: ContentInsetsViewController()
                     ),
        HomeViewModel(text: "Tagging",
                      viewController: TaggingViewController()
                     ),
        HomeViewModel(text: "Overlay",
                      viewController: OverlayViewController()
                     ),
        HomeViewModel(text: "Loading Cell",
                      viewController: LoadingCellViewController()
                     )
    ]
    
    init() {
        self.tableView = UITableView()
        super.init(nibName: nil, bundle: nil)
        title = "MVVM+C Practice Sections"
        view.backgroundColor = .systemBlue
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testWordpressEndpoint()
        DispatchQueue.main.async { [weak self] in
            if let self,
               let navigationController = self.navigationController {
                navigationController.navigationBar.titleTextAttributes = [
                    NSAttributedString.Key.foregroundColor: UIColor.systemYellow
                ]
            }
        }
    }
    
    
    func testWordpressEndpoint() {
        guard let url = URL(string: "https://digitaldone4u.com/wp-json/wp/v2/posts") else { return }
        
        URLSession.shared
            .dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: DigitalDone4You.self, decoder: JSONDecoder())
            .tryMap { data -> Data in
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let data = try encoder.encode(data)
                guard let utfString = String(data: data, encoding: .utf8)?.data(using: .utf8) else {
                    fatalError()
                }
                return utfString
            }
            .sink(receiveCompletion: { completion in
                if case .failure(let failure) = completion {
                    print("Retrieving data failed with error: \(failure)")
                }
            },receiveValue: { response in
                if let value = String(data: response, encoding: .utf8) {
//                    print(value)
                }
            })
            .store(in: &cancellable)
        
    }
}


// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let digitalDone4You = try? JSONDecoder().decode(DigitalDone4You.self, from: jsonData)

import Foundation

// MARK: - DigitalDone4YouElement
struct DigitalDone4YouElement: Codable {
    let id: Int?
    let date, dateGmt: String?
    let guid: GUID?
    let modified, modifiedGmt, slug, status: String?
    let type: String?
    let link: String?
    let title: GUID?
    let content, excerpt: Content?
    let author, featuredMedia: Int?
    let commentStatus, pingStatus: String?
    let sticky: Bool?
    let template, format: String?
    let meta: Meta?
    let categories: [Int]?
    let tags: [JSONAny]?
    let classList: [String]?
    let jetpackSharingEnabled: Bool?
    let jetpackFeaturedMediaURL: String?
    let links: Links?

    enum CodingKeys: String, CodingKey {
        case id, date
        case dateGmt = "date_gmt"
        case guid, modified
        case modifiedGmt = "modified_gmt"
        case slug, status, type, link, title, content, excerpt, author
        case featuredMedia = "featured_media"
        case commentStatus = "comment_status"
        case pingStatus = "ping_status"
        case sticky, template, format, meta, categories, tags
        case classList = "class_list"
        case jetpackSharingEnabled = "jetpack_sharing_enabled"
        case jetpackFeaturedMediaURL = "jetpack_featured_media_url"
        case links = "_links"
    }
}

// MARK: - Content
struct Content: Codable {
    let rendered: String?
    let protected: Bool?
}

// MARK: - GUID
struct GUID: Codable {
    let rendered: String?
}

// MARK: - Links
struct Links: Codable {
    let linksSelf, collection, about: [About]?
    let author, replies: [Author]?
    let versionHistory: [VersionHistory]?
    let wpAttachment: [About]?
    let wpTerm: [WpTerm]?
    let curies: [Cury]?

    enum CodingKeys: String, CodingKey {
        case linksSelf = "self"
        case collection, about, author, replies
        case versionHistory = "version-history"
        case wpAttachment = "wp:attachment"
        case wpTerm = "wp:term"
        case curies
    }
}

// MARK: - About
struct About: Codable {
    let href: String?
}

// MARK: - Author
struct Author: Codable {
    let embeddable: Bool?
    let href: String?
}

// MARK: - Cury
struct Cury: Codable {
    let name, href: String?
    let templated: Bool?
}

// MARK: - VersionHistory
struct VersionHistory: Codable {
    let count: Int?
    let href: String?
}

// MARK: - WpTerm
struct WpTerm: Codable {
    let taxonomy: String?
    let embeddable: Bool?
    let href: String?
}

// MARK: - Meta
struct Meta: Codable {
    let jetpackMembershipsContainsPaidContent: Bool?
    let footnotes: String?

    enum CodingKeys: String, CodingKey {
        case jetpackMembershipsContainsPaidContent = "_jetpack_memberships_contains_paid_content"
        case footnotes
    }
}

typealias DigitalDone4You = [DigitalDone4YouElement]

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
            return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(0) // Adjust '0' to whatever value you need to hash
    }
    
    

    public init() {}

    public required init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if !container.decodeNil() {
                    throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
            }
    }

    public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encodeNil()
    }
}

class JSONCodingKey: CodingKey {
    let key: String

    required init?(intValue: Int) {
            return nil
    }

    required init?(stringValue: String) {
            key = stringValue
    }

    var intValue: Int? {
            return nil
    }

    var stringValue: String {
            return key
    }
}

class JSONAny: Codable {

    let value: Any

    static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
            return DecodingError.typeMismatch(JSONAny.self, context)
    }

    static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
            let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
            return EncodingError.invalidValue(value, context)
    }

    static func decode(from container: SingleValueDecodingContainer) throws -> Any {
            if let value = try? container.decode(Bool.self) {
                    return value
            }
            if let value = try? container.decode(Int64.self) {
                    return value
            }
            if let value = try? container.decode(Double.self) {
                    return value
            }
            if let value = try? container.decode(String.self) {
                    return value
            }
            if container.decodeNil() {
                    return JSONNull()
            }
            throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
            if let value = try? container.decode(Bool.self) {
                    return value
            }
            if let value = try? container.decode(Int64.self) {
                    return value
            }
            if let value = try? container.decode(Double.self) {
                    return value
            }
            if let value = try? container.decode(String.self) {
                    return value
            }
            if let value = try? container.decodeNil() {
                    if value {
                            return JSONNull()
                    }
            }
            if var container = try? container.nestedUnkeyedContainer() {
                    return try decodeArray(from: &container)
            }
            if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
                    return try decodeDictionary(from: &container)
            }
            throw decodingError(forCodingPath: container.codingPath)
    }

    static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
            if let value = try? container.decode(Bool.self, forKey: key) {
                    return value
            }
            if let value = try? container.decode(Int64.self, forKey: key) {
                    return value
            }
            if let value = try? container.decode(Double.self, forKey: key) {
                    return value
            }
            if let value = try? container.decode(String.self, forKey: key) {
                    return value
            }
            if let value = try? container.decodeNil(forKey: key) {
                    if value {
                            return JSONNull()
                    }
            }
            if var container = try? container.nestedUnkeyedContainer(forKey: key) {
                    return try decodeArray(from: &container)
            }
            if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
                    return try decodeDictionary(from: &container)
            }
            throw decodingError(forCodingPath: container.codingPath)
    }

    static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
            var arr: [Any] = []
            while !container.isAtEnd {
                    let value = try decode(from: &container)
                    arr.append(value)
            }
            return arr
    }

    static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
            var dict = [String: Any]()
            for key in container.allKeys {
                    let value = try decode(from: &container, forKey: key)
                    dict[key.stringValue] = value
            }
            return dict
    }

    static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
            for value in array {
                    if let value = value as? Bool {
                            try container.encode(value)
                    } else if let value = value as? Int64 {
                            try container.encode(value)
                    } else if let value = value as? Double {
                            try container.encode(value)
                    } else if let value = value as? String {
                            try container.encode(value)
                    } else if value is JSONNull {
                            try container.encodeNil()
                    } else if let value = value as? [Any] {
                            var container = container.nestedUnkeyedContainer()
                            try encode(to: &container, array: value)
                    } else if let value = value as? [String: Any] {
                            var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                            try encode(to: &container, dictionary: value)
                    } else {
                            throw encodingError(forValue: value, codingPath: container.codingPath)
                    }
            }
    }

    static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
            for (key, value) in dictionary {
                    let key = JSONCodingKey(stringValue: key)!
                    if let value = value as? Bool {
                            try container.encode(value, forKey: key)
                    } else if let value = value as? Int64 {
                            try container.encode(value, forKey: key)
                    } else if let value = value as? Double {
                            try container.encode(value, forKey: key)
                    } else if let value = value as? String {
                            try container.encode(value, forKey: key)
                    } else if value is JSONNull {
                            try container.encodeNil(forKey: key)
                    } else if let value = value as? [Any] {
                            var container = container.nestedUnkeyedContainer(forKey: key)
                            try encode(to: &container, array: value)
                    } else if let value = value as? [String: Any] {
                            var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                            try encode(to: &container, dictionary: value)
                    } else {
                            throw encodingError(forValue: value, codingPath: container.codingPath)
                    }
            }
    }

    static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
            if let value = value as? Bool {
                    try container.encode(value)
            } else if let value = value as? Int64 {
                    try container.encode(value)
            } else if let value = value as? Double {
                    try container.encode(value)
            } else if let value = value as? String {
                    try container.encode(value)
            } else if value is JSONNull {
                    try container.encodeNil()
            } else {
                    throw encodingError(forValue: value, codingPath: container.codingPath)
            }
    }

    public required init(from decoder: Decoder) throws {
            if var arrayContainer = try? decoder.unkeyedContainer() {
                    self.value = try JSONAny.decodeArray(from: &arrayContainer)
            } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
                    self.value = try JSONAny.decodeDictionary(from: &container)
            } else {
                    let container = try decoder.singleValueContainer()
                    self.value = try JSONAny.decode(from: container)
            }
    }

    public func encode(to encoder: Encoder) throws {
            if let arr = self.value as? [Any] {
                    var container = encoder.unkeyedContainer()
                    try JSONAny.encode(to: &container, array: arr)
            } else if let dict = self.value as? [String: Any] {
                    var container = encoder.container(keyedBy: JSONCodingKey.self)
                    try JSONAny.encode(to: &container, dictionary: dict)
            } else {
                    var container = encoder.singleValueContainer()
                    try JSONAny.encode(to: &container, value: self.value)
            }
    }
}
