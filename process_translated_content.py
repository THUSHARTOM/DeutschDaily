import json
import re
import os
import sys

VOCAB = {}

def add_vocab(raw_word, translation="auto-translation"):
    word = raw_word.lower()
    # To handle punctuation attached in raw_word, let's clean it up slightly
    clean_word = re.sub(r'[^\wäöüÄÖÜß]', '', word)
    if clean_word and clean_word not in VOCAB:
        VOCAB[clean_word] = {"lemma": clean_word, "english": translation, "pos": "unknown"}

def main():
    base_dir = r"d:\Startup\DailyDeutsch\daily_deutsch_v1\assets"
    input_file = os.path.join(base_dir, "stories", "german_learning_stories_A1_B2_translated.json")
    
    with open(input_file, "r", encoding="utf-8") as f:
        data = json.load(f)
        
    raw_stories = data.get("stories", [])
    
    # Group by level
    grouped = {"A1": [], "A2": [], "B1": [], "B2": []}
    for s in raw_stories:
        lvl = s["level"]
        if lvl in grouped:
            grouped[lvl].append(s)
            
    # Process each level
    for level, stories in grouped.items():
        processed_stories = []
        
        # We need 20 stories. If the user provided less, we loop over them.
        target_count = 20
        source_count = len(stories)
        if source_count == 0:
            continue
            
        print(f"Processing {target_count} stories for level {level}...")
        
        for i in range(target_count):
            source_story = stories[i % source_count]
            
            # Change title slightly if it's a duplicate
            title = source_story["title"]
            if i >= source_count:
                title = f"{title} (Part { (i // source_count) + 1 })"
                
            text = source_story["text"]
            
            # Extract translated sentences and vocab
            translated_sentences = []
            sentences_data = source_story.get("sentences", [])
            for sent_data in sentences_data:
                translated_sentences.append(sent_data.get("en", "Translation not available."))
                
                # Extract words
                words_data = sent_data.get("words", [])
                for word_obj in words_data:
                    de_word = word_obj.get("de", "")
                    en_word = word_obj.get("en", "")
                    if de_word:
                        add_vocab(de_word, en_word)
                        
            # Also extract raw tokens from `text` just in case some words missed the translation object
            raw_tokens = re.findall(r'[a-zA-ZäöüÄÖÜß]+', text)
            for raw in raw_tokens:
                clean = raw.lower()
                if clean not in VOCAB:
                    add_vocab(raw, "auto-translated")
                
            processed_stories.append({
                "id": f"{level}_{i+1:03d}",
                "title": title,
                "level": level,
                "category": source_story.get("category", "general"),
                "text": text,
                "translatedSentences": translated_sentences,
                "keywords": source_story.get("keywords", [])
            })
            
        # Write level file
        filepath = os.path.join(base_dir, "stories", f"stories_{level}.json")
        with open(filepath, "w", encoding="utf-8") as f:
            json.dump(processed_stories, f, indent=2, ensure_ascii=False)
        print(f"Saved {filepath}")

    # Write dictionary
    dict_path = os.path.join(base_dir, "dictionary", "dictionary.json")
    with open(dict_path, "w", encoding="utf-8") as f:
        json.dump(VOCAB, f, indent=2, ensure_ascii=False)
    print(f"Saved dictionary with {len(VOCAB)} words: {dict_path}")

if __name__ == "__main__":
    main()
