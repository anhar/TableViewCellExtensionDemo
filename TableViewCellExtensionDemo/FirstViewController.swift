//
//  ViewController.swift
//  TableViewCellExtensionDemo
//
//  Created by Andreas Hård on 2018-07-13.
//  Copyright © 2018 Andreas Hård. All rights reserved.
//

import UIKit

class FirstViewController: UITableViewController, UITableViewDataSourcePrefetching {
    
    var viewModel: ViewModel!
    var images: [IndexPath : UIImage?] = [:]
    var imageTasks: [IndexPath : URLSessionDataTask?] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTableView()
        viewModel = ViewModel()
        self.title = viewModel.title.uppercased()
    }
    
    //MARK: Setup functions
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 44
        tableView.prefetchDataSource = self
        tableView.contentInset = UIEdgeInsets.init(top: 16, left: 0, bottom: 16, right: 0)
        tableView.separatorStyle = .singleLine
        tableView.registerReusableCell(IconTableViewCell.self)
        tableView.registerReusableCell(TextTableViewCell.self)
        tableView.registerReusableCell(PortraitImageTableViewCell.self)
        tableView.registerReusableHeaderFooterView(SectionHeaderView.self)
    }
    
    //MARK: Network functions
    
    func imageDataTask(forItemAt indexPath: IndexPath) -> URLSessionDataTask? {
        let sectionModel: SectionCapable = viewModel.sections[indexPath.section]
        guard let cellModel = sectionModel.rows[indexPath.row] as? ImageURLCellCapable else {
            return nil
        }
        guard let imageURL = cellModel.imageURL else {
            return nil
        }
        
        let dataTask = CachableImageApiRequest.sharedInstance.fetchImage(url: imageURL) { (result) in
            switch result {
            case let .success(image):
                self.images[indexPath] = image
                self.tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
            case let .failure(.generic(error)):
                print("Failed to fetch image url: \(imageURL)\n with error: \(error)")
            case let .failure(.cachedDataConversion(error)):
                print("Failed to convert cached data to UIImage for imageURL: \(imageURL)\n with error: \(error)")
            case let .failure(.downloadDataConversion(error)):
                print("Failed to convert data to UIImage for imageURL: \(imageURL)\n with error: \(error)")
            }
        }
        
        if dataTask != nil {
            imageTasks[indexPath] = dataTask
        }
        
        return dataTask
    }
    
    func requestImage(forItemAt indexPath: IndexPath){
        let sectionModel: SectionCapable = viewModel.sections[indexPath.section]
        guard sectionModel.rows[indexPath.row] is ImageURLCellCapable else {
            return
        }
        
        if let dataTask = imageTasks[indexPath] as? URLSessionDataTask {
            if dataTask.state == URLSessionTask.State.running {
                return
            }
        }
        
        if let task = imageDataTask(forItemAt: indexPath){
            task.resume()
        }
    }
    
    //MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionViewModel = viewModel.sections[section]
        return sectionViewModel.rows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionViewModel = viewModel.sections[indexPath.section]
        let cellViewModel = sectionViewModel.rows[indexPath.row]
        
        switch cellViewModel.cellId {
        case .icon:
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as IconTableViewCell
            if let imageCellViewModel = cellViewModel as? LocalImageCellCapable {
                cell.updateCell(with: imageCellViewModel)
            }
            
            return cell
        case .text:
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as TextTableViewCell
            cell.updateCell(with: cellViewModel)
            return cell
        case .portraitImage:
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as PortraitImageTableViewCell
            let image = images[indexPath]
            
            if let task = imageTasks[indexPath] {
                cell.isLoading = task?.state == .running
            } else if image == nil {
                cell.isLoading = true
                requestImage(forItemAt: indexPath)
            }
            
            if let portraitImage = image {
                cell.updateCell(with: cellViewModel.title, image: portraitImage)
                cell.isLoading = false
            } else {
                cell.updateCell(with: cellViewModel.title, image: nil)
            }
            
            return cell
        }
    }
    
    //MARK: UITableViewDataSourcePrefetching
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let sectionModel = viewModel.sections[indexPath.section]
            guard sectionModel.rows[indexPath.row] is ImageURLCellCapable else {
                return
            }
            
            if images[indexPath] == nil {
                requestImage(forItemAt: indexPath)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let sectionModel: SectionCapable = viewModel.sections[indexPath.section]
            guard sectionModel.rows[indexPath.row] is ImageURLCellCapable else {
                return
            }
            
            if let task = imageTasks[indexPath] as? URLSessionDataTask {
                if task.state != .canceling {
                    task.cancel()
                }
            }
        }
    }
    
    //MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionViewModel = viewModel.sections[section]
        let headerView = tableView.dequeueReusableHeaderFooterView() as SectionHeaderView
        headerView.updateView(title: sectionViewModel.title)
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

