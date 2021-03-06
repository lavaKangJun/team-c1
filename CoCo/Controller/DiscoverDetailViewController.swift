//
//  DiscoverDetailViewController.swift
//  CoCo
//
//  Created by 강준영 on 14/02/2019.
//  Copyright © 2019 Team CoCo. All rights reserved.
//

import UIKit

class DiscoverDetailViewController: UIViewController {
    // MARK: - Propertise
    private let goodsIdentifier = "GoodsCell"
    private let searchWorCoreDataManager = SearchWordCoreDataManager()
    private let petKeywordCoreDataManager = PetKeywordCoreDataManager()
    private let networkManager = ShoppingNetworkManager.shared
    private let algorithmManager = Algorithm()
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: PinterestLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    private lazy var largeTitle: LargeTitle = {
        guard let largeTitle = Bundle.main.loadNibNamed("LargeTitle", owner: self, options: nil)?.first as? LargeTitle else {
            return LargeTitle()
        }
        largeTitle.translatesAutoresizingMaskIntoConstraints = false
        largeTitle.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        return largeTitle
    }()
    private lazy var headerView: DetailCategoryController = {
        let headerView = DetailCategoryController()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        return headerView
    }()
    private var activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
    fileprivate var discoverDetailService: DiscoverDetailService?
    fileprivate var searchWord = ""
    fileprivate var layout: PinterestLayout?
    fileprivate var isInserting = false
    fileprivate var pagenationNum = 1
    fileprivate var headerSize: CGFloat = 30
    var category: Category?
    var pet: Pet?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupNavigationView()
        setupHeader()
        setupCollctionView()
        setupIndicator()
        loadData()
        tabBarController?.tabBar.isHidden = true
        extendedLayoutIncludesOpaqueBars = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        setupNaviItemButton()
    }

    // MARK: - Setup Methodes
    func setupIndicator() {
        activityIndicatorView.color = UIColor.gray
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.frame = self.view.frame
        activityIndicatorView.center = self.view.center
        activityIndicatorView.startAnimating()
    }

    func setupNavigationView() {
        navigationItem.title = "COCO"
        navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.navigationBar.tintColor = AppColor.purple
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()

    }

    func setupNaviItemButton() {
        let buttonImage = UIImage(named: "list")?.withRenderingMode(.alwaysTemplate)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: buttonImage, style: .plain, target: self, action: #selector(sortGoods))
    }

    func setupCollctionView() {
        view.addSubview(collectionView)
        let goodsCellView = UINib(nibName: "GoodsCell", bundle: nil)
        collectionView.register(goodsCellView, forCellWithReuseIdentifier: goodsIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = PinterestLayout()
        collectionView.contentInset = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 0)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        layout = collectionView.collectionViewLayout as? PinterestLayout
        layout?.delegate = self
    }

    func setupHeader() {
        view.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 30)
            ])
        headerView.detailCategoryDelegate = self
        headerView.category = category
        headerView.pet = pet
    }

    // MARK: - DataLoad Method
    func loadData() {
        discoverDetailService = DiscoverDetailService(serachCoreData: searchWorCoreDataManager, petCoreData: petKeywordCoreDataManager, network: networkManager, algorithm: algorithmManager)
        guard let pet = pet else {
            return
        }
        guard let search = category?.getData(pet: pet).first else {
            return
        }
        discoverDetailService?.setPet(pet: pet)
        searchWord = search

        if !isInserting {
            isInserting = true
            discoverDetailService?.getShoppingData(start: pagenationNum - 1, search: searchWord, completion: { [weak self]
                (isSuccess, _, _) in
                guard let self = self else {
                    return
                }
                if isSuccess {
                    DispatchQueue.main.async {
                        self.activityIndicatorView.stopAnimating()
                        self.layout?.setCellPinterestLayout(indexPathRow: self.pagenationNum - 1) {}
                        self.collectionView.reloadData()
                        self.pagenationNum += 20
                    }
                    self.isInserting = false
                }
            })
        }
    }

    // MARK: - SortMethodes
    @objc func sortGoods() {
        let actionSheet = UIAlertController(title: nil, message: "정렬 방식을 선택해주세요", preferredStyle: .actionSheet)

        let sortSim = UIAlertAction(title: "유사도순", style: .default) { _ in
            self.sortChanged(sort: .similar)
        }
        let sortAscending = UIAlertAction(title: "가격 오름차순", style: .default) { _ in
            self.sortChanged(sort: .ascending)
        }
        let sortDescending = UIAlertAction(title: "가격 내림차순", style: .default) { _ in
            self.sortChanged(sort: .descending)
        }
        let sortDate = UIAlertAction(title: "날짜순", style: .default) { _ in
            self.sortChanged(sort: .date)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        actionSheet.addAction(sortSim)
        actionSheet.addAction(sortAscending)
        actionSheet.addAction(sortDescending)
        actionSheet.addAction(sortDate)
        actionSheet.addAction(cancel)

        present(actionSheet, animated: true, completion: nil)
    }

    func sortChanged(sort: SortOption) {
        activityIndicatorView.startAnimating()
        discoverDetailService?.sortOption = sort
        pagenationNum = 1
        self.discoverDetailService?.dataLists.removeAll()
        discoverDetailService?.getShoppingData(start: pagenationNum, search: searchWord ?? "") { [weak self](isSuccess, err, _) in
            guard let self = self else {
                return
            }
            if isSuccess {
                DispatchQueue.main.async {
                    self.activityIndicatorView.stopAnimating()
                    self.layout?.setupInit()
                    self.layout?.invalidateLayout()
                    self.collectionView.reloadData()
                    self.collectionView.setContentOffset(CGPoint.zero, animated: false)
                    self.pagenationNum += 20
                }
            } else {
                if err == NetworkErrors.noData {
                    self.alert("데이터가 없습니다. 다른 검색어를 입력해보세요")
                } else {
                    self.alert("네트워크 연결이 끊어졌습니다.")
                }
            }
        }
    }
}

extension DiscoverDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let dataCount = discoverDetailService?.dataLists.count else {
            return 0
        }
        return dataCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: goodsIdentifier, for: indexPath) as? GoodsCell else {
            return UICollectionViewCell()
        }
        cell.myGoods = discoverDetailService?.dataLists[indexPath.item]
        cell.isEditing = false
        cell.isLike = false
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let discoverDetailService = discoverDetailService else {
            return
        }
        let webViewStoryboard = UIStoryboard(name: "WebView", bundle: nil)
        guard let webViewController: WebViewController  = webViewStoryboard.instantiateViewController(withIdentifier: "WebViewController") as? WebViewController else {
            return
        }
        webViewController.sendData(discoverDetailService.dataLists[indexPath.item])
        navigationController?.pushViewController(webViewController, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollPosition = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y

        if scrollPosition > 0, scrollPosition < scrollView.contentSize.height * 0.1 {
            pagination()
        }
    }

    func getIndexPath(newData: Int) -> [IndexPath] {
        guard let discoverDetailService = discoverDetailService else {
            return []
        }
        var arrList = [IndexPath]()
        let startCount = discoverDetailService.dataLists.count - newData
        let endCount = startCount + newData
        (startCount..<endCount).forEach {
            arrList.append(IndexPath(item: $0, section: 0))
        }
        return arrList
    }

    func pagination() {
        if !isInserting {
            isInserting = true
            discoverDetailService?.getShoppingData(start: pagenationNum, search: searchWord, completion: { [weak self]
                (isSuccess, error, newData) in
                if let error = error {
                    print(error)
                }
                guard let self = self else {
                    return
                }
                guard let newData = newData else {
                    return
                }
                if isSuccess {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else {
                            return
                        }
                        self.layout?.setCellPinterestLayout(indexPathRow: self.pagenationNum - 1) {
                            self.collectionView.insertItems(at: self.getIndexPath(newData: newData))
                            self.pagenationNum += 20
                        }
                    }
                    self.isInserting = false
                }
            })
        }
    }
}

extension DiscoverDetailViewController: PinterestLayoutDelegate {
    // MARK: - Delegate Methodes
    func collectionView(_ collectionView: UICollectionView, heightForTitleIndexPath indexPath: IndexPath) -> CGFloat {
        guard let discoverDetailService = discoverDetailService else {
            return 0
        }
        let itemSize = (collectionView.frame.width / 2) - 40
        let title = discoverDetailService.dataLists[indexPath.item].title
        let attribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)]
        let option = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimateFrame = NSString(string: title).boundingRect(with: CGSize(width: itemSize, height: 1000), options: option, attributes: attribute, context: nil)
        return estimateFrame.height + view.frame.width*2/3
    }

    func headerFlexibleHeight(inCollectionView collectionView: UICollectionView, withLayout layout: UICollectionViewLayout, fixedDimension: CGFloat) -> CGFloat {
        return 0
    }
}

extension DiscoverDetailViewController: DetailCategoryControllerDelegate {
    func showGoods(indexPath: IndexPath, pet: Pet, detailCategory: String) {
        discoverDetailService?.dataLists.removeAll()
        searchWord = detailCategory
        pagenationNum = 1
        discoverDetailService?.getShoppingData(start: 1, search: detailCategory) { [weak self] (isSuccess, _, _) in
            if isSuccess {
                DispatchQueue.main.async { [weak self] in
                    self?.layout?.setupInit()
                    self?.layout?.invalidateLayout()
                    self?.collectionView.reloadData()
                    self?.collectionView.setContentOffset(CGPoint.zero, animated: false)
                    self?.pagenationNum += 20
                }
            }
        }
    }
}
