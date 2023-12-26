import XCTest
@testable import BPETokenizer

final class BPETokenizerTests: XCTestCase {
    private var bpe: BPETokenizer!
    private var simpleText  = "そういう事はそんなに簡単なの？"
    private var apostroText = "You must've been a little sure've yerself to say he'll do that dont'che know."
    private var funkyText   = "f<unk>y|sa9jj2r ロK aFHh pO@ロHF $h oiA B-ロ____ロ______      :wej  lkj.,FqyMan"
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        let specialTokensMapPath = try XCTUnwrap(Bundle.module.url(forResource:"special_tokens_map", withExtension:"json"))
        let tokenizerPath = try XCTUnwrap(Bundle.module.url(forResource:"tokenizer", withExtension:"json"))
        
        bpe = try BPETokenizer(pathToTokenizerConfig: tokenizerPath, pathToSpecialTokensMap: specialTokensMapPath)
    }

    func testPretokenize() throws {
        let simplePre = bpe.preTokenize(simpleText)
        XCTAssertEqual(simplePre, ["ãģĿãģĨãģĦãģĨäºĭãģ¯ãģĿãĤĵãģªãģ«ç°¡åįĺãģªãģ®", "ï¼Ł"])
        
        let apostroPre = bpe.preTokenize(apostroText)
        XCTAssertEqual(apostroPre, ["You", "Ġmust", "'ve", "Ġbeen", "Ġa", "Ġlittle", "Ġsure",
                                    "'ve", "Ġyerself", "Ġto", "Ġsay", "Ġhe", "'ll", "Ġdo",
                                    "Ġthat", "Ġdont", "'", "che", "Ġknow", "."])
        let funkyPre = bpe.preTokenize(funkyText)
        XCTAssertEqual(funkyPre, ["f", "<", "unk", ">", "y", "|", "sa", "9", "jj", "2", "r",
                                  "ĠãĥŃK", "ĠaFHh", "ĠpO", "@", "ãĥŃHF", "Ġ$", "h", "ĠoiA",
                                  "ĠB", "-", "ãĥŃ", "____", "ãĥŃ", "______", "ĠĠĠĠĠ", "Ġ:",
                                  "wej", "Ġ", "Ġlkj", ".,", "FqyMan" ])
    }
    
    func testTokenize() throws {
        let simpleTokens = bpe.tokenize(simpleText)
        XCTAssertEqual(simpleTokens.map {$0.tokenId},
                       [48711, 5151, 9935, 22010, 6418, 15936, 13639, 6686, 5444, 163, 110, 96, 12363, 235, 6686, 3917, 26443])
        
        let apostroTokens = bpe.tokenize(apostroText)
        XCTAssertEqual(apostroTokens.map {$0.tokenId},
                       [1394, 1364, 1849, 644, 247, 1652, 2119, 1849, 340, 398, 
                        813, 281, 1333, 344, 1833, 513, 326, 13414, 8, 1962, 871, 15])

        
        let funkyTokens = bpe.tokenize(funkyText)
        XCTAssertEqual(funkyTokens.map {$0.tokenId},
                       [71, 29, 3938, 31, 90, 93, 6678, 26, 22492, 19, 83, 209, 24404,
                        44, 247, 36821, 73, 268, 48, 33, 24404, 21996, 370, 73, 258, 
                        74, 34, 378, 14, 24404, 1713, 24404, 1713, 876, 50272, 27, 664,
                        75, 50276, 77, 31169, 904, 39, 82, 90, 4779 ])
        
    }
    
    func testDecode() throws {
        let simpleTokens = bpe.tokenize(simpleText)
        XCTAssertEqual(simpleTokens.map {$0.chars},
        ["そう", "い", "う", "事", "は", "そ", "ん", "な", "に", "�", "�", "�", "�", "�", "な", "の", "？" ])
        
        let apostroTokens = bpe.tokenize(apostroText)
        XCTAssertEqual(apostroTokens.map {$0.chars},
                       ["You", " must", "'ve", " been", " a", " little", " sure", "'ve",
                       " y", "ers", "elf", " to", " say", " he", "'ll", " do", " that",
                       " dont", "'", "che", " know", "."])

        
        let funkyTokens = bpe.tokenize(funkyText)
        XCTAssertEqual(funkyTokens.map {$0.chars},
                       ["f", "<", "unk", ">", "y", "|", "sa", "9", "jj", "2", "r", " ", "ロ",
                        "K", " a", "FH", "h", " p", "O", "@", "ロ", "HF", " $", "h", " o", "i",
                        "A", " B", "-", "ロ", "____", "ロ", "____", "__", "      ", ":", "we",
                        "j", "  ", "l", "kj", ".,", "F", "q", "y", "Man"])
        
    }
}
