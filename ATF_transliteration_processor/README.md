# Normalization of Sumerian ATF-style transliteration.

The class `transliteration` allows parsing and normalizing individual tokens (words) transliterated in ATF-style. As the current version was created specifically for lemmatizers testing, it is task-specific and lacks certain features that might be useful for other purposes.

### Initial arguments:

- `translit`: ATF-transliterated token as string.

**IMPORTANT:** _different tokens should be processed separately_.

### Main properties:

- `raw_translit`: the ATF-transliterated token string
- `sign_list`: list of dictionaries representing signs; each has the following keys:
  - `value`: the sign value, i.e. reading
  - `index`: the sign's index
  - `emendation`: the sign in the text (only for emended signs)
  - `value_of`: primary sign name (only for signs with unclear index)
 
 **IMPORTANT:** _Determinatives are omitted at the moment_.
- `defective`: boolean variable, default False. A transliteration is marked as defective when contains unclear signs or values, as well as some other non-textual characters ('_', '...') and non-Sumerian (Akkadian) characters ('ṭ', 'ṣ').

**IMPORTANT:** _Transliterations marked as defective are not processed_. 
- `normalization`: The token's representation with glyph boundary, indices and other "non-phonetic" information removed. Overlapping vowels and consonants (common in phonetic complements) around glyph boundaries are not repeated.

**IMPORTANT:** _Although the normalization aims to similarity with the transcription, and in some cases, they do correspond, they should be always strictly distinguished_.
- `normalization_u`: Normalization with sign index higher than 1 escaped as Unicode characters. The Unicode character replaces the last vowel character of the sign. Use 'revert_unicode_index' to convert the Unicode normalization to a dictionary.

**IMPORTANT:** _Not recommended for use due to low efficiency_.

## Some basic ATF conventions commonly used in Sumerian transliterations:
- Word boundary: whitespace
- Glyph boundary: hyphen, dot (between uncertain signs)
- Emendation, omitted: < >
- Emendation, superfluous: << >>
- Lacuna: [ ]
- Notes: {!} {?}
- Determinative { }
- Unclear sign: X
- Unclear value: superscript
- Unclear index: ₓ (usually followed by superscript sign name in parentheses)

For a detailed description see http://oracc.museum.upenn.edu/doc/help/editinginatf/cdliatf/index.html
