//
//  MyGoodsTableViewCell.swift
//  CoCo
//
//  Created by 최영준 on 12/02/2019.
//  Copyright © 2019 Team CoCo. All rights reserved.
//

import UIKit

class MyGoodsTableViewCell: UITableViewCell {
    // MARK: - Private properties
    private var data = [MyGoodsData]()
    private var action: Selector?
    private var enableEditing = false
    private var actionTarget: Any?
    private weak var viewController: UIViewController?

    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var empmtyLabel: UILabel!

    // MARK: - Lifecycles
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(UINib(nibName: Identifier.goodsCell, bundle: nil), forCellWithReuseIdentifier: Identifier.goodsCell)
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func prepareForReuse() {
        super .prepareForReuse()
        titleLabel.text = nil
        data.removeAll()
        empmtyLabel.isHidden = true
        collectionView.isHidden = false
    }

    // MARK: - Setting methods
    func updateContents(_ data: [MyGoodsData], viewController: UIViewController?, direction: UICollectionView.ScrollDirection = .horizontal) {
        if data.isEmpty {
            empmtyLabel.isHidden = false
            collectionView.isHidden = true
            return
        }
        self.data = data
        self.viewController = viewController
        setScrollDirection(direction)
        collectionView.reloadData()
    }

    func startEditing(_ isStart: Bool, target: Any?, delete: Selector?) {
        enableEditing = isStart
        action = delete
        actionTarget = target
    }

    private func setScrollDirection(_ direction: UICollectionView.ScrollDirection) {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = direction
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension MyGoodsTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier.goodsCell, for: indexPath) as? GoodsCell else {
            return UICollectionViewCell()
        }
        cell.myGoods = data[safeIndex: indexPath.row]
        cell.deleteButton.isHidden = !enableEditing
        if enableEditing, let action = action {
            cell.deleteButton.addTarget(actionTarget, action: action, for: .touchUpInside)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = viewController as? MyGoodsViewController, let goods = data[safeIndex: indexPath.row] {
            vc.performSegue(withData: goods)
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension MyGoodsTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // tableView leading(15) + trailing(15) + cell 사이 간격(10) = 40 / 보여지는 셀은 두 개(2)
        let cellWidth = Double((frame.size.width - 40) / 2)
        let cellHeight = cellWidth * 1.22
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

// MARK: - Private Structures
extension MyGoodsTableViewCell {
    private struct Identifier {
        static let goodsCell = "GoodsCell"
    }
}
