import Foundation
import SwiftData

@MainActor
class VocabularyRepository {
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func addWord(_ word: VocabularyWord) {
        modelContext.insert(word)
        save()
    }
    
    func addContext(_ context: WordContext, to word: VocabularyWord) {
        word.contexts.append(context)
        context.vocabularyWord = word
        save()
    }
    
    func fetchWords() -> [VocabularyWord] {
        let descriptor = FetchDescriptor<VocabularyWord>(sortBy: [SortDescriptor(\.dateAdded, order: .reverse)])
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching words: \(error)")
            return []
        }
    }
    
    func searchWords(containing searchText: String) -> [VocabularyWord] {
        let predicate = #Predicate<VocabularyWord> { word in
            word.word.localizedStandardContains(searchText) ||
            word.definition.localizedStandardContains(searchText)
        }
        let descriptor = FetchDescriptor<VocabularyWord>(predicate: predicate, sortBy: [SortDescriptor(\.dateAdded, order: .reverse)])
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error searching words: \(error)")
            return []
        }
    }
    
    func deleteWord(_ word: VocabularyWord) {
        modelContext.delete(word)
        save()
    }
    
    func updateMastery(for word: VocabularyWord, level: Int) {
        word.masteryLevel = level
        save()
    }
    
    func incrementStudyCount(for word: VocabularyWord) {
        word.studyCount += 1
        save()
    }
    
    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}