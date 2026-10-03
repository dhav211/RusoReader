import UIKit

/// Loads the cover image by the given url, sets the size based on the given width which then sets the height based on a 2:3 ratio, applies a faint shadow behind the cover art for added depth. If there isn't a url or the url fails to load an image then a placeholder will be set instead of the image.
final class CoverImageView: UIView {
    private var imageUrl: String?
    private var width: CGFloat = 0
    private var height: CGFloat = 0
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(imageUrl: String?, height: CGFloat) {
        self.imageUrl = imageUrl
        self.height = height
        self.width = height * 0.66

        subviews.forEach { $0.removeFromSuperview() }
        NSLayoutConstraint.deactivate(constraints)

        if let coverImage = loadCoverImage() {
            // Applies the shadow to the container, since the image uses clipToBounds this will prevent the shadow from displaying
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.3
            layer.shadowOffset = CGSize(width: 0, height: 6)
            layer.shadowRadius = 6
            translatesAutoresizingMaskIntoConstraints = false
            
            // Create an imageView inside of the container
            let coverImageView = UIImageView(image: coverImage)
            coverImageView.contentMode = .scaleAspectFit
            coverImageView.clipsToBounds = true
            coverImageView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(coverImageView)
            
            // Set the containers size, and then constrain the image view inside the container
            NSLayoutConstraint.activate([
                widthAnchor.constraint(equalToConstant: width),
                heightAnchor.constraint(equalToConstant: height),
                coverImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
                coverImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
                coverImageView.topAnchor.constraint(equalTo: topAnchor),
                coverImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        } else {
            // TODO we will create a placeholder cover image, a subtle gradient with maybe the authors initials on it or maybe the first letter of the book
            // When we test this take an epub and remove the cover image and delete the reference to it
        }
    }
    
    private func loadCoverImage() -> UIImage? {
        guard let imageUrl else { return nil }
        do {
            let fileStore = FileStore()
            let data = try fileStore.load(fileName: imageUrl)
            return UIImage(data: data)
        } catch {
            print("\(error)")
            return nil
        }
    }
}
