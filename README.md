# BPETokenizer
(**Note: Under development!**)

## About
I've been sinking a lot of time lately into chasing reference implementations from Python into Swift. Wanting to match `tokenizers`' output as identically as possible, I made a class that loads `special_tokens_map.json` and `tokenizer.json` files to provide BPE tokenization.

## Usage
```
        let bpe = try BPETokenizer(pathToTokenizerConfig: ".../tokenizer.json", pathToSpecialTokensMap: ".../special_tokens_map.json")
        let tokens = bpe.tokenize("That's all I got.")
        > ([BPETokenizer.Token]) 6 values {
          [0] = (tokenId = 2773, chars = "That")
          [1] = (tokenId = 434, chars = "\'s")
          [2] = (tokenId = 512, chars = " all")
          [3] = (tokenId = 309, chars = " I")
          [4] = (tokenId = 1694, chars = " got")
          [5] = (tokenId = 15, chars = ".")
        }
```

## Contributing
All contributions welcome! The long-term goal of this project is to match `tokenizers`' output for as many BPE-based `tokenizer.json` configurations as possible.

### TODO
- [x] Pre-tokenization
- [x] Merge processing
- [ ] Handle added tokens (important)
- [ ] Handle out-of-vocab Unicode characters
- [ ] Handle prefix space, trim, fuse, prefix/suffix settings
- [ ] Alternative normalizations
