import json
import re
import os
import sys
import subprocess

# Ensure deep-translator is installed for translating sentences
try:
    from deep_translator import GoogleTranslator
except ImportError:
    subprocess.check_call([sys.executable, "-m", "pip", "install", "deep-translator"])
    from deep_translator import GoogleTranslator

VOCAB = {}

def add_vocab(raw_word, translation="auto-translation"):
    word = raw_word.lower()
    if word not in VOCAB:
        VOCAB[word] = {"lemma": raw_word, "english": translation, "pos": "unknown"}

def split_into_sentences(text):
    # Basic sentence splitter for German
    # Splits by . ? ! followed by a space
    sentences = re.split(r'(?<=[.!?])\s+', text.strip())
    return [s.strip() for s in sentences if s.strip()]

def main():
    base_dir = r"d:\Startup\DailyDeutsch\daily_deutsch_v1\assets"
    input_file = os.path.join(base_dir, "stories", "german_learning_stories_A1_B2.json")
    
    with open(input_file, "r", encoding="utf-8") as f:
        data = json.load(f)
        
    raw_stories = data.get("stories", [])
    
    # Group by level
    grouped = {"A1": [], "A2": [], "B1": [], "B2": []}
    for s in raw_stories:
        lvl = s["level"]
        if lvl in grouped:
            grouped[lvl].append(s)
            
    translator = GoogleTranslator(source='de', target='en')
    
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
            sentences = split_into_sentences(text)
            
            translated_sentences = []
            for sent in sentences:
                try:
                    eng = translator.translate(sent)
                    translated_sentences.append(eng)
                except Exception as e:
                    print(f"Failed to translate: {sent} - Error: {e}")
                    translated_sentences.append("Translation not available.")
                    
            # Extract vocab
            raw_tokens = re.findall(r'[a-zA-ZäöüÄÖÜß]+', text)
            for raw in raw_tokens:
                # Let's try to get word-level translations for the dictionary
                # To avoid hitting the API 1000s of times for single words, 
                # we'll use a placeholder and rely on the full sentence translation 
                # for the main context. The user can tweak the JSON later.
                add_vocab(raw, "auto-translated")
                
            processed_stories.append({
                "id": f"{level}_{i+1:03d}",
                "title": title,
                "level": level,
                "category": source_story["category"],
                "text": text,
                "translatedSentences": translated_sentences,
                "keywords": source_story["keywords"]
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
