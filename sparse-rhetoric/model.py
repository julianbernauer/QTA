import os
os.chdir('U:\\topfish-master')

from embeddings import text_embeddings
import nlp
from helpers import io_helper
from sts import simple_sts 
from sys import stdin
import argparse
from datetime import datetime

supported_lang_strings = {"en" : "english", "fr" : "french", "de" : "german", "es" : "spanish", "it" : "italian"}

parser = argparse.ArgumentParser(description='Performs text scaling (assigns a score to each text on a linear scale).')
parser.add_argument('-d', '--datadir', default='U:\\topfish-master\\datadir_embed_pop', help='A path to the directory containing the input text files for scaling (one score will be assigned per file).')
parser.add_argument('-e','--embs', default='U:\\topfish-master\\embeddingspaces\\wiki.big-five.mapped.vec', help='A path to the file containing pre-trained word embeddings')
parser.add_argument('-o', '--output', default='C:\\Users\\Dr. J\\Desktop\\output',  help='Path for scaling results.')
parser.add_argument('-s', '--stopwords', default='U:\\topfish-master\\stopwords\\bigfive.txt', help='Path for stopwords')

args = parser.parse_args()

files = io_helper.load_all_files(args.datadir)
filenames = [x[0] for x in files]
texts = [x[1] for x in files]
filenames

# check sonderzeichen / UTF-8
texts[17]

languages = [x.split("\n", 1)[0].strip().lower() for x in texts]
languages
langs = [(l if l in supported_lang_strings.values() else supported_lang_strings[l]) for l in languages]

stopwords = io_helper.load_lines(args.stopwords)

predictions_serialization_path = args.output

embeddings = text_embeddings.Embeddings()
embeddings.load_embeddings(args.embs, limit = 1000000, language = 'default', print_loading = True, skip_first_line = True)

nlp.scale_efficient(filenames, texts, langs, embeddings, predictions_serialization_path, stopwords)
print(datetime.now().strftime('%Y-%m-%d %H:%M:%S') + " Scaling completed.", flush = True)

