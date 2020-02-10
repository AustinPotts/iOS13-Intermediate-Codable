import Foundation

// https://pokeapi.co/api/v2/pokemon/4





struct Pokemon: Decodable {
    
    let name: String
    let species: String
    let abilities: [String]
    
    //Step 2 Create coding keys
    enum Keys: String, CodingKey {
        case name
        case species
        case abilities
        
        enum SpeciesKeys: String, CodingKey {
            case name
        }
        
        enum AbilityDescriptionKeys: String, CodingKey {
            case ability
            
            enum AbilityKeys: String, CodingKey {
                case name
            }
        }
    }
    
    init(from decoder: Decoder) throws {
        
        //Step 1 Create the container
        let container = try decoder.container(keyedBy: Keys.self)
        
        name = try container.decode(String.self, forKey: .name)
        
        let speciesContainer = try container.nestedContainer(keyedBy: Keys.SpeciesKeys.self, forKey: .species) //Keys.SpeciesKeys to specify
        species = try speciesContainer.decode(String.self, forKey: .name)
        
        var abilitiesContainer  = try container.nestedUnkeyedContainer(forKey: .abilities)
        var abilityNames = [String]()
        
        while abilitiesContainer.isAtEnd == false {
            
            // abilitiesContainer points to the n'th element in the array
            
            let abilityDescriptionContainer = try abilitiesContainer.nestedContainer(keyedBy: Keys.AbilityDescriptionKeys.self)
            
            let abilityContainer = try abilityDescriptionContainer.nestedContainer(keyedBy: Keys.AbilityDescriptionKeys.AbilityKeys.self, forKey: .ability)
            
            let abilityName = try abilityContainer.decode(String.self, forKey: .name)
            abilityNames.append(abilityName)
            
        }
        
        abilities = abilityNames
        
    }
    
}


let url = URL(string: "https://pokeapi.co/api/v2/pokemon/4")!
let pokemonData = try! Data(contentsOf: url)

let decoder = JSONDecoder()

let pokemon = try decoder.decode(Pokemon.self, from: pokemonData)

print(pokemon)


