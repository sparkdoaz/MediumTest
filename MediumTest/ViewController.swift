//
//  ViewController.swift
//  MediumTest
//
//  Created by 黃建程 on 2019/8/23.
//  Copyright © 2019 Spark. All rights reserved.
//

import UIKit
import Kingfisher
import CoreData
import MJRefresh

class ViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var manager = APIManager()
    
    var save: PurpleData?
    
    var hotlistdata: [Datum]?
    
    
    var nextPage: String?
    
    let header = MJRefreshNormalHeader()
    
    let footer = MJRefreshAutoNormalFooter()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        manager.delegate = self
        
//        gettoken.getToken()
        
        tableView.backgroundColor = .white
//
        tableView.delegate = self
        tableView.dataSource = self
        
        manager.getHotList()
        
        footer.setRefreshingTarget(self, refreshingAction: #selector(loadmoreData))
        
        tableView.mj_footer = footer

    }
    
    let imageHeight = UIScreen.main.bounds.width //與寬度等同
    
    @objc func loadmoreData() {

        print(nextPage)
        if nextPage != nil {
            manager.getNextHotList(next: nextPage!)
        }
        
        
        
    }


}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return imageHeight

    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: imageHeight, height: imageHeight))
        let url = URL(string: "https://i.kfs.io/playlist/global/26541395v266/cropresize/600x600.jpg")
        view.kf.setImage(with: url)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension

    }

}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hotlistdata?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? HotListCell else {return UITableViewCell()}
        
        
        guard let hotlistdata = hotlistdata else { return cell}

        cell.trackLabel.text = hotlistdata[indexPath.row].name
        
        let imageurl = URL(string: hotlistdata[indexPath.row].album.images[0].url)
        
        cell.cdImage.kf.setImage(with: imageurl)
        
        return cell
        
    }
    
    
}



extension ViewController: GetTokenAPIDelegate {
    func didGetNextHotList(didGet data: PurpleData) {
        save = data
        guard let save = save else { return}
        nextPage = save.paging.next
        hotlistdata?.append(contentsOf: save.data)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        print(hotlistdata?.count)
        footer.endRefreshing()

    }
    
    func didGetHotList(didGet data: PurpleData) {
        save = data
        guard let save = save else { return}
        
        nextPage = save.paging.next
        hotlistdata = save.data
//        print(save)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        print("First")
        print(hotlistdata?.count)
        print("firstNextPAge\(nextPage)")
    }
    
    func didGetToken() {
        
    }
    
    
}

extension ViewController {
    func saveToCoreData(index: IndexPath) {
        let manageContext = StorageManager.sharedManager.persistentContainer.viewContext
        
//        guard let hotListEntity = NSEntityDescription.entity(forEntityName: "Entity", in: manageContext) else {
//            return
//        }
//
//        let requeset = NSFetchRequest<Entity>(entityName: "Entity")
        guard let save = save else { return}
        
        for number in 0...save.data.count {
            
        }
        let  order = Entity(context: manageContext)
        order.index = Int32(index.row)
//        order.iamge =
    }
}
