import UIKit
import ImageViewer_swift

class GalleryItem: UICollectionViewCell {
    
    private let imageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        return iv
    }()
    
    private let removeButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
        btn.tintColor = .red
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    var remove: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupContentView()
        setupImageView()
        setupRemoveBtn()
    }
    
//    override func prepareForReuse() {
//        imageView.image = UIImage(named: "DefaultImg")
//        remove = nil
//    }
//    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupContentView() {
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.7
        contentView.layer.shadowOffset = .zero
        contentView.layer.shadowRadius = 8
    }
    
    private func setupImageView() {
        contentView.addSubview(imageView)
        
        imageView.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
        ])
    }
    
    private func setupRemoveBtn() {
        imageView.addSubview(removeButton)
        NSLayoutConstraint.activate([
            removeButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 4),
            removeButton.rightAnchor.constraint(equalTo: imageView.rightAnchor, constant: -4),
            removeButton.widthAnchor.constraint(equalToConstant: 25),
            removeButton.heightAnchor.constraint(equalToConstant: 25),
        ])
        
        let action = UIAction {_ in
            self.remove?()
        }
        
        removeButton.addAction(action, for: .touchUpInside)
    }
    
    func configure(image: UIImage) {
        DispatchQueue.main.async {
            self.imageView.image = image
            self.imageView.setupImageViewer()
        }
    }
}



