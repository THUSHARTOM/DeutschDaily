import json
import re
import os

VOCAB = {}

def add_vocab(raw_word, translation, level="unknown"):
    clean_word = re.sub(r'[^\wäöüÄÖÜß]', '', raw_word.lower())
    if clean_word and clean_word not in VOCAB:
        VOCAB[clean_word] = {
            "lemma": clean_word,
            "english": translation,
            "pos": level,
        }

def main():
    base_dir = r"d:\Startup\DailyDeutsch\daily_deutsch_v1\assets"
    input_file = os.path.join(base_dir, "stories", "german_learning_stories_A1_B2_translated_updated.json")

    with open(input_file, "r", encoding="utf-8") as f:
        data = json.load(f)

    stories = data.get("stories", [])
    print(f"Processing {len(stories)} stories...")

    for story in stories:
        story_level = story.get("level", "unknown")

        # Extract words from sentences
        sentences_data = story.get("sentences", [])
        for sent in sentences_data:
            words = sent.get("words", [])
            for word_obj in words:
                de_word = word_obj.get("de", "")
                en_word = word_obj.get("en", "")
                word_level = word_obj.get("level", story_level)
                if de_word:
                    add_vocab(de_word, en_word, word_level)

        # Also pull keywords
        keywords = story.get("keywords", [])
        keywords_en = story.get("keywords_en", [])
        for i, kw in enumerate(keywords):
            en = keywords_en[i] if i < len(keywords_en) else "unknown"
            add_vocab(kw, en, story_level)

    # Write dictionary
    dict_path = os.path.join(base_dir, "dictionary", "dictionary.json")
    with open(dict_path, "w", encoding="utf-8") as f:
        json.dump(VOCAB, f, indent=2, ensure_ascii=False)
    print(f"Saved dictionary with {len(VOCAB)} words: {dict_path}")

if __name__ == "__main__":
    main()
