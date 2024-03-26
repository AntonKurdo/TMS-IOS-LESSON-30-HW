import UIKit

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = galleryView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! GalleryItem
        
        cell.remove = {
            ImageCaching.removeImage(name: self.images[indexPath.row]) {
                self.images.remove(at: indexPath.row)
                self.galleryView.performBatchUpdates({
                    self.galleryView.deleteItems(at: [indexPath])
                }) { _ in
                    self.galleryView.reloadData()
                }
            }
        }
        ImageCaching.loadImage(name: images[indexPath.row]) { img in
            if let img = img {
                cell.configure(image: img)
            }
        }
        
        return cell
    }
}

extension ViewController: CustomAlertDelegate {
    func onSuccessTapped(url urlString: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            let url = URL(string: urlString)!
            let data = try! Data(contentsOf: url)
            let urlComponent = URLComponents(string: urlString)
          
            let newImage = UIImage(data: data)
            let newImageIndex = self.images.count
            
            guard let imageName = urlComponent?.host else {return}
            ImageCaching.saveImage(newImage, "\(imageName)_\(newImageIndex)") { name in
                DispatchQueue.main.async {
                    self.images.append(name)
                    self.galleryView.insertItems(at: [IndexPath(item: newImageIndex, section: 0)])
                }
            }
        }
    }
}
