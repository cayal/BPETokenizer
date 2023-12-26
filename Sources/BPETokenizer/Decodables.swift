import Foundation

public struct SpecialTokensMap: Decodable {
    var bosToken: Token
    var eosToken: Token
    var unkToken: Token
    
    public enum CodingKeys: CodingKey {
        case bos_token
        case eos_token
        case unk_token
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
                                                 
        let btChars = try container.decode(String.self, forKey: .bos_token)
        let etChars = try container.decode(String.self, forKey: .eos_token)
        let utChars = try container.decode(String.self, forKey: .unk_token)
        self.bosToken = Token(tokenId: -4345683, chars: btChars)
        self.eosToken = Token(tokenId: -4542291, chars: etChars)
        self.unkToken = Token(tokenId: -5590603, chars: utChars)
    }
}

// TODO Implement
public struct AddedToken: Decodable {
    var id: Int
    var content: String
    var single_word: Bool
    var lstrip: Bool
    var rstrip: Bool
    var normalized: Bool
    var special: Bool
}

public struct Normalizer: Decodable {
    var type: String
}

public struct TokenizerConfig: Decodable {
    var version: String
    var added_tokens: [AddedToken] // TODO Implement
    var normalizer: Normalizer
    var pre_tokenizer: TokenProcessor
    var post_processor: TokenProcessor
    var decoder: TokenProcessor
    var model: TokenizerModel
}

public struct TokenProcessor: Decodable {
    var type: String
    var add_prefix_space: Bool
    var trim_offsets: Bool
    var use_regex: Bool
}
