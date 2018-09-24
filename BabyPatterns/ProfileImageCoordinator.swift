import UIKit

public final class ProfileImageCoordinator: NSObject, ProfileViewDelegate {
    private weak var _rootVc: UIViewController?
    public var onImageChosen: ((UIImage) -> Void)?

    public init(rootVc: UIViewController) {
        _rootVc = rootVc
    }

    public func changeProfileImageButtonTapped() {
        let actionSheet = UIAlertController(title: "Change Profile Photo?", message: nil, preferredStyle: .actionSheet)

        let libraryOption = UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            self.profileImage(from: .photoLibrary)
        })

        let cameraOption = UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.profileImage(from: .camera)
        })

        let cancelOption = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            actionSheet.dismiss(animated: true, completion: nil)
        })

        actionSheet.addAction(libraryOption)
        actionSheet.addAction(cameraOption)
        actionSheet.addAction(cancelOption)

        _rootVc?.present(actionSheet, animated: true, completion: nil)
    }

    private func profileImage(from sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        _rootVc?.present(imagePicker, animated: true, completion: nil)
    }
}

extension ProfileImageCoordinator: UIImagePickerControllerDelegate,
                                   UINavigationControllerDelegate {

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }

        guard let resizedImage = resize(image: image) else { return }
        let vc = EditProfileImageVc(imageCandidate: resizedImage)
        vc.delegate = self
        _rootVc?.present(vc, animated: true, completion: nil)
    }

    fileprivate func resize(image: UIImage) -> UIImage? {
        guard let data = image.jpegData(compressionQuality: 0) else { return nil }
        guard let imageSource = CGImageSourceCreateWithData(data as NSData as CFData, nil) else { return nil }

        let options: [NSString: NSObject] = [
            kCGImageSourceThumbnailMaxPixelSize: (max(image.size.width, image.size.height) * 0.5) as NSObject,
            kCGImageSourceCreateThumbnailFromImageAlways: true as NSObject,
            kCGImageSourceCreateThumbnailWithTransform: true as NSObject,
        ]
        let thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary?)
        return thumbnail.flatMap { UIImage(cgImage: $0) }
    }

    private func rotatedImage(image: UIImage, orientation: UIImage.Orientation) -> UIImage {
        UIGraphicsBeginImageContext(image.size)

        let context = UIGraphicsGetCurrentContext()

        // TODO: use a switch statement silly
        if orientation == .right {
            context!.rotate(by: CGFloat(90) / CGFloat(180) * CGFloat.pi)
        } else if orientation == .left {
            context!.rotate(by: -CGFloat(90) / CGFloat(180) * CGFloat.pi)

        } else if orientation == .down {
            // NOTHING
        } else if orientation == .up {
            context!.rotate(by: CGFloat(90) / CGFloat(180) * CGFloat.pi)
        }

        image.draw(at: CGPoint(x: 0, y: 0))
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

extension ProfileImageCoordinator: EditProfileImageDelegate {
    public func profileImageEdited(image: UIImage) {
        onImageChosen?(image)
    }
}
