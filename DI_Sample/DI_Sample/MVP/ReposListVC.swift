//
//  ReposListVC.swift
//  DI_Sample
//
//  Created by sdk on 29.09.2021.
//

import UIKit

class ReposListVC: UIViewController, Storyboarded {
    
    var presenter: ReposListPresenter!
    
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var vwActivityIndicator: UIView!
    private let reusableCellIdentifier = "ReposListTableViewCell"
    private(set) var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        tblVw.register(UINib(nibName: reusableCellIdentifier, bundle: nil), forCellReuseIdentifier: reusableCellIdentifier)
        tblVw.delegate = self
        tblVw.dataSource = self
        tblVw.prefetchDataSource = self
        tblVw.estimatedRowHeight = UIScreen.main.bounds.width * 5.0 / 38.0
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl.tintColor = .green
        tblVw.addSubview(refreshControl)
        
        presenter.start()
    }
    @objc private func refresh(refresh: UIRefreshControl) {
        presenter.refresh() {
            DispatchQueue.main.async {
                refresh.endRefreshing()
            }
        }
    }


}

//MARK: UITableViewDelegate, UITabBarDelegate
extension ReposListVC: UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.models.count
    } 
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reusableCellIdentifier) as! ReposListTableViewCell
        let model = presenter.models[indexPath.row]
        cell.fill(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: isLoadingCell) {
            presenter.getNextPage()
        }
    }
    private func isLoadingCell(for indexPath: IndexPath) -> Bool {
        return indexPath.row >= presenter.numberOfModels - 1
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let yVelocity = scrollView.panGestureRecognizer.velocity(in: scrollView).y
        if yVelocity < 0 {
            let offset = scrollView.contentOffset
            let bounds = scrollView.bounds
            let size = scrollView.contentSize
            let inset = scrollView.contentInset
            let shiftingY = Float(offset.y + bounds.size.height - inset.bottom)
            let h = Float(size.height)
            var reload_distance: Float = 10
            if #available(iOS 11.0, *) {
                let window = UIApplication.shared.keyWindow
                reload_distance = Float(CGFloat(reload_distance) + (window?.safeAreaInsets.bottom ?? 0.0))
            }
            if shiftingY > h + reload_distance {
                presenter.getNextPage()
            }
        }
    }
}

extension ReposListVC: ReposListVCProtocol {
    func updateView() {
        DispatchQueue.main.async {
            self.tblVw.reloadData()
        }
    }
    func updateViewSync() {
        DispatchQueue.main.sync {
            self.tblVw.reloadData()
        }
    }
    func showErrorAlert(errorText: String) {
        DispatchQueue.main.sync {
            let alert = UIAlertController(title: "Oops...", message: errorText, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
                self?.refreshControl.endRefreshing()
            })
            present(alert, animated: true, completion: nil)
        }
    }
    func showAnimation() {
        DispatchQueue.main.async {
            self.vwActivityIndicator.isHidden = false
        }
    }
    func hideAnimation() {
        DispatchQueue.main.async {
            self.vwActivityIndicator.isHidden = true
        }
    }
}
