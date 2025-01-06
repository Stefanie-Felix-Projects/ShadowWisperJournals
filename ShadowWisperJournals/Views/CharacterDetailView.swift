//
//  CharacterDetailView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 06.01.25.
//

import SwiftUI

struct CharacterDetailView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var characterVM = CharacterViewModel()
    
    var character: Character
    
    @State private var name: String
    @State private var strength: Int
    @State private var agility: Int
    @State private var intelligence: Int
    @State private var backstory: String
    
    @State private var equipmentString: String
    @State private var skillsString: String
    
    init(character: Character) {
        self.character = character
        
        _name = State(initialValue: character.name)
        _strength = State(initialValue: character.attributes?["strength"] ?? 0)
        _agility = State(initialValue: character.attributes?["agility"] ?? 0)
        _intelligence = State(initialValue: character.attributes?["intelligence"] ?? 0)
        _backstory = State(initialValue: character.backstory ?? "")
        
        _equipmentString = State(initialValue: (character.equipment ?? [])
            .joined(separator: ", "))
        
        _skillsString = State(initialValue: (character.skills ?? [])
            .joined(separator: ", "))
    }
    
    var body: some View {
        Form {
            Section("Allgemeine Daten") {
                TextField("Name", text: $name)
            }
            
            Section("Attribute") {
                Stepper("Stärke: \(strength)", value: $strength, in: 0...20)
                Stepper("Geschicklichkeit: \(agility)", value: $agility, in: 0...20)
                Stepper("Intelligenz: \(intelligence)", value: $intelligence, in: 0...20)
            }
            
            Section("Ausrüstung") {
                TextField("Ausrüstung (Kommagetrennt)", text: $equipmentString)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }
            
            Section("Fertigkeiten") {
                TextField("Fertigkeiten (Kommagetrennt)", text: $skillsString)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }
            
            Section("Hintergrundgeschichte") {
                TextEditor(text: $backstory)
                    .frame(minHeight: 100)
            }
            
            Section {
                Button("Speichern") {
                    var updatedCharacter = character
                    updatedCharacter.name = name
                    updatedCharacter.attributes = [
                        "strength": strength,
                        "agility": agility,
                        "intelligence": intelligence
                    ]
                    
                    let equipmentArray = equipmentString
                        .split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    
                    let skillsArray = skillsString
                        .split(separator: ",")
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    
                    updatedCharacter.equipment = equipmentArray.isEmpty ? nil : equipmentArray
                    updatedCharacter.skills = skillsArray.isEmpty ? nil : skillsArray
                    updatedCharacter.backstory = backstory
                    
                    characterVM.updateCharacter(updatedCharacter)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Löschen", role: .destructive) {
                    characterVM.deleteCharacter(character)
                    dismiss()
                }
            }
        }
        .navigationTitle("Charakter bearbeiten")
        .onAppear {
            if !character.userId.isEmpty {
                characterVM.fetchCharacters(for: character.userId)
            }
        }
    }
}
