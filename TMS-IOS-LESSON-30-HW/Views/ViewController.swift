import UIKit

class ViewController: UIViewController {
    
    private enum Constants {
        static let title = "Gallery"
        static let horizontalPadding: CGFloat = 12
        static let imageWidth = Int(UIScreen.main.bounds.width) / 3 - 16
        static let imageHeight = 175
    }
    
    var galleryView: UICollectionView!
    
    private let customAlert = CustomAlert()
    
    private let emptyLabel = {
        let label = UILabel()
        label.text = "Empty list..."
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 30)
        label.layer.opacity = 0.1
        return label
    }()
    
    var images: [String] = [] {
        willSet {
            self.emptyLabel.isHidden = (newValue.count > 0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        customAlert.delegate = self
        
        setupNavigationBar()
        setupGalleryView()
        setupEmptyState()
        
        fetchDataFromCache()
    }
    
    private func fetchDataFromCache() {
        guard let storedData = StorageService.getValue(key: Keys.images) as? [String] else { return }
        images = storedData
    }
    
    private func setupNavigationBar() {
        navigationItem.title = Constants.title
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add))
        navigationItem.rightBarButtonItem = add
    }
    
    private func setupGalleryView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: Constants.horizontalPadding, bottom: 0, right: Constants.horizontalPadding)
        layout.itemSize = CGSize(width: Constants.imageWidth , height: Constants.imageHeight)
        galleryView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        galleryView.register(GalleryItem.self, forCellWithReuseIdentifier: "cell")
        galleryView.dataSource = self
        galleryView.delegate = self
    
        galleryView.showsVerticalScrollIndicator = true
        
        
        self.view.addSubview(galleryView)
        
    }
    
    private func setupEmptyState() {
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func add() {
        if(customAlert.backgroundView == nil) {
            self.customAlert.showAlert(title: "Add new image...", vc: self)
        }
    }
}




