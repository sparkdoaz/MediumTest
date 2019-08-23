//
//  ViewController.swift
//  MediumTest
//
//  Created by 黃建程 on 2019/8/23.
//  Copyright © 2019 Spark. All rights reserved.
//

import UIKit
import Kingfisher

class ViewController: UIViewController {
    @IBAction func test(_ sender: Any) {
        
        manager.getHotList()
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var manager = APIManager()
    
    var save: PurpleData?
    
    var 

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

    }
    
    let imageHeight = UIScreen.main.bounds.width //與寬度等同


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
        return save?.data.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? HotListCell else {return UITableViewCell()}
        
        guard let save = save else { return cell}
        
        cell.trackLabel.text = save.data[indexPath.row].name
        
        let imageurl = URL(string: save.data[indexPath.row].album.images[0].url)
        
        cell.cdImage.kf.setImage(with: imageurl)
        
        return cell
        
    }
    
    
}



extension ViewController: GetTokenAPIDelegate {
    func didGetHotList(didGet data: PurpleData) {
        save = data
        guard let save = save else { return}
        
        print(save)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        
    }
    
    func didGetToken() {
        
    }
    
    
}
