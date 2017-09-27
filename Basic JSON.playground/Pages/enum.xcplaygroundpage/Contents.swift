/*:
 [Предыдущая страница](@previous)
 ****
 #  Использование протокола 'Codable' для перечислений 'enum'
 
 Для перечисления 'enum' ([enum]) необходимо указать тип вариантов, то есть "raw" value. Например, ниже представлено перечисление "Пол" 'Gender'в структуре 'Person", и тип его вариантов 'String'. Тип 'String' надо обязательно указать при подтверждении протокола 'Codable', и если этот тип реализует протокол 'Codable' (как в нашем случае с 'String') , то все будет в порядке. Это относится и к 'Int' и другим базовым типам.
 
 [enum]: https://littlebitesofcocoa.com/318-codable-enums  "Codable Enum"
 
 */
import Foundation

struct Person: Codable {
    enum Gender: String, Codable {
        case male, female, alien
    }
    var name: String
    var userName: String
    var gender: Gender
}

let person1 = Person(name: "Peter", userName: "pwitham", gender: .alien)
// Encode to JSON
let encoder = JSONEncoder ()
encoder.outputFormatting = .prettyPrinted
let data = try! encoder.encode(person1)
let json = String(data: data, encoding: .utf8)!

let decoder = JSONDecoder()
let person = try! decoder.decode(Person.self, from: data)
/*:
Но если у вас 'enum' с ассоциативными значениями^ как в случае с 'ContentKind', то вы должны взять на себя часть логики encode и decode.
 
 #### Во-первых, вам необходим свой собственный тип  'Swift Error' для "выбрасывания" ошибок, если что-то пойдет неправильно.
 
 #### Во-вторых, вам необходимо сообщить "ключи",  которые будут использоваться для encode и/или decode ваших данных. Для этого используется другое перечисление 'enum' 'CodingKeys', встроенное в протокол  'CodingKey'.

 #### В-третьих, вам необходимо реализовать две функции:
 
         init(from decoder: Decoder) throws
         func encode(to encoder: Encoder) throws
*/

enum ContentKind : Codable {
    case app (String)
    case movie(Int)
}

extension ContentKind {
    enum CodingError: Error { case decoding(String) }
    enum CodableKeys: String, CodingKey { case app, movie }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodableKeys.self)
        
        if let bundleID = try? values.decode(String.self, forKey: .app) {
            self = .app(bundleID)
            return
        }
        
        if let storeID = try? values.decode(Int.self, forKey: .movie) {
            self = .movie(storeID)
            return
        }
        
        throw CodingError.decoding("Decoding Failed. \(dump(values))")
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodableKeys.self)
        
        switch self {
        case let .app(bundleID):
            try container.encode(bundleID, forKey: .app)
        case let .movie(storeID):
            try container.encode(storeID, forKey: .movie)
        }
    }
}


let contentKind = ContentKind.app("Sorry!")
let esJsonEncoder = JSONEncoder()
let dataContent = try! esJsonEncoder.encode(contentKind)
let jsonContent = String(data: dataContent, encoding: .utf8)
let content = try! JSONDecoder().decode(ContentKind.self, from: dataContent)
type(of: content)
