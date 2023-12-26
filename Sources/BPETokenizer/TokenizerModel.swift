import Foundation

public struct TokenizerModel: Decodable {
    var type: StringLiteralType = "BPE"
    var dropout: String?
    var unk_token: String?
    var continuing_subword_prefix: String?
    var end_of_word_suffix: String?
    var fuse_unk: Bool
    var vocab: [String:Int]
    var mergeRuleParts: [(String, String)]
    
    enum CodingKeys : String, CodingKey {
        case type, dropout, unk_token, continuing_subword_prefix, end_of_word_suffix, fuse_unk, vocab, merges
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        dropout = try? values.decode(String.self, forKey: .dropout)
        unk_token = try? values.decode(String.self, forKey: .unk_token)
        continuing_subword_prefix = try? values.decode(String.self, forKey: .continuing_subword_prefix)
        end_of_word_suffix = try? values.decode(String.self, forKey: .end_of_word_suffix)
        fuse_unk = try values.decode(Bool.self, forKey: .fuse_unk)
        vocab = try values.decode(Dictionary<String, Int>.self, forKey: .vocab)
        
        let mergeStrings = try values.decode(Array<String>.self, forKey: .merges)
        mergeRuleParts = try mergeStrings.map({
            let pieces = $0.split(separator: " ")
            guard pieces.count == 2 else {
                throw TokenizerError.badMerges
            }
            return (String(pieces[0]), String(pieces[1]))
        })
    }
}
