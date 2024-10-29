import Combine
import UIKit

struct ContentItem: Hashable {
    let id: UUID
    let title: String
}

class CollectionViewModel {
    @Published var contentItems: [ContentItem] = []
    @Published var isLoading: Bool = false
    var count = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Initial mock data
        loadMoreData()
    }
    
    func loadMoreData() {
        guard !isLoading else { return } // Prevent multiple triggers
        isLoading = true
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            let newItems = (0..<20).map { _ in
                self.count += 1
                return ContentItem(id: UUID(), title: "Item \(self.count)")
            }
            DispatchQueue.main.async {
                self.contentItems.append(contentsOf: newItems)
                self.isLoading = false // Set loading to false after data is added
            }
        }
    }
}

class LoadingCellViewController: UIViewController {
    
    enum Section {
        case main
    }
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, ContentItem>!
    var viewModel = CollectionViewModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupDataSource()
        bindViewModel()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = view.bounds.size
        layout.minimumLineSpacing = 0 // No spacing between items
        layout.sectionInset = .zero   // No extra inset

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.isPagingEnabled = true
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "contentCell")
        collectionView.register(LoadingCollectionViewCell.self, forCellWithReuseIdentifier: "loadingCell")
        collectionView.backgroundColor = .white
        
        view.addSubview(collectionView)
    }
    
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, ContentItem>(collectionView: collectionView) {
            (collectionView, indexPath, contentItem) -> UICollectionViewCell? in
            
            // Handle loading cell case
            if contentItem.title.isEmpty { // The empty title indicates loading cell
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "loadingCell", for: indexPath) as? LoadingCollectionViewCell else {
                    return nil
                }
                cell.startLoading()
                return cell
            } else {
                // Normal content cell
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "contentCell", for: indexPath)
                cell.contentView.backgroundColor = .systemBlue
                cell.contentView.layer.cornerRadius = 8
                cell.contentView.clipsToBounds = true
                
                // Ensure any previously added views are removed from reuse
                for subview in cell.contentView.subviews {
                    subview.removeFromSuperview()
                }
                
                let label = UILabel(frame: cell.bounds)
                label.text = contentItem.title
                label.textAlignment = .center
                cell.contentView.addSubview(label)
                return cell
            }
        }
    }
    
    private func bindViewModel() {
        viewModel.$contentItems
            .sink { [weak self] items in
                self?.applySnapshot(for: items)
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .sink { [weak self] isLoading in
                self?.handleLoadingState(isLoading)
            }
            .store(in: &cancellables)
    }
    
    private func applySnapshot(for items: [ContentItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ContentItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        
        // Apply the snapshot
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func handleLoadingState(_ isLoading: Bool) {
        var snapshot = dataSource.snapshot()
        
        if isLoading {
            // Add the loading cell (special case with empty title)
            let loadingItem = ContentItem(id: UUID(), title: "") // Placeholder title for the loading cell
            snapshot.appendItems([loadingItem])
        } else {
            // Remove the loading cell
            if let lastItem = snapshot.itemIdentifiers.last, lastItem.title.isEmpty {
                snapshot.deleteItems([lastItem])
            }
        }
        
        // Apply the snapshot and ensure the layout is invalidated
        dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
            if let self {
                self.collectionView.layoutIfNeeded() // Force layout update
            }
        }
    }
}

extension LoadingCellViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Center the content vertically if it's smaller than the scroll view height
        centerVerticallyInScrollView(scrollView: scrollView)
    }
    
    private func centerVerticallyInScrollView(scrollView: UIScrollView) {
        // Calculate the vertical padding needed to center the content
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.bounds.height
        
        // Ensure that content is smaller than the scrollView, otherwise no padding is applied
        if contentHeight < scrollViewHeight {
            let verticalPadding = (scrollViewHeight - contentHeight) / 2
            scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: 0, bottom: verticalPadding, right: 0)
        } else {
            // Reset the insets when the content is larger than the scrollView
            scrollView.contentInset = .zero
        }
    }
}

extension LoadingCellViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Adjust the size of each item to be the same as the collection view's bounds
        return collectionView.bounds.size
    }
}

// Keep only the prefetching logic
extension LoadingCellViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let contentItems = viewModel.contentItems
        print(indexPaths)
        // Trigger loading more data when reaching near the end
        if indexPaths.contains(where: { $0.row >= contentItems.count - 3 }) && !viewModel.isLoading {
            viewModel.loadMoreData()
        }
    }
}

// Custom Loading Cell with Activity Indicator
class LoadingCollectionViewCell: UICollectionViewCell {
    private var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func startLoading() {
        activityIndicator.startAnimating()
    }
    
    func stopLoading() {
        activityIndicator.stopAnimating()
    }
}
