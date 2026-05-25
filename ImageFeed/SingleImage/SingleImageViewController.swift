import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    // MARK: - Outlets

    @IBOutlet private weak var scrollView: UIScrollView?
    @IBOutlet private weak var imageView: UIImageView?

    // MARK: - Properties

    var imageUrl: URL?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView?.minimumZoomScale = 0.1
        scrollView?.maximumZoomScale = 1.25

        loadImage()
    }

    // MARK: - Actions

    @IBAction func didTapBackButton() {
        dismiss(animated: true)
    }

    @IBAction func didTapShareButton() {
        guard let image = imageView?.image else { return }

        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(activityVC, animated: true)
    }

    // MARK: - Private Methods

    private func loadImage() {
        guard let imageView else { return }

        UIBlockingProgressHUD.show()

        imageView.kf.setImage(with: imageUrl) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self = self else { return }

            switch result {
            case .success(let imageResult):
                imageView.frame.size = imageResult.image.size
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                self.showAlert(
                    title: "Что-то пошло не так(",
                    message: "Попробовать ещё раз?",
                    actions: [
                        UIAlertAction(title: "Не надо", style: .cancel),
                        UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
                            self?.loadImage()
                        }
                    ]
                )
            }
        }
    }

    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        guard let scrollView else { return }

        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(scrollView.maximumZoomScale,
                        max(scrollView.minimumZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
    }

    private func centerImage() {
        guard let scrollView else { return }
        let boundsSize = scrollView.bounds.size
        let contentSize = scrollView.contentSize

        let horizontalInset = max(0, (boundsSize.width - contentSize.width) / 2)
        let verticalInset = max(0, (boundsSize.height - contentSize.height) / 2)

        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
}

// MARK: - UIScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}
