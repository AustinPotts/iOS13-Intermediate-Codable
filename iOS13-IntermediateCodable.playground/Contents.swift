import Foundation


// Intermediate Codable

// Star Wars

//




// Structs are Value types & classes are refrence types, we use structs for safety & speed

struct Person: Codable {
    
    let name: String
    let height: Int
    let hairColor: String
    
    
    let films: [URL ]//[String]
    let vehicles:  [URL] //[String]
    let starships:  [URL] //[String]
    
    enum PersonKeys: String, CodingKey {
        case name
        case height
        case hairColor = "hair_color"
        case films
        case vehicles
        case starships
    }
    
    // We want to take control of the decoding & encoding to do it ourselves because out of the box it doesnt give us all the things we need to convert
    
    // Keyed containers are like dictonaries
    // UnKeyed containers are like arrays
    // Single Value containers are just holding a single value
    init(from decoder: Decoder) throws {
        
        // Step 1. Create the container
        let container = try decoder.container(keyedBy: PersonKeys.self)
        // .self is because we refrenced the actual enum without initializing
        // we need to tell what type we are going to use
        
        
        name = try container.decode(String.self, forKey: .name) //String.self is telling this to use this type
        
        hairColor = try container.decode(String.self, forKey: .hairColor)
        
        let heightString = try container.decode(String.self, forKey: .height)
        height = Int(heightString) ?? 0
        
        
        // Using nested unkeyed container for array of values
        var filmsContainer = try container.nestedUnkeyedContainer(forKey: .films)
        var filmURLS = [URL]()
        
        while filmsContainer.isAtEnd == false {
            let filmString = try filmsContainer.decode(String.self)
            if let filmURL = URL(string: filmString) {
                filmURLS.append(filmURL)
            }
        }
        films = filmURLS
        
        // Compact Map - compact map will take in a value & transform it
        let vehiclesString = try container.decode([String].self, forKey: .vehicles)
        vehicles = vehiclesString.compactMap({ value in
            URL(string: value)
        })
        
        
        starships = try container.decode([URL].self, forKey: .starships)
    }
    
    
    func encode(to encoder: Encoder) throws {
        // Step 1 Make a container
        var container = encoder.container(keyedBy: PersonKeys.self)
        
        // encode (put in) the values in the container
        
        try container.encode(name, forKey: .name)
        
        try container.encode(hairColor, forKey: .hairColor)
        
        try container.encode("\(height)", forKey: .height)
        
        // approach #1 encode an array of URLs
        // {"films": []}
        var filmsContainer = container.nestedUnkeyedContainer(forKey: .films) //Arrays dont have keys
        for filmURL in films {
            try filmsContainer.encode(filmURL.absoluteString) // Returning strong value
        }
        
        let vehiclesString = vehicles.map { value in //We use map becuase it will never be nil
            value.absoluteString
        }
        
        try container.encode(vehiclesString, forKey: .vehicles)
        
        try container.encode(starships, forKey: .starships) // Because URL extends decodable protocol which extends to codable
    }
    
}
// THIS IS BAD WAY TO DO IT. URL Session is the proper way
let baseURL = URL(string: "https://swapi.co/api/people/1/")!
let data = try Data(contentsOf: baseURL)

let decoder = JSONDecoder()
let luke = try! decoder.decode(Person.self, from: data)

print(luke)

let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted]

let lukeData = try! encoder.encode(luke)
let lukeString = String(data: lukeData, encoding: .utf8)

print(lukeString)

// You are not limited to only json
let plistEncoder = PropertyListEncoder()
plistEncoder.outputFormat = .xml
let plistData = try! plistEncoder.encode(luke)
let plistString = String(data: plistData, encoding:  .utf8)!
print(plistString)


