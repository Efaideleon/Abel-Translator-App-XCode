//
//  TwoPromptersView.swift
//  Abel-Translator-App
//
//  Created by Efai De leon on 1/10/24.
//

import SwiftUI
import Foundation

struct TwoPromptersView: View {
    //Words to be displayed on the prompter
    let englishWords: [String] = ["The", "little", "roadside-restaurant", "sat", "in", "the", "shadow", "of", "a", "colossal", "red-transport-truck,", "proudly", "displaying", "its", "affiliation", "with", "the", "OKLAHOMA CITY TRANSPORT COMPANY", "in", "bold", "letters."]
    let spanishWords: [String] = ["El", "pequeño", "restaurante al lado de la carretera", "se sentaba", "en", "la", "sombra", "de", "un", "colosal", "camion de transporte rojo,", "con orgullo", "mostrando", "su", "afiliacion", "con", "la", "OKLAHOMA CITY TRANSPORT COMPANY", "en", "grandes", "letras."]
    
    @ObservedObject var prompterModelView: PrompterModelView
    @State private var scrollToIndexTop: Int = 0
    @State private var scrollToIndexBottom: Int = 0
    @State private var timer: Timer?
    @State private var scrollViewProxyTop: ScrollViewProxy?
    @State private var scrollViewProxyBottom: ScrollViewProxy?
    private let scrollInterval: TimeInterval = 3.0
    
    init() {
        prompterModelView = PrompterModelView(length: englishWords.count)
    }
    
    var body: some View {
        // Scanning the Words Size
        VStack{
            sizeWidthView(words: englishWords.reversed(), prompterAddWord: prompterModelView.addWord(word:width:))
            sizeWidthView(words: spanishWords.reversed(), prompterAddWord: prompterModelView.addSpanishWord(word:width:))
        }.font(.system(size: 25))
        // Prompters
        VStack(alignment: .center){
            twoPromptersView(topRows: prompterModelView.words, bottomRows: prompterModelView.spanishWords)
        }.font(.system(size: 25))
    }
    
    // Sizing the words's width on screen on the horizontal windows, later to be deleted
    func sizeWidthView(words: [String], prompterAddWord: @escaping (_: String, _: CGFloat) -> Void) -> some View {
        return ScrollView {
            ForEach(words, id: \.self) { word in
                Text(word)
                    .background(
                        GeometryReader { geometry in
                            Color.red
                                .onAppear {
                                    prompterAddWord(word, geometry.size.width)
                                }
                        }
                    )
                    .fixedSize()
            }
        }.frame(height: 20)
    }
    
    // The prompter windows the top one and the bottom one
    func twoPromptersView (topRows: [[String]], bottomRows: [[String]]) -> some View {
        VStack {
            rowBuilderViewTop(rows: topRows)
                .foregroundColor(.white)
                .frame(width: Constants.Prompter.width, height: Constants.Prompter.height)
            rowBuilderViewBottom(rows: bottomRows)
                .foregroundColor(.white)
                .frame(width: Constants.Prompter.width, height: Constants.Prompter.height)
            Button("Start") {
                startAutoScrollTop(rows: topRows, numOfRows: topRows.count)
                startAutoScrollBottom(rows: bottomRows, numOfRows: bottomRows.count)
            }
            .background(Color.blue)
            .foregroundColor(.white)
        }
    }
    
    // The top prompter
    func rowBuilderViewTop(rows: [[String]]) -> some View {
        let rows: [[String]] = rows
        return VStack{
            ScrollViewReader{ scrollViewProxy in
                ScrollView{
                    LazyVStack(spacing: 30){
                        ForEach(rows, id: \.self) { row in
                            rowView(row: row)
                                .id(row)
                                .onAppear{
                                    scrollViewProxyTop = scrollViewProxy
                                }
                        }
                    }
                }
            }.background(Color.black)
        }
    }
    
    // The bottom prompter
    func rowBuilderViewBottom(rows: [[String]]) -> some View {
        let rows: [[String]] = rows
        return VStack{
            ScrollViewReader{ scrollViewProxy in
                ScrollView{
                    LazyVStack(spacing: 16){
                        ForEach(rows, id: \.self) { row in
                            rowView(row: row)
                                .id(row)
                                .onAppear{
                                    scrollViewProxyBottom = scrollViewProxy
                                }
                        }
                    }
                }
            }.background(Color.black)
        }
    }
    
    func rowView(row: [String]) -> some View {
        HStack(alignment: .center) {
            ForEach(row, id: \.self) { word in
                Text(word) // The actual word on screen
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private func startAutoScrollTop(rows: [[String]], numOfRows: Int) {
        timer = Timer.scheduledTimer(withTimeInterval: scrollInterval, repeats: true) { _ in
            scrollToIndexTop += 1
            if scrollToIndexTop < numOfRows {
                withAnimation {
                    scrollViewProxyTop?.scrollTo(rows[scrollToIndexTop], anchor: .bottom)
                }
            }
        }
    }
    
    private func startAutoScrollBottom(rows: [[String]], numOfRows: Int) {
        timer = Timer.scheduledTimer(withTimeInterval: scrollInterval, repeats: true) { _ in
            scrollToIndexBottom += 1
            if scrollToIndexBottom < numOfRows {
                withAnimation {
                    scrollViewProxyBottom?.scrollTo(rows[scrollToIndexBottom], anchor: .bottom)
                }
            }
        }
    }   
}


struct PrompterModel {
    private(set) var words: Array<Array<String>> = []
    private(set) var spanishWords: Array<Array<String>> = []
    private(set) var accumulatedWidth: CGFloat = 0
    private(set) var currentRow: Array<String> = []
    private(set) var currentSpanishRow: Array<String> = []
    private(set) var expectedLength: Int = 0
    private(set) var numOfWords: Int = 0
    private(set) var numOfSpanishWords: Int = 0
    private(set) var accumulatedSpanishWidth: CGFloat = 0
    private(set) var prompterWidth: CGFloat = Constants.Prompter.widthUsed
    private(set) var breaklineArray: Array<Bool>
    
    init(expectedLength: Int){
        self.expectedLength = expectedLength
        breaklineArray = Array(repeating: false, count: expectedLength)
    }
    
    mutating func addWord(word: String, width: CGFloat) {
        var br: Bool
        accumulatedWidth = accumulatedWidth + width
        
        if (accumulatedWidth > prompterWidth) {
            br = true
            words.append(currentRow)
            currentRow = []
            accumulatedWidth = width
            breaklineArray[numOfWords] = br
        }
        currentRow.append(word)
        
        numOfWords = numOfWords + 1
        if (numOfWords == expectedLength){
            words.append(currentRow)
        }
    }
    
    mutating func addspanishWord(word: String, width: CGFloat) {
        var br: Bool
        accumulatedSpanishWidth = accumulatedSpanishWidth + width
        
        if (accumulatedSpanishWidth > prompterWidth) {
            br = true
            spanishWords.append(currentSpanishRow)
            currentSpanishRow = []
            accumulatedSpanishWidth = width
            breaklineArray[numOfSpanishWords] = br
        }
        currentSpanishRow.append(word)
        
        numOfSpanishWords = numOfSpanishWords + 1
        if (numOfSpanishWords == expectedLength){
            spanishWords.append(currentSpanishRow)
        }
    }
}

class PrompterModelView: ObservableObject {
    @Published private var model: PrompterModel
 
    init (length: Int) {
        model = PrompterModel(expectedLength: length)
    }
    func addWord(word: String, width: CGFloat) {
        model.addWord(word: word, width: width)
    }
    
    var words: Array<Array<String>> {
        // When we return the array of array of words it must match with the breakline indications
        var englishWordsArray: Array<Array<String>> = []
        var wordCount: Int = 0
        var currentRow: Array<String> = []
        for rows in model.words {
            for _word in rows {
                if (model.breaklineArray[wordCount]) {
                    englishWordsArray.append(currentRow)
                    currentRow = []
                }
                currentRow.append(_word)
                wordCount += 1
            }
        }
        return englishWordsArray
    }
    
    func addSpanishWord(word: String, width: CGFloat) {
        model.addspanishWord(word: word, width: width)
    }
    
    var spanishWords: Array<Array<String>> {
        var spanishWordsArray: Array<Array<String>> = []
        var wordCount: Int = 0
        var currentRow: Array<String> = []
        for rows in model.spanishWords {
            for _word in rows {
                if (model.breaklineArray[wordCount]) {
                    spanishWordsArray.append(currentRow)
                    currentRow = []
                }
                currentRow.append(_word)
                wordCount += 1
            }
        }
        return spanishWordsArray
    }
}

struct Constants {
    struct Prompter{
        static let width: CGFloat = 900/UIScreen.main.scale
        static let height: CGFloat = 500/UIScreen.main.scale
        static let widthUsed: CGFloat = width * 0.80
    }
}

#Preview {
    TwoPromptersView()
}
