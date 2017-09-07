/*:
 [Previous](@previous) | [Next](@next)
 ****
 #  Несоответствие свойств Модели и JSON объекта
 
 Если имена свойств в некоторых структурах Swift данных не совпадают с именами ключей в соответствующих JSON объектах, то используйте перечисление  enum CodingKeys: String, CodingKey { } для задания соответствия между ними.
 
 Вы можете использовать при декодировании в JSONDecode не все поля JSON объекта, а выборочно.
 
 Не все свойства в Модели могут присутствовать в JSON объекте, в этом случае им присваивается значение nil и сами свойства Модели должны быть Optopnal.
 
 Свойствами могут быть массивы Array и словари Dictionary, которые работают с классами JSONEncoder и JSONDecoder автоматически и никаких дополнительных настроек не требуется, если иерархия Модели и основного JSON объекта совпадают.
 
 
 */

import Foundation

let inputJSON = """
                    {
                        "stat": "ok",
                        "pages": 1,
                        "blogs":
                            {
                            "blog":
                                [
                                    {
                                        "id" : 73,
                                        "name" : "Bloxus test",
                                        "needspassword" : true,
                                        "url" : "http://remote.bloxus.com/",
                                        "email" :
                                        [
                                            {"home":  "myHomeEmail@gmail.com"},
                                            {"work":  "myWorkEmail@gmail.com"}
                                        ],
                                        "create_at": "2017-08-22T12:19:00Z",
                                    },
                                    {
                                        "id" : 74,
                                        "name" : "Manila Test",
                                        "needspassword" : false,
                                        "url" : "http://flickrtest1.userland.com/"
                                    }
                                ]
                            }
                    }
                """

struct Stat: Codable {
//    let stat: String
    let blogs: Blogs
}

struct Blogs: Codable {
    let blog: [Blog]
}

struct Blog: Codable {
    let id: Int
    let name: String
    let needsPassword : Bool
    let url: URL
    let email: [[String:String]]?
    let createAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case needsPassword = "needspassword"
        case url
        case email
        case createAt = "create_at"
    }
}

let inputData =  inputJSON.data(using: .utf8)!
let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .iso8601
let stat = try! decoder.decode(Stat.self, from: inputData)
dump (stat.blogs)

let encoder = JSONEncoder ()
encoder.outputFormatting = .prettyPrinted
encoder.dateEncodingStrategy = .iso8601
let data = try! encoder.encode(stat)
let json = String(data: data, encoding: .utf8)!
print(json)

