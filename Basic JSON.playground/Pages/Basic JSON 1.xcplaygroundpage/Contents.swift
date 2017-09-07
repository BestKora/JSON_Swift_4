
/*:
  [Previous](@previous) | [Next](@next)
 ****
 # Полное соответствие структуры Модели и JSON
 
Если структура ваших данных в Swift точно соответствует структуре JSON объекта, то используйте для encoding (кодирования) и decoding (раскодирования) экземпляры классов JSONEncoder и JSONDecoder.
 
 */
import Foundation
let inputJSON = """
                {
                    "stat": "ok",
                    "blogs":
                        {
                            "blog":
                                [
                                    {
                                        "id" : 73,
                                        "name" : "Bloxus test",
                                        "needspassword" : true,
                                        "url" : "http://remote.bloxus.com/"
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

/* struct Stat: Codable {
    struct Blogs: Codable {
        struct Blog: Codable {
            let id: Int
            let name: String
            let needspassword : Bool
            let url: URL
        }
        let blog: [Blog]
    }
    let stat: String
    let blogs: Blogs
}*/

struct Stat: Codable {
let stat: String
    let blogs: Blogs
}

struct Blogs: Codable {
    let blog: [Blog]
}
struct Blog: Codable {
    let id: Int
    let name: String
    let needspassword : Bool
    let url: URL
}

let inputData =  inputJSON.data(using: .utf8)!
let decoder = JSONDecoder()
let stat = try! decoder.decode(Stat.self, from: inputData)
dump (stat)

let encoder = JSONEncoder ()
encoder.outputFormatting = .prettyPrinted
let data = try! encoder.encode(stat)
let json = String(data: data, encoding: .utf8)!
print(json)
