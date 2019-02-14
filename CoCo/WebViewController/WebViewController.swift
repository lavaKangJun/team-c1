//
//  WebViewController.swift
//  CoCo
//
//  Created by 최영준 on 08/02/2019.
//  Copyright © 2019 Team CoCo. All rights reserved.
//

import UIKit
import WebKit

// TODO: WKWebView 로드시 메모리 누수 발생: JavaScriptCore 원인 찾아보기
class WebViewController: UIViewController {
    // MARK: - Private properties
    private var service: WebViewService?
    private var isFavorite = false
    private let webViewKeyPaths = [
        #keyPath(WKWebView.estimatedProgress)
    ]
    
    // MARK: - IBOutlets
    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet private weak var progressView: UIView!
    @IBOutlet private weak var favoriteButton: UIBarButtonItem!
    
    // MARK: - Required call methods
    // 웹 뷰 호출시 데이터를 전달한다. (필수)
    func sendData(_ data: MyGoodsData) {
        service = WebViewService(data: data)
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let myGoodsData = service?.myGoodsData else {
            let message = getErrorMessage(MyGoodsDataError.lostData)
            alert(message) { [weak self] in
                guard let self = self else {
                    return
                }
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        isFavorite = myGoodsData.isFavorite
        setWebView()
        setNavigationBar()
        setProgressView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        service?.insert()
        setFavoriteButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        service?.updateFavorite(isFavorite)
    }
    
    // MARK: - Observer related methods
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            updateProgressView(CGFloat(webView.estimatedProgress))
        }
    }
    
    private func addObserversToWebView() {
        for keyPath in webViewKeyPaths {
            webView.addObserver(self, forKeyPath: keyPath, options: .new, context: nil)
        }
    }
    
    // MARK: - Navigation related methods
    private func setNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.prefersLargeTitles = true
        if let title = service?.myGoodsData.shoppingmall {
            navigationItem.title = title
        }
        let backButton = UIBarButtonItem(image: UIImage(named: "left-arrow"), style: .plain, target: self, action: #selector(popViewController))
        backButton.tintColor = AppColor.purple
        navigationItem.leftBarButtonItem = backButton
        navigationItem.hidesBackButton = true
    }
    
    @objc private func popViewController() {
        navigationController?.popViewController(animated: false)
    }
    
    // MARK: - WebView related methods
    private func setWebView() {
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        guard let urlString = service?.myGoodsData.link, let url = URL(string: urlString) else {
            let message = getErrorMessage(MyGoodsDataError.invalidLink)
            alert(message) { [weak self] in
                guard let self = self else {
                    return
                }
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
        loadWebView(url)
        addObserversToWebView()
    }
    private func loadWebView(_ url: URL) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    // MARK: - ProgressView related methods
    private func setProgressView() {
        progressView.backgroundColor = AppColor.purple
    }
    
    private func updateProgressView(_ value: CGFloat) {
        progressView.frame.size.width = value * view.frame.width
    }
    
    // MARK: - Button related methods
    private func setFavoriteButton() {
        favoriteButton.image = (isFavorite) ?
            UIImage(named: "like_fill") : UIImage(named: "like")
    }
    
    // MARK: - Action methods
    @IBAction private func actionGoForward(_ sender: Any) {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    @IBAction private func actionGoBack(_ sender: Any) {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @IBAction private func actionReload(_ sender: Any) {
        webView.reload()
    }
    
    @IBAction private func actionShare(_ sender: Any) {
        guard let url = webView.url else {
            let message = getErrorMessage(MyGoodsDataError.invalidLink)
            alert(message)
            return
        }
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    @IBAction private func actionFavorite(_ sender: Any) {
        isFavorite = !isFavorite
        setFavoriteButton()
    }
}

// MARK: - WKNavigationDelegate
extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        // 웹뷰 로딩이 시작되면 progressView를 보여준다.
        progressView.isHidden = false
        view.bringSubviewToFront(progressView)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 웹뷰 로딩이 안료되면 progressView를 숨긴다.
        progressView.isHidden = true
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

// MARK: - UIScrollViewDelegate
extension WebViewController: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.y > 0 {
            navigationController?.setNavigationBarHidden(true, animated: false)
        } else {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
}

// MARK: - ErrorHandlerType
extension WebViewController: ErrorHandlerType { }
