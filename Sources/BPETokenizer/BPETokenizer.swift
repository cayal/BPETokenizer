import Foundation

public struct Token: Hashable, Decodable  { public var tokenId: Int; public var chars: String }
public struct TokenPair: Hashable { public var first: Token; public var second: Token }

public enum TokenizerError: Error {
    case badMerges, mergeNotInVocab, mergePieceNotInVocab
}

public class BPETokenizer {
    var config: TokenizerConfig
    var specialTokensMap: SpecialTokensMap
    var addPrefixSpace: Bool = false
    lazy var bytesChar: [UInt8:Character] = {
        var bs: [UInt8] = []
            bs += 33...126  // '!' to '~'
            bs += 161...172 // '\u{A1}' to '\u{AC}'
            bs += 174...255 // '\u{AE}' to '\u{FF}'

            var cs: [UInt32] = bs.map { UInt32($0) }
            var n: UInt32 = 0

            for b in UInt8.min...UInt8.max {
                if !bs.contains(b) {
                    bs.append(b)
                    cs.append(256 + n)
                    n += 1
                }
            }

            var resultMap: [UInt8: Character] = [:]
            for (f, t) in zip(bs, cs) {
                if let scalar = UnicodeScalar(t) {
                    resultMap[f] = Character(scalar)
                }
            }

            return resultMap
    }()
    
    lazy var charBytes: [Character:UInt8] = {
        var resultMap: [Character: UInt8] = [:]
        for (k, v) in bytesChar {
            resultMap[v] = k
        }
        return resultMap
    }()
    
    enum MergeMapKey: Hashable { case rank(Int); case pair(TokenPair) }
    let mergeMap: [MergeMapKey:Token]
    
    public convenience init(pathToTokenizerConfig: URL, pathToSpecialTokensMap: URL) throws {
        let specialTokensMapData = try Data(contentsOf:pathToSpecialTokensMap)
        let specialTokensMap = try JSONDecoder().decode(SpecialTokensMap.self, from:specialTokensMapData)
        
        let tokenizerData = try (Data(contentsOf:pathToTokenizerConfig))
        let tokenizerConfig = try JSONDecoder().decode(TokenizerConfig.self, from:tokenizerData)
        try self.init(config: tokenizerConfig, specialTokensMap: specialTokensMap)
    }
    
    public init(config: TokenizerConfig, specialTokensMap: SpecialTokensMap, addPrefixSpace: Bool = false) throws {
        self.config = config
        self.addPrefixSpace = addPrefixSpace
        self.specialTokensMap = specialTokensMap
        
        var map = [MergeMapKey:Token]()
        for (i, mergeRuleParts) in self.config.model.mergeRuleParts.enumerated() {
            guard let firstId  = config.model.vocab[mergeRuleParts.0],
                  let secondId = config.model.vocab[mergeRuleParts.1] else {
                throw TokenizerError.mergePieceNotInVocab
            }
            let pair = TokenPair(first:  Token(tokenId: firstId, chars: mergeRuleParts.0),
                                 second: Token(tokenId: secondId, chars: mergeRuleParts.1))
            let newToken = mergeRuleParts.0 + mergeRuleParts.1
            guard let newId = config.model.vocab[newToken] else {
                throw TokenizerError.mergeNotInVocab
            }
            let destination = Token(tokenId: newId, chars: newToken)
            map[MergeMapKey.pair(pair)] = destination
            map[MergeMapKey.rank(i)]    = destination
        }
        self.mergeMap = map
    }
    
    func preTokenize(_ str: String) -> [String] {
        let normalized = str.precomposedStringWithCanonicalMapping
        let regex = /'s|'t|'re|'ve|'m|'ll|'d| ?\p{L}+| ?\p{N}+| ?[^\s\p{L}\p{N}]+|\s+(?!\S)|\s+/
        let matches = normalized.matches(of: regex)
        let charLists = matches.map(
            {$0.utf8.map { String(bytesChar[$0]!) }.joined()}
        )
        return charLists
    }
    
    func postProcess(_ tokens: [Token]) -> [Token] {
        return tokens.map {
            Token(tokenId: $0.tokenId,
                  chars: $0.chars.map({ String(bytes: [charBytes[Character(extendedGraphemeClusterLiteral: $0)]!], encoding: .utf8) ?? "???" }).joined()
                  )
        }
    }
    
    func mergeSome(rule queryPair: TokenPair, destination token: Token, upon group: inout [Token]) {
        var i = group.startIndex
//        if group.contains(where: {$0.tokenId == 876}) {
//            print("Debugme")
//        }
        while group.count > 1  {
            guard group.indices.contains(i) else { break }
            // <(•_•<) ==> a, b, c | (a, [b), c] (anterior) [posterior]
            let anteriorPair  = i > group.startIndex && TokenPair(first: group[i - 1], second: group[i]) == queryPair ? true : false
            let posteriorPair = i < group.endIndex-1 && TokenPair(first: group[i], second: group[i + 1]) == queryPair ? true : false
            switch (anteriorPair, posteriorPair) {
            case (true, false):
                group[i - 1] = token
                group.remove(at: i)
            case (_,     true):
                group[i] = token
                group.remove(at: i + 1)
                i += 1
            default:
                i += 1
                break
            }
        }
    }
    
    func tokenForString(_ str: String) -> Token {
        guard let id = config.model.vocab[str] else { return specialTokensMap.unkToken }
        return Token(tokenId: id, chars: str)
    }
    
    public func tokenize(_ text: String) -> [Token] {
        let preTokenized: [String] = preTokenize(text)
        
        var tokenizationGroups: [[Token]] = preTokenized.map({
            $0.split(separator:"").map(String.init).map(tokenForString)
        })
        
        for queryRule in config.model.mergeRuleParts {
//            print(queryRule)
            let queryPair = TokenPair(first: tokenForString(queryRule.0), second: tokenForString(queryRule.1))
            guard let destinationToken = mergeMap[.pair(queryPair)] else { continue }
            for groupIn in tokenizationGroups.indices {
                mergeSome(rule: queryPair, destination: destinationToken, upon: &tokenizationGroups[groupIn])
            }
        }
        
        return tokenizationGroups.flatMap(postProcess)
    }
}
