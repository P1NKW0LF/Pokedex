//
//  ContentView.swift
//  Pokedex
//
//  Created by Danny on 10/09/25.
//

import SwiftUI

// MARK: - Model

struct Pokemon: Identifiable {
    let id = UUID()
    let number: Int
    let name: String
    let types: [PokeType]
}

enum PokeType: String, CaseIterable, Identifiable { // Cambiar cuando implemente API
    case fire = "Fire"
    case water = "Water"
    case grass = "Grass"
    case electric = "Electric"
    case psychic = "Psychic"
    case rock = "Rock"
    case ground = "Ground"
    case ice = "Ice"
    case fighting = "Fighting"
    case poison = "Poison"
    case bug = "Bug"
    case dragon = "Dragon"
    case ghost = "Ghost"
    case dark = "Dark"
    case steel = "Steel"
    case fairy = "Fairy"
    case normals = "Normal"
    
    var id: String { rawValue }
}

// MARK: - View Screen

struct ContentView: View {
    @State private var searchText: String = ""
    @State private var selectedTypes: Set<PokeType> = []
    @State private var sortAscending: Bool = true
    
    // Layout columnas (2 columnas)
    private let columns = [GridItem(.flexible()),
                           GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    
                    // Search Bar
                    SearchBar(text: $searchText)
                        .padding(.horizontal)
                    
                    // Pokemon type filter
                    TypeChipsStrip(selected: $selectedTypes)
                        .padding(.horizontal)
                    
                    // Display Grid ya filtrados
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(filteredAndSorted) { pokemon in
                            PokemonCard(pokemon: pokemon)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }
                .padding(.top, 20)
            }
            .navigationTitle("Pokédex")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        sortAscending.toggle() // orden por ID
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
        }
    }
    
    // MARK: - Filtros
    
    private var filteredAndSorted: [Pokemon] {
        var PokemonsPrueba = sampleData
        
        // Normalizar texto
        let busqueda = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // Busqueda por nombre y numero de pokemon
        if !busqueda.isEmpty {
            PokemonsPrueba = PokemonsPrueba.filter {
                $0.name.lowercased().contains(busqueda) ||
                "#\(String(format: "%03d", $0.number))".contains(busqueda)
            }
        }
        
        // filtro por tipos de pokemon seleccionados
        if !selectedTypes.isEmpty {
            PokemonsPrueba = PokemonsPrueba.filter { !Set($0.types).isDisjoint(with: selectedTypes) }
        }
        
        // Ordenar por ID acendente o desendente
        PokemonsPrueba.sort { sortAscending ? $0.number < $1.number : $0.number > $1.number }
        return PokemonsPrueba
    }
}

// MARK: - Componentes

// Search bar creation
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
            TextField("Buscar Pokémon", text: $text) // preguntar porque el $
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 12)
            .strokeBorder(.secondary.opacity(0.4), lineWidth: 1))
    }
}

// Filtro de tipos de pokemones
struct TypeChipsStrip: View {
    @Binding var selected: Set<PokeType>
    
    private let all = Array(PokeType.allCases)
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) { // Espacio entre filtros
                ForEach(all) { type in
                    let isOn = selected.contains(type)
                    Button {
                        if isOn { selected.remove(type) } else { selected.insert(type) }
                    } label: {
                        HStack(spacing: 6) { // Espacio dentro del Filtro
                            Circle()
                                .strokeBorder(isOn ? Color.primary : Color.secondary.opacity(0.5), lineWidth: 2)
                                .frame(width: 16, height: 16)
                            Text(type.rawValue)
                                .font(.subheadline.weight(.medium))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Capsule()
                            .strokeBorder(isOn ? Color.primary : Color.secondary.opacity(0.35), lineWidth: 1)
                                .background(isOn ? Color.primary.opacity(0.08) : Color.clear)
                                .clipShape(Capsule())
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
    }
}


// Tarjetas de pokemones Creacion
struct PokemonCard: View {
    let pokemon: Pokemon
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
               
                Circle()
                    .strokeBorder(.secondary.opacity(0.6), lineWidth: 2)
                    .frame(width: 18, height: 18)
                Spacer()
            }
            VStack(alignment: .leading, spacing: 4) {
                
                // Pokemon name
                Text(pokemon.name)
                    .font(.title3.weight(.semibold))
                
                // Pokemon type
                Text(pokemon.types.map(\.rawValue).joined(separator: "/"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                // Pokemon number & Star
                HStack {
                    Text("#\(String(format: "%03d", pokemon.number))")
                        .font(.headline.monospaced())
                        .foregroundStyle(.orange)
                    Spacer()
                    Image(systemName: "star")
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 6)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(.secondary.opacity(0.4), lineWidth: 1)
        )
    }
}

// MARK: - Poquemones de prueba

private let sampleData: [Pokemon] = [
    .init(number: 1,  name: "Bulbasaur",  types: [.grass, .poison]),
    .init(number: 4,  name: "Charmander", types: [.fire]),
    .init(number: 7,  name: "Squirtle",   types: [.water]),
    .init(number: 25, name: "Pikachu",    types: [.electric]),
    .init(number: 52, name: "Meowth",     types: [.normals]),
    .init(number: 63, name: "Abra",       types: [.psychic]),
]



// MARK: - Preview

#Preview {
    ContentView()
}
