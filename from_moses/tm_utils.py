from __future__ import print_function
import platform, re, regex, string, textwrap, autocorrect, sys, os, codecs, calendar, random, pickle, numpy as np, pandas as pd, bs4, urllib, textacy, logging, cufflinks as cf
# , seaborn as sns
#print all logging.INFO details
#logging.basicConfig(format='%(asctime)s : %(levelname)s : %(message)s', level=logging.INFO)
#Supress default INFO logging
logger = logging.getLogger()
logger.setLevel(logging.CRITICAL)
from time import time
from itertools import groupby
from  more_itertools import unique_everseen
from operator import itemgetter
from bs4 import BeautifulSoup
from urllib.request import urlopen
from textwrap import fill
#import pycontractions
#from pycontractions import Contractions
from autocorrect import spell
from textacy import preprocessing
# text3 = preprocessing.normalize_whitespace(text2)
# from textacy.preprocess import remove_punct
from datetime import datetime
from pprint import pprint
from collections import Counter
from wordcloud import WordCloud, STOPWORDS
#allow offline use of cufflinks
cf.go_offline()

# Plotting-related
import matplotlib
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle
# from matplotlib import pyplot as plt
# from matplotlib.gridspec import GridSpec
from matplotlib.ticker import FuncFormatter
import matplotlib.colors as mcolors
import matplotlib._color_data as mcd
# %matplotlib inline
# import seaborn as sns
import plotly
from plotly import tools
# import plotly.plotly as py
import chart_studio.plotly as py
import plotly.graph_objs as go
import plotly.figure_factory as ff
from plotly.offline import download_plotlyjs,init_notebook_mode,plot,iplot
#connects JS to notebook so plots work inline
init_notebook_mode(connected=True)
import bokeh
from bokeh.io import push_notebook, show, output_notebook
import bokeh.plotting as bp
from bokeh.plotting import figure, save, output_file, show
from bokeh.models import ColumnDataSource, LabelSet, HoverTool, Label
output_notebook()
# import IPython
from IPython.display import display

# NLP-related
from nltk.corpus import stopwords
stop_words = stopwords.words('english')
stop_words.extend(['from', 'subject', 're', 'edu', 'use', 'not', 'would', 'say', 'could', '_', 'be', 'know', 'good', 'go', 'get', 'do', 'done', 'try', 'many', 'some', 'nice', 'thank', 'think', 'see', 'rather', 'easy', 'easily', 'lot', 'lack', 'make', 'want', 'seem', 'run', 'need', 'even', 'right', 'line', 'even', 'also', 'may', 'take', 'come'])
from textblob import TextBlob
# import pathlib, inflect
import spacy
from spacy.tokenizer import Tokenizer
from spacy import displacy
nlp = spacy.load('en_core_web_lg')
# !{sys.executable} -m spacy download en
import gensim
import gensim.corpora as corpora
from gensim import corpora, models, similarities
from gensim.corpora import Dictionary
from gensim.models import Doc2Vec, CoherenceModel, LdaModel, HdpModel, LsiModel
# from gensim.models.wrappers import LdaMallet #,LdaVowpalWabbit
from gensim.utils import simple_preprocess # lemmatize,
from gensim.matutils import hellinger
import lda
# import pyLDAvis.gensim
import pyLDAvis
import pyLDAvis.gensim_models as gensimvis
pyLDAvis.enable_notebook()
# # feed the LDA model into the pyLDAvis instance
# lda_viz = gensimvis.prepare(ldamodel, corpus, dictionary)
import sklearn
from sklearn import metrics
from sklearn.feature_extraction.text import TfidfVectorizer, CountVectorizer, TfidfTransformer
from sklearn.preprocessing import normalize
from sklearn.preprocessing import MinMaxScaler
from sklearn.decomposition import PCA, NMF, TruncatedSVD #,LatentDirichletAllocation
from sklearn.manifold import TSNE

### Functions

#dataframe styling
def color_green(val):
    color = 'green' if isinstance(val, float) else 'black'
    return 'color: {col}'.format(col=color)

def make_bold(val):
    weight = 700 if isinstance(val, float) else 400
    return 'font-weight: {wt}'.format(wt=weight)

remc=["navy","white","snow","whitesmoke","seashell","honeydrew","ivory","lightyellow","beige",'lavender',
      "floralwhite","mintcream","azure","alicblue","lavenderblush","ghostwhite","lightblue","lightgreen","chartreuse"]
tableau_cl=[c[4:] for c in mcolors.TABLEAU_COLORS] #10 colors
xkcd_cl=[c for c in list({name for name in mcd.CSS4_COLORS
         if "xkcd:" + name in mcd.XKCD_COLORS}) if c not in remc] #45 colors
css4_cl=[c for c in mcolors.CSS4_COLORS if c not in remc] # 136 colors

#20 colors
colormap = np.array([
    "#1f77b4", "#aec7e8", "#ff7f0e", "#ffbb78", "#2ca02c",
    "#98df8a", "#d62728", "#ff9896", "#9467bd", "#c5b0d5",
    "#8c564b", "#c49c94", "#e377c2", "#f7b6d2", "#7f7f7f",
    "#c7c7c7", "#bcbd22", "#dbdb8d", "#17becf", "#9edae5"
])

def pretty_print(input_text):
    
    pieces = [str(word) for word in input_text]
    output = ' '.join(pieces)
    #write_up = fill(output)
    print('Hellinger Distances between topics are: \n')
    print('_'*70)
    print('\n')
    print(output.translate({ord(')'):')\n'}))
    print('_'*70)
    #print(write_up)
    
    return None

# Define functions for stopwords, bigrams, trigrams and lemmatization
def remove_stopwords(texts):
    return [[word for word in simple_preprocess(str(doc)) if word not in stop_words] for doc in texts]

# def make_bigrams(texts):
# 	bigram_mod=[]
# 	for doc in texts:
# 		bigram = gensim.models.Phrases(doc, min_count=5, threshold=100)
# 		bigram_mod = gensim.models.phrases.Phraser(bigram)
# 	return bigram_mod #[bigram_mod[doc] for doc in texts]

# def make_trigrams(texts):
# 	trigram_mod=[]
# 	for doc in texts:
# 		trigram = gensim.models.Phrases(doc, threshold=100)
# 		trigram_mod = gensim.models.phrases.Phraser(trigram)
# 	return trigram_mod #[trigram_mod[bigram_mod[doc]] for doc in texts]

def lemmatization(texts, allowed_postags=['NOUN']): #, 'ADJ', 'VERB', 'ADV'
    """https://spacy.io/api/annotation"""
    texts_out = []
    for sent in texts:
        doc = nlp(" ".join(sent)) 
        texts_out.append([token.lemma_ for token in doc if token.pos_ in allowed_postags])
    return texts_out

def compute_coherence_values(model_type, dictionary, texts, max_topics, 
                                 corpus=False, topics=False, transformed_vectorizer=False, tfidf_norm=False,
                                 min_topics=2, stride=3, n_top_words=False, measure='u_mass',
                                 lsi_flag=False, nmf_flag=False, mallet_flag=False, mallet_path=False):

    coherence_values = []
    model_list = []
    if nmf_flag:
        feat_names = transformed_vectorizer.get_feature_names()
    
    for num_topics in range(min_topics, max_topics, stride):
        if lsi_flag:
            model=model_type(corpus=corpus, id2word=dictionary, num_topics=num_topics)
        elif nmf_flag:
            model=model_type(n_components=num_topics, init='nndsvd', random_state=111)
        elif mallet_flag:
            model=model_type(mallet_path=mallet_path, corpus=corpus, id2word=dictionary, num_topics=num_topics) 
        else:
            model=model_type(corpus=corpus, id2word=dictionary, num_topics=num_topics, random_state=121)   
            
        model_list.append(model)
        
        if nmf_flag:
            words_list = []
            
            for i in range(num_topics):
                model.fit(tfidf_norm)
                
                #for each topic, obtain the largest values, and add the words they map to into the dictionary
                words_ids = model.components_[i].argsort()[:-n_top_words - 1:-1]
                words = [feat_names[key] for key in words_ids]
                words_list.append(words)
                
            coherencemodel = CoherenceModel(topics=words_list, texts=texts, dictionary=dictionary, coherence=measure)
            
        else:
            coherencemodel = CoherenceModel(model=model, texts=texts, dictionary=dictionary, coherence=measure)
        
        coherence_values.append(coherencemodel.get_coherence())
        print('Coherence of model with {} topics has been computed'.format(num_topics))
        
    print('All coherence values have been computed for the {} using the {} measure'.format(model_type, measure.upper()))
    print('\n')

    return model_list, coherence_values

def show_best_num_topics(model_type, umass_coherence_vals, cv_coherence_vals, max_topics, min_topics=2, stride=3):
    
    min_topics=min_topics
    max_topics=max_topics
    stride=stride
    
    x = range(min_topics, max_topics, stride)
    
    max_y1 = max(umass_coherence_vals)
    max_x1 = x[umass_coherence_vals.index(max_y1)]
    
    max_y2 = max(cv_coherence_vals)
    max_x2 = x[cv_coherence_vals.index(max_y2)] 
    
    fig = plt.figure(constrained_layout=True, figsize=(14,5))

    gs = GridSpec(1, 2, figure=fig)
    ax1 = fig.add_subplot(gs[0, 0])
    ax2 = fig.add_subplot(gs[0, -1])

    ax1.plot(x, umass_coherence_vals, label='Coherence Values')
    ax1.set_xlabel('Num Topics')
    ax1.set_ylabel('Coherence score (U_MASS)')
    ax1.legend(loc='best')
    ax1.text(max_x1, max_y1, str((max_x1, max_y1)))

    ax2.plot(x, cv_coherence_vals, label='Coherence Values')
    ax2.set_xlabel('Num Topics')
    ax2.set_ylabel('Coherence score (C_V)')
    ax2.legend(loc='best')
    ax2.text(max_x2, max_y2, str((max_x2, max_y2)))

    fig.suptitle('Coherence Scores ({})'.format(model_type))

    plt.show()

    print('The most coherent number of {} topics using the U_MASS measure is: {}'.format(model_type, max_x1))
    print('The most coherent number of {} topics using the C_V measure is: {}'.format(model_type, max_x2))
    print('\n')
    
    tup_list = [(max_x1, max_y1), (max_x2, max_y2)]
    best_num_topics = max(tup_list, key=itemgetter(1))[0]
    
    return best_num_topics

def get_topics(model, num_topics,num_words):
    
    word_dict = {}
    for i in range(num_topics):
        words = model.show_topic(i, topn = num_words)
        word_dict['Topic # ' + '{:02d}'.format(i+1)] = [i[0]+" "+str(i[1]) for i in words]
        
    return pd.DataFrame(word_dict)

def topics_2_bow(topic, model, lsi_flag=False, mallet_flag=False):

    topic = topic.split('+')
    topic_bow = []
    
    lsi_mallet_array = np.array([])
    lsi_mallet_dict = {}
    lsi_mallet_dict_scaled = {}
    
    for word in topic:
        #split probability and word
        try:
            prob, word = word.split('*')
        except:
            continue

        #replace unwanted characters
        rep = {' ': '', '"': ''}
        replace = dict((re.escape(k), v) for k, v in rep.items())
        pattern = re.compile("|".join(replace.keys()))
        word = pattern.sub(lambda m: replace[re.escape(m.group(0))], word)

        #convert to word_type
        try:
            word = model.id2word.doc2bow([word])[0][0]
        except:
            continue
            
        if lsi_flag or mallet_flag:
            lsi_mallet_array = np.append(lsi_mallet_array, float(prob))
            lsi_mallet_dict.update({word:prob})
              
        else:
            topic_bow.append((word, float(prob)))
                        
    if lsi_flag or mallet_flag:
        scaler = MinMaxScaler(feature_range=(0,1), copy=True)
        lsi_mallet_scaled = scaler.fit_transform(lsi_mallet_array.reshape(-1,1))
        
        lsi_mallet_scaled = (lsi_mallet_scaled - lsi_mallet_scaled.min()) / (lsi_mallet_scaled - lsi_mallet_scaled.min()).sum()
        
        for k,v in zip(lsi_mallet_dict.keys(), lsi_mallet_scaled):
            lsi_mallet_dict_scaled.update({k:v[0]})        

        for k,v in lsi_mallet_dict_scaled.items():
            topic_bow.append((k,v))
        
    return topic_bow

def get_most_similar_topics(model, topics_df=False, num_topics=False, mallet_flag=False, hdp_flag=False, lsi_flag=False, nmf_flag=False, columns=False):
    
    if not nmf_flag:
    
        mod_topics = tuple(topics_df.columns)
        mod_top_dict = {}

        if hdp_flag:
            for k,v in zip(mod_topics, model.show_topics(num_words=len(model.id2word))):
                mod_top_dict.update({k:v})
        else:    
            for k,v in zip(mod_topics, model.show_topics(num_words=len(model.id2word), num_topics=num_topics)):
                mod_top_dict.update({k:v})

        for k,v in mod_top_dict.items():
            mod_top_dict[k] = topics_2_bow(v[1], model, lsi_flag, mallet_flag)
    
    else:
        mod_topics = tuple(columns)
        mod_top_dict = {}
        
        nmf_top_list = []
        for k,v in zip(mod_topics, model.components_):
            nmf_top_list.append(tuple((k, v)))
        
        scaler = MinMaxScaler(feature_range=(0,1), copy=True)
        
        for k,v in nmf_top_list:
            v_scaled = scaler.fit_transform(v.reshape(-1,1))
            v = (v_scaled - v_scaled.min()) / (v_scaled - v_scaled.min()).sum()
            mod_top_dict.update({k:v})

    hellinger_dists = [(hellinger(mod_top_dict[x], mod_top_dict[y]), x, y)
                          for i,x in enumerate(mod_top_dict.keys())
                          for j,y in enumerate(mod_top_dict.keys())
                          if i != j]       

    unique_hellinger = [tuple(x) for x in set(map(frozenset, hellinger_dists)) if len(tuple(x)) == 3]
    
    resorted_hellinger = []
    for i in range(len(unique_hellinger)):
        resorted_hellinger.append(sorted(tuple(str(e) for e in unique_hellinger[i])))
        resorted_hellinger[i][0] = float(resorted_hellinger[i][0])
        resorted_hellinger[i] = tuple(resorted_hellinger[i])

    resorted_hellinger = sorted(resorted_hellinger, reverse=True)

    return resorted_hellinger

def get_dominant_topics(klist,model, corpus, texts, lsi_flag=False):

    dom_topics_df = pd.DataFrame()

    #for all topic/topic-probability pairings
    for i, row in enumerate(model[corpus]):
        #return the pairings, sorting first the one with the highest topic-probability in the mixture
        if lsi_flag:
            row = sorted(row, key=lambda x: abs(x[1]), reverse=True)
        else:
            row = sorted(row, key=lambda x: (x[1]), reverse=True)     
        #for every topic/topic-probability pairing in the sorted tuple list
        for j, (topic_num, topic_prob) in enumerate(row):
            #take the pairing with the highest topic-probability
            if j == 0:
                #return the tuple list of top 'n' word-probabilities associated with that topic
                wp = model.show_topic(topic_num, topn=20)
                #create a list of those top 'n' words
                topic_keywords = ", ".join([word for word, prob in wp])
                #append to the empty dataframe a series containing:
                #    the dominant topic allocation for that document,
                #    the topic-probability it contributes to that document,
                #    and the top 'n' words associated with that topic
                # print(type(dom_topics_df), pd.Series([int(topic_num), round(topic_prob,4), topic_keywords]) )
                # return
                #dom_topics_df = dom_topics_df.append(pd.Series([int(topic_num), round(topic_prob,4), topic_keywords]), ignore_index=True)
                # newline = pd.Series([int(topic_num), round(topic_prob,4), topic_keywords])
                #newline = pd.DataFrame(newline)
                #dom_topics_df = pd.concat([dom_topics_df, pd.Series([int(topic_num), round(topic_prob,4), topic_keywords])])
                ddf = pd.DataFrame([int(topic_num), round(topic_prob,4), topic_keywords]).transpose()
                dom_topics_df = pd.concat([dom_topics_df, ddf], ignore_index=True )
            else:
                #ignore other topics in the mixture
                break
                
    #name the columns of the constructed dataframe
    dom_topics_df.columns = ['Dominant_Topic', 'Probability_Contribution', 'Topic_Keywords']
    dom_topics_df["Publication"]=klist
    
    #append to the original text as another column in the dataframe
    contents = pd.Series(texts)
    dom_topics_df = pd.concat([dom_topics_df, contents], axis=1)
    
    dom_topics_final = dom_topics_df.reset_index()
    dom_topics_final.columns = ['Document_Number', 'Dominant_Topic', 'Probability_Contribution', 'Topic_Keywords', 'Original_Text',"Publication"]
    dom_topics_final.set_index('Document_Number', inplace=True)
    
    return dom_topics_df, dom_topics_final

def get_most_representative_docs(dom_topics_final_df, n_topics=20, lsi_flag=False):
    
    representative_docs = pd.DataFrame()
    
    dom_topics_grpd = dom_topics_final_df.groupby('Dominant_Topic')

    #for every dominant topic, find the document to which it contributed the greatest (or largest magnitude [LSI]) probability contribution
    if not lsi_flag:    
        for i, grp in dom_topics_grpd:
            representative_docs = pd.concat([representative_docs, 
                                                grp.sort_values(['Probability_Contribution'], ascending=True).head(1)], 
                                                axis=0)
    else:
        for i, grp in dom_topics_grpd:
            representative_docs = pd.concat([representative_docs,
                                                #sort by descending absolute value
                                                grp.reindex(grp.Probability_Contribution.abs().sort_values(inplace=False, ascending=False).index).head(1)],
                                                axis=0)

    representative_docs.reset_index(drop=True, inplace=True)

    representative_docs.columns = ['Topic_Number', 'Probability_Contribution', 'Topic_Keywords', 'Most_Representative_Document',"Publication"]
    representative_docs['Topic_Number'] = representative_docs['Topic_Number'].astype(int)

    representative_docs.set_index('Topic_Number', inplace=True)

    rep_docs_first_n = representative_docs.head(n_topics)
    
    return rep_docs_first_n

def get_topic_distribution(dom_topics_final_df, rep_doc_df=False, n_topics=20, hdp_flag=False):
    
    if hdp_flag:
        
        rep_doc_df = get_most_representative_docs(dom_topics_final_df, n_topics=dom_topics_final_df['Dominant_Topic'].nunique())
    
    rep_doc_df.reset_index(inplace=True)
    
    #topic number and keywords
    topic_num_keywords = rep_doc_df[['Topic_Number', 'Topic_Keywords']]
    
    #number of documents allocated to each topic
    topic_counts = dom_topics_final_df['Dominant_Topic'].value_counts()
    
    #topic allocation percentage of total corpus
    topic_percent = round(topic_counts/topic_counts.sum(), 4)
    
    #concat number of allocated docs and percentage
    topic_dist = pd.concat([topic_num_keywords, topic_counts, topic_percent], axis=1)
    
    topic_dist.columns = ['Topic_Number', 'Topic_Keywords', 'Documents_per_Topic', 'Percent_of_Total_Corpus']
    topic_dist.dropna(axis=0, how='any', inplace=True)
    
    topic_dist['Topic_Number'] = topic_dist['Topic_Number'].astype(int)
    topic_dist.set_index('Topic_Number', inplace=True)
    
    topic_dist = topic_dist[['Documents_per_Topic', 'Percent_of_Total_Corpus', 'Topic_Keywords']]

    topic_dist_first_n = topic_dist.head(n_topics)
    
    return topic_dist_first_n

def plot_tsne(title, doc_list, fitted_lda, fitted_count_vectorizer, transformed_lda, transformed_tsne, color_map, n_top_words=10):
    
    n_top_words = n_top_words
    color_map = color_map
    
    #retrieve component key words
    _lda_keys = []
    for i in range(transformed_lda.shape[0]):
        _lda_keys +=  transformed_lda[i].argmax(),
        
    topic_summaries = []
    #matrix of shape n_topics x len(vocabulary)
    topic_words = fitted_lda.topic_word_
    #all vocab words (strings)
#     vocab = fitted_count_vectorizer.get_feature_names()
    vocab = fitted_count_vectorizer.get_feature_names_out()
    for i, topic_dist in enumerate(topic_words):
        #np.argsort returns indices that would sort an array
        #iterates over topic component vectors, sorts array in asc order, appends key words from end of array
        topic_word = np.array(vocab)[np.argsort(topic_dist)][:-(n_top_words + 1):-1]
        topic_summaries.append(' '.join(topic_word))
    
    num_example = len(transformed_lda)

    plot_dict = {
            'x': transformed_tsne[:, 0],
            'y': transformed_tsne[:, 1],
            'colors': color_map[_lda_keys][:num_example],
            'content': doc_list[:num_example],
            'topic_key': _lda_keys[:num_example]
            }

    #create dataframe from dictionary
    plot_df = pd.DataFrame.from_dict(plot_dict)

    source = bp.ColumnDataSource(data=plot_df)
#     title = 'LDA T-SNE Visualization'
#     title="t-SNE plot of LDA Topic Modeling of articles on Social Justice & Computing"

    plot_lda = bp.figure(width=800, height=800,  #1400, 1100
                         title=title,
                         tools="pan,wheel_zoom,box_zoom,reset,hover,save", #previewsave
                         x_axis_type=None, y_axis_type=None, min_border=1)

    plot_lda.scatter('x','y', color='colors', source=source)

    topic_coord = np.empty((transformed_lda.shape[1], 2)) * np.nan
    for topic_num in _lda_keys:
        if not np.isnan(topic_coord).any():
            break
        topic_coord[topic_num] = transformed_tsne[_lda_keys.index(topic_num)]

    #plot key words
    for i in range(transformed_lda.shape[1]):
        plot_lda.text(topic_coord[i, 0], topic_coord[i, 1], []) #topic_summaries[i]

    #hover tools
    hover = plot_lda.select(dict(type=HoverTool))
    hover.tooltips = {"content": "@content - topic: @topic_key"}

    # save the plot
    #save(plot_lda, '{}.html'.format(title))

    #Cf. JSON Serialization issue: 
    #    https://github.com/bokeh/bokeh/issues/5439
    #    https://github.com/bokeh/bokeh/issues/6222
    #   https://github.com/bokeh/bokeh/issues/7523
    try:
        show(plot_lda, notebook_handle=True)
    except Exception as e:
        print('Note!: {}'.format(e.__doc__))
        print(e)

    return None

def df_tsne(title, doc_list, fitted_lda, fitted_count_vectorizer, transformed_lda, transformed_tsne, color_map, n_top_words=10):
    
    n_top_words = n_top_words
    color_map = color_map
    
    #retrieve component key words
    _lda_keys = []
    for i in range(transformed_lda.shape[0]):
        _lda_keys +=  transformed_lda[i].argmax(),
        
    topic_summaries = []
    #matrix of shape n_topics x len(vocabulary)
    topic_words = fitted_lda.topic_word_
    #all vocab words (strings)
#     vocab = fitted_count_vectorizer.get_feature_names()
    vocab = fitted_count_vectorizer.get_feature_names_out()
    for i, topic_dist in enumerate(topic_words):
        #np.argsort returns indices that would sort an array
        #iterates over topic component vectors, sorts array in asc order, appends key words from end of array
        topic_word = np.array(vocab)[np.argsort(topic_dist)][:-(n_top_words + 1):-1]
        topic_summaries.append(' '.join(topic_word))
    
    num_example = len(transformed_lda)

    plot_dict = {
            'x': transformed_tsne[:, 0],
            'y': transformed_tsne[:, 1],
            'colors': color_map[_lda_keys][:num_example],
            'content': doc_list[:num_example],
            'topic_key': _lda_keys[:num_example]
            }
       
    #create dataframe from dictionary
    plot_df = pd.DataFrame.from_dict(plot_dict) 
    
    return plot_df

### NLP Models

# Initialize spacy 'en' model, keeping only tagger component (for efficiency)
# python3 -m spacy download en
# nlp = spacy.load('en')
nlp = spacy.load('en_core_web_lg', disable=['parser', 'ner'])

#cont = Contractions('../GoogleNews-vectors-negative300.bin.gz')
#cont.load_models()

punctuations = string.punctuation

LabeledSentence1 = gensim.models.doc2vec.TaggedDocument

def sent_to_words(sentences):
    for sentence in sentences:
        yield(gensim.utils.simple_preprocess(str(sentence), deacc=True))  # deacc=True removes punctuations
        
from nltk.corpus import stopwords

stop_words = stopwords.words('english')
# rem=["article","paper","make", "theory","social","think","problem","school","course","become",
#     "student","different","variable","other","difficult","main","study","teacher","scale",
#      "child","concept","analysis","introduction","preface","foreword","conclusion",
#     "overview","epilogue",
#      "base","behalf","comprises","curricula","curriculum","definition",
# "do","doc","editorial","essay","faculty","grade","hand","home",
# "list","million","month","part","question","reader","site","text",
# "time","title","way","year",
#      "factor","teacher","student","practice" #"value","system","group"
#     ]
stop_words.extend(['from', 'subject', 're', 'edu', 'use', 'not', 'would', 'say', 'could', '_', 'be', 'know', 'good', 'go', 'get', 'do', 'done', 'try', 'many', 'some', 'nice', 'thank', 'think', 'see', 'rather', 'easy', 'easily', 'lot', 'lack', 'make', 'want', 'seem', 'run', 'need', 'even', 'right', 'line', 'even', 'also', 'may', 'take', 'come'])
# stop_words.extend(rem)

tokenizer = Tokenizer(nlp.vocab)

stopwords = stop_words #spacy.lang.en.STOP_WORDS

#spacy.lang.en.STOP_WORDS.add("e.g.")
#nlp.vocab['the'].is_stop
# nlp.Defaults.stop_words |= {"(a)", "(b)", "(c)", "etc", "etc.", "etc.)", "w/e", "(e.g.", "no?", "s", 
#                            "film", "movie","0","1","2","3","4","5","6","7","8","9","10","e","f","k","n","q",
#                             "de","oh","ones","miike","http","imdb", "horror", "like", "good", "great", "little", 
#                             "come", "way", "know", "michael", "lot", "thing", "films", "later", "actually", "find", 
#                             "big", "long", "away", "filmthe", "www", "com", "x", "aja", "agritos", "lon", "therebravo", 
#                             "gou", "b", "particularly", "probably", "sure", "greenskeeper", "try", 
#                             "half", "intothe", "especially", "exactly", "20", "ukr", "thatll", "darn", "certainly", "simply", }
# stopwords = list(nlp.Defaults.stop_words)


