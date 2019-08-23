//
//  Entity+CoreDataProperties.swift
//  
//
//  Created by 黃建程 on 2019/8/23.
//
//

import Foundation
import CoreData


extension Entity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Entity> {
        return NSFetchRequest<Entity>(entityName: "Entity")
    }

    @NSManaged public var iamge: String?
    @NSManaged public var save: Bool
    @NSManaged public var name: String?
    @NSManaged public var gggggggkkkkkk: String?
    @NSManaged public var index: Int32

}
