//
//  AddCharacterView.swift
//  ShadowWisperJournals
//
//  Created by Stefanie Seeck on 06.01.25.
//

import SwiftUI

struct AddCharacterView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var characterVM: CharacterViewModel
    let userId: String

    @State private var name: String = ""
    @State private var strength: Int = 0
    @State private var agility: Int = 0
    @State private var intelligence: Int = 0
    @State private var backstory: String = ""

    @State private var equipmentString: String = ""
    @State private var skillsString: String = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)

                Section("Attribute") {
                    Stepper("Stärke: \(strength)", value: $strength, in: 0...20)
                    Stepper(
                        "Geschicklichkeit: \(agility)", value: $agility,
                        in: 0...20)
                    Stepper(
                        "Intelligenz: \(intelligence)", value: $intelligence,
                        in: 0...20)
                }

                Section("Ausrüstung") {
                    TextField(
                        "Ausrüstung (Kommagetrennt)", text: $equipmentString)
                }

                Section("Fertigkeiten") {
                    TextField(
                        "Fertigkeiten (Kommagetrennt)", text: $skillsString)
                }

                Section("Hintergrundgeschichte") {
                    TextEditor(text: $backstory)
                        .frame(minHeight: 100)
                }

                Button("Charakter hinzufügen") {
                    let attributes = [
                        "strength": strength,
                        "agility": agility,
                        "intelligence": intelligence,
                    ]

                    let equipmentArray =
                        equipmentString
                        .split(separator: ",")
                        .map {
                            $0.trimmingCharacters(in: .whitespacesAndNewlines)
                        }

                    let skillsArray =
                        skillsString
                        .split(separator: ",")
                        .map {
                            $0.trimmingCharacters(in: .whitespacesAndNewlines)
                        }

                    let now = Date()
                    let newCharacter = Character(
                        id: nil,
                        name: name,
                        attributes: attributes,
                        equipment: equipmentArray.isEmpty
                            ? nil : equipmentArray,
                        skills: skillsArray.isEmpty ? nil : skillsArray,
                        backstory: backstory.isEmpty ? nil : backstory,
                        userId: userId,
                        createdAt: now,
                        updatedAt: now
                    )

                    do {
                        _ = try characterVM.db.collection("characters")
                            .addDocument(from: newCharacter)
                    } catch {
                        print(
                            "Fehler beim Hinzufügen des Charakters: \(error.localizedDescription)"
                        )
                    }

                    dismiss()
                }
            }
            .navigationTitle("Neuer Charakter")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
        }
    }
}
