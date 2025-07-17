// Birthday.swift
// 生日数据模型
import Foundation
import CoreData

@objc(Birthday)
public class Birthday: NSManagedObject {
    @NSManaged public var name: String?
    @NSManaged public var date: Date? // 存储用户输入的日期
    @NSManaged public var isLunar: Bool // true: 农历, false: 公历
    @NSManaged public var relation: String?
    @NSManaged public var note: String?
    // 新增属性，自动转换的另一种历法日期
    @NSManaged public var lunarDateString: String? // 农历字符串
    @NSManaged public var solarDateString: String? // 公历字符串

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Birthday> {
        return NSFetchRequest<Birthday>(entityName: "Birthday")
    }
}

extension Birthday: Identifiable {}

// MARK: - Core Data Properties
// 注意：不要在 extension Birthday 中重复声明 fetchRequest，否则类型查找会冲突。
