//
//  ViewController.swift
//  CollectionSandbox
//
//  Created by Mateus Rodrigues on 30/04/22.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    let fractionalValue = 0.25
    
    lazy var compositionalLayout = UICollectionViewCompositionalLayout { [self] (index, _) in
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fractionalValue), heightDimension: .fractionalWidth(fractionalValue))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.orthogonalScrollingBehavior = .groupPagingCentered
        
        section.visibleItemsInvalidationHandler = { (items, offset, environment) in
            items.forEach { item in
                    let distanceFromCenter = abs((item.frame.midX - offset.x) - environment.container.contentSize.width / 2.0)
                    let minScale: CGFloat = 0.7
                    let maxScale: CGFloat = 1.0
                    let scale = max(maxScale - (distanceFromCenter / environment.container.contentSize.width), minScale)
                    item.transform = CGAffineTransform(scaleX: scale, y: scale)
                }
            DispatchQueue.global(qos: .background).async {
                let containerMidX = environment.container.contentSize.width / 2.0
                let itemAtCenter = items.first(where: { (($0.frame.midX - offset.x) - containerMidX).rounded() == 0 })
                if let itemAtCenter = itemAtCenter {
                    print(itemAtCenter.indexPath)
                }
            }
        }
        
        return section
    }
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: compositionalLayout)
    
    var orthogonalScrollView: UIScrollView? {
        didSet {
            initialOrthogonalOffset = orthogonalScrollView?.contentOffset ?? .zero
        }
    }
    
    var initialOrthogonalOffset = CGPoint.zero
    
    let numbers = Array(0...10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            collectionView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: fractionalValue),
        ])
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(CollectionViewHostingCell<ContentView>.self, forCellWithReuseIdentifier: "cell")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollViews(in: collectionView).forEach {
            self.orthogonalScrollView = $0
        }
    }
    
    func scrollViews(in subview: UIView) -> [UIScrollView] {
        var scrollViews: [UIScrollView] = []
        subview.subviews.forEach { view in
            if let scrollView = view as? UIScrollView {
                scrollViews.append(scrollView)
            } else {
                scrollViews.append(contentsOf: self.scrollViews(in: view))
            }
        }
        return scrollViews
    }
    
    
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numbers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewHostingCell<ContentView>
        cell.content = ContentView(number: numbers[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        orthogonalScrollView?.setContentOffset(orthogonalOffset(for: indexPath), animated: true)
    }
    
    func orthogonalOffset(for indexPath: IndexPath) -> CGPoint {
        return CGPoint(x: initialOrthogonalOffset.x + CGFloat(indexPath.item) * (fractionalValue * view.frame.width), y: 0)
    }
    
}

