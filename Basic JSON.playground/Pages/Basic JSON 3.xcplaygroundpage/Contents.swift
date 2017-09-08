/*:
 [Предыдущая страница](@previous) 
 ****
 #  Несоответствие иерархии Модели и JSON объекта
 
 Если мы хотим игнорировать некоторые контейнеры в JSON объекте или хотим существенно трансформировать в Модели его значения, то нам придется использовать init(from decoder:Decoder) throws и func encode(to encoder: Encoder) throws и более продвинутый API классов JSONEncoder и JSONDecoder
 
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

/*struct Stat: Codable {
    //    let stat: String
    let blogs: Blogs
}*/

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
    
    enum CodingKeys: String, CodingKey{
        case id
        case name
        case needsPassword = "needspassword"
        case url
        case email
        case createAt = "create_at"
    }
}

extension Blogs {
    private enum TopCodingKeys: String, CodingKey{
        case stat
        case blogs
        case pages
        case blog
    }
    
    init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: TopCodingKeys.self)
        
        // 1- ой способ : извлекаем сразу словарь [String:[Blog]]
        /*
        let blogs  = try container.decode([String:[Blog]].self, forKey: .blogs)
        self.init(blog: blogs["blog"]!)
        */
         // 2- ой способ : извлекаем массив [Blog]
        /*
         let meta  = try container.nestedContainer(keyedBy: TopCodingKeys.self,
                                                    forKey: .blogs)
         let blogs = try meta.decode([Blog].self, forKey: .blog)
         self.init(blog: blogs)
        */
        // 3- ий способ : извлекаем каждый элемент Blog массива отдельно
        //
         let meta  = try container.nestedContainer(keyedBy: TopCodingKeys.self,
                                                    forKey: .blogs)
         var blogsContainer = try meta.nestedUnkeyedContainer(forKey: .blog)
         var blogs: [Blog] = []
         while !blogsContainer.isAtEnd {
         let blog = try blogsContainer.decode(Blog.self)
         blogs.append(blog)
         }
         self.init(blog: blogs)
        
        //
    }
    
      func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: TopCodingKeys.self)
        try container.encode("ok", forKey: .stat)
        try container.encode(1, forKey: .pages)
           // 1- ой способ : записывам словарь ["blog": [Blog]]
        /*
        try container.encode(["blog": self.blog], forKey: .blogs)
        */
         // 2- ой способ : записывам массив [Blog]
        /*
        var meta = container.nestedContainer(keyedBy: BlogsCodingKeys.self,
                                              forKey: .blogs)
        try meta.encode(self.blog, forKey: .blog)
        */
           // 3- ий способ : записываем каждый элемент Blog массива отдельно,
           // возможно, с преобразованием
        var meta = container.nestedContainer(keyedBy: TopCodingKeys.self,
                                              forKey: .blogs)
        var blogArray = meta.nestedUnkeyedContainer(forKey: .blog)
        try blog.forEach {
            let blogEmailNil = Blog (id: $0.id,
                                   name: $0.name,
                          needsPassword: $0.needsPassword,
                                    url: $0.url,
                                  email: [["school":"school@gmail.com"]],
                               createAt: $0.createAt)
            try blogArray.encode($0.email == nil ? blogEmailNil : $0)
        }
    }
}

let inputData =  inputJSON.data(using: .utf8)!
let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .iso8601
let blogs = try! decoder.decode(Blogs.self, from: inputData)
dump (blogs)

let encoder = JSONEncoder ()
encoder.outputFormatting = .prettyPrinted
encoder.dateEncodingStrategy = .iso8601
let data = try! encoder.encode(blogs)
let json = String(data: data, encoding: .utf8)!
print(json)

