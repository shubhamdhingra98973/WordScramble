//
//  ContentView.swift
//  WordScramble
//
//  Created by Apple on 05/02/21.
//

import SwiftUI

struct ContentView: View {
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var alertTitle = ""
    @State private var alertMsg = ""
    @State private var showingError = false
    
    var body : some View {
        NavigationView {
            VStack {
                TextField("Enter your word", text : $newWord , onCommit : addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                List(usedWords , id : \.self){
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
            }.navigationBarTitle(rootWord)
           
            //Challenge 3
            .navigationBarItems(trailing: Button(action : startGame){
                Text("Start Game")
            })
            .onAppear(perform : startGame)
            .alert(isPresented: $showingError) {
                Alert(title: Text(alertTitle), message: Text(alertMsg), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func startGame() {
        if let fileUrl = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: fileUrl) {
                let allwords = startWords.components(separatedBy: "\n")
                rootWord = allwords.randomElement()  ?? "silkworm"
                newWord = ""
               
                return
            }
        }
        fatalError("start.txt could not load from bundle..")
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
//        guard answer.count > 0 else
//        {
//            return
//        }
        ///Challenge 1
        guard wordTooShort(word: answer) else {
            wordError(errorTitle: "Word is too short", errorMsg: "Cannot consider")
            return
        }
        
        //Challenge 2
        guard sameAsStartWord(word: answer) else {
            wordError(errorTitle: "Same word as startword", errorMsg: "Cannot consider")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(errorTitle: "Word used Already", errorMsg: "Be Original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(errorTitle: "Word not recognized", errorMsg: "You can't just make them up , you know!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(errorTitle: "Word not possible", errorMsg: "That's not the real word")
            return
        }
        
        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    
    func isOriginal(word : String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func sameAsStartWord(word : String) -> Bool {
        return !word.elementsEqual(rootWord)
    }
    
    //Challenge1
    func wordTooShort(word : String) -> Bool {
        return !(word.count < 3)
    }
    
    func isPossible(word : String) -> Bool {
         
        var tempword = rootWord.lowercased()
        
        for letter in word {
            if let pos = tempword.firstIndex(of: letter){
                tempword.remove(at: pos)
            }
            else {
                return false
            }
        }
        return true
    }
    
    func isReal(word : String) -> Bool {
        
//        //Challenge 1
//        if word.count < 3 {
//            return false
//        }
        
        let textChecker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = textChecker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
     
    func wordError(errorTitle : String , errorMsg : String) {
        alertTitle = errorTitle
        alertMsg = errorMsg
        showingError = true
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
