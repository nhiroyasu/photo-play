import PhotoPlay
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

extension PhotoPlayViewController {
    enum FilterMenuSection: Int {
        case contents
    }

    enum FilterMenuItem: Hashable {
        case filter(type: FilterType, title: String, image: UIImage)
    }

    enum FilterType: Hashable {
        case original
        case chrome
        case fade
        case process
        case transfer
        case instant
        case vignette
        case sepia
        case mono
        case noir
        case tonal
        case thermal
        case xRay
    }

    func setUpFilterMenu() {
        let filterCellName = "PhotoPlayFilterMenuCell"
        filterCollectionView.register(
            UINib(nibName: filterCellName, bundle: Bundle.module),
            forCellWithReuseIdentifier: filterCellName
        )
        filterCollectionView.showsVerticalScrollIndicator = false
        filterCollectionView.showsHorizontalScrollIndicator = false
        filterCollectionView.collectionViewLayout = {
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(64),
                    heightDimension: .fractionalHeight(1)
                )
            )
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .estimated(.leastNormalMagnitude),
                    heightDimension: .fractionalHeight(1)
                ),
                subitems: [item]
            )
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 8
            section.contentInsets = .init(top: 8, leading: 16, bottom: 8, trailing: 16)
            let layout = UICollectionViewCompositionalLayout(section: section)
            let config = UICollectionViewCompositionalLayoutConfiguration()
            config.scrollDirection = .horizontal
            layout.configuration = config
            return layout
        }()
        filterDataSource = .init(collectionView: filterCollectionView, cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case let .filter(type, title, image):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: filterCellName, for: indexPath) as! PhotoPlayFilterMenuCell
                cell.configure(image: image, title: title) { [weak self] in
                    guard let self else { return }
                    selectedFilterType = type
                    canvasManager.applyImageFilter(imageFilters)
                }
                return cell
            }
        })
        var snapshot = NSDiffableDataSourceSnapshot<FilterMenuSection, FilterMenuItem>()

        canvasViewDispatchQueue.async(qos: .userInitiated) { [weak self] in
            guard let self else { return }

            let resizedImageSize: Float = 64 * Float(UIScreen.main.scale)
            let resizedImage: CIImage? = {
                let ciImage = CIImage(cgImage: self.image)

                let lanczosScaleFilter = CIFilter.lanczosScaleTransform()
                lanczosScaleFilter.inputImage = ciImage
                lanczosScaleFilter.scale = resizedImageSize / Float(self.image.width)
                return lanczosScaleFilter.outputImage
            }()

            if let resizedImage {
                snapshot.appendSections([.contents])
                snapshot.appendItems(
                    [
                        .filter(
                            type: .original,
                            title: "Original",
                            image: UIImage(ciImage: resizedImage)
                        ),
                        .filter(
                            type: .chrome,
                            title: "Chrome",
                            image: UIImage(ciImage: resizedImage.applyingFilter(.chrome))
                        ),
                        .filter(
                            type: .fade,
                            title: "Fade",
                            image: UIImage(ciImage: resizedImage.applyingFilter(.fade))
                        ),
                        .filter(
                            type: .process,
                            title: "Process",
                            image: UIImage(ciImage: resizedImage.applyingFilter(.process))
                        ),
                        .filter(
                            type: .transfer,
                            title: "Transfer",
                            image: UIImage(ciImage: resizedImage.applyingFilter(.transfer))
                        ),
                        .filter(
                            type: .instant,
                            title: "Instant",
                            image: UIImage(ciImage: resizedImage.applyingFilter(.instant))
                        ),
                        .filter(
                            type: .vignette,
                            title: "Vignette",
                            image: UIImage(ciImage: resizedImage.applyingFilter(.vignette(intensity: 0.5, radius: 10)))
                        ),
                        .filter(
                            type: .sepia,
                            title: "Sepia",
                            image: UIImage(ciImage: resizedImage.applyingFilter(.sepia(intensity: 0.5)))
                        ),
                        .filter(
                            type: .mono,
                            title: "Mono",
                            image: UIImage(ciImage: resizedImage.applyingFilter(.mono))
                        ),
                        .filter(
                            type: .noir,
                            title: "Noir",
                            image: UIImage(ciImage: resizedImage.applyingFilter(.noir))
                        ),
                        .filter(
                            type: .tonal,
                            title: "Tonal",
                            image: UIImage(ciImage: resizedImage.applyingFilter(.tonal))
                        ),
                        .filter(
                            type: .thermal,
                            title: "Thermal",
                            image: UIImage(ciImage: resizedImage.applyingFilter(.thermal))
                        ),
                        .filter(
                            type: .xRay,
                            title: "X-Ray",
                            image: UIImage(ciImage: resizedImage.applyingFilter(.xRay))
                        ),
                    ]
                )
                DispatchQueue.main.async { [weak self] in
                    self?.filterDataSource.apply(snapshot, animatingDifferences: false)
                }
            }
        }
    }

    // MARK: - Helpers

    func filterTypeToImageFilter(_ type: FilterType) -> ImageFilter {
        switch type {
        case .original: return .noFilter
        case .mono: return .mono
        case .noir: return .noir
        case .vignette: return .vignette(intensity: 0.5, radius: 10)
        case .sepia: return .sepia(intensity: 0.5)
        case .chrome: return .chrome
        case .fade: return .fade
        case .tonal: return .tonal
        case .process: return .process
        case .transfer: return .transfer
        case .instant: return .instant
        case .thermal: return .thermal
        case .xRay: return .xRay
        }
    }

    var imageFilters: [ImageFilter] {
        var filters: [ImageFilter] = []

        // add effect filter if needed
        if let selectedFilterType {
            filters.append(filterTypeToImageFilter(selectedFilterType))
        }

        // add control filters
        filters += [
            .brightness(amount: brightnessValue),
            .contrast(amount: contrastValue),
            .saturation(amount: saturationValue),
            .temperature(amount: CGFloat(6500 - temperatureDiffValue)),
            .sharpen(radius: 10, sharpness: sharpnessValue)
        ]

        return filters
    }
}
