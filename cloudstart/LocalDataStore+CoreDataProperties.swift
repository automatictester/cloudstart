import Foundation
import CoreData

extension LocalDataStore {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocalDataStore> {
        return NSFetchRequest<LocalDataStore>(entityName: "LocalDataStore")
    }

    @NSManaged public var instanceId: String?
    @NSManaged public var instanceType: String?
    @NSManaged public var name: String?
    @NSManaged public var state: String?

}
