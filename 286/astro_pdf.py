
# coding: utf-8

# In[1]:

import pandas as pd


# In[2]:

df = pd.read_csv('astro_with_weights.csv')


# In[3]:

import urllib.request, urllib.parse, urllib.error
import feedparser
import time
import pandas as pd
import numpy as np


# In[4]:

def remove_special_chars(title):
    chars = ['[',']','\'','\\','"',':',';','@','&','*','$','#','!','%','(',')','=','+','-','|','~','`','/','<','>','.',',','{','}']

    for char in chars:
        title = title.replace(char,'')
    title = title.replace(' ','%20')
    return title


# In[5]:

def remove(yay):
    return yay.replace(', ','_')


# In[6]:

titles = df['title'].apply(remove_special_chars).as_matrix()


# In[7]:

authors = df['first_author'].apply(remove).as_matrix()


# In[8]:

abstracts = df['abstract'].apply(remove_special_chars)


# In[ ]:

datas = []
for i,(title,author) in enumerate(zip(titles,authors)):
    if i % 100 == 0:
        print(i)
    # Base api query url
    base_url = 'http://export.arxiv.org/api/query?';

    # Search parameters
    search_query = 'title:'+title+'+AND+au:'+author # search for electron in all fields
#     search_query = 'title:'+title
    start = 0                     # retreive the first 5 results
    max_results = 1

    query = 'search_query=%s' % (search_query)

    # Opensearch metadata such as totalResults, startIndex,
    # and itemsPerPage live in the opensearch namespase.
    # Some entry metadata lives in the arXiv namespace.
    # This is a hack to expose both of these namespaces in
    # feedparser v4.1
    feedparser._FeedParserMixin.namespaces['http://a9.com/-/spec/opensearch/1.1/'] = 'opensearch'
    feedparser._FeedParserMixin.namespaces['http://arxiv.org/schemas/atom'] = 'arxiv'
    try:
        # perform a GET request using the base_url and query
        response = urllib.request.urlopen(base_url+query).read()
    except:
        continue
        
    # parse the response using feedparser
    feed = feedparser.parse(response)

    print('totalResults for this query: %s' % feed.feed.opensearch_totalresults)
    if int(feed.feed.opensearch_totalresults) > 0:
        entry = feed.entries[0]
        if entry.title[:5] == title.replace('%20',' ')[:5]:
            for link in entry.links:
                if 'title' in link:
                    href = link.href + '.pdf'
            data = [
                i,
                entry.id.split('/abs/')[-1], # arxiv-id
                entry.title,                 # title
                entry.published,             # published
                ', '.join(author.name for author in entry.authors), # authors
                href,                        # href
            #     entry.summary                # summary
            ]
            datas.append(data)
            print(title[:20],entry.title[:20])


# In[139]:

import csv

with open('astro_arxiv.csv', 'wb') as myfile:
    wr = csv.writer(myfile, quoting=csv.QUOTE_ALL)
    wr.writerow(datas)


# In[9]:

df = pd.read_csv('astro_arxiv.csv')


# In[15]:

links = df['5'].dropna()


# In[77]:

import requests
def download_file(i,download_url):
    response = requests.get(download_url)
    print(print(i,download_url.split('/')[-1]))

    with open('pdf/'+download_url.split('/')[-1], 'wb') as f:
        f.write(response.content)


# In[ ]:




# In[79]:

for i, link in links.loc[:2463].iteritems():
    download_file(i,link)


# In[17]:


from pdfminer.pdfinterp import PDFResourceManager, PDFPageInterpreter#process_pdf
from pdfminer.pdfpage import PDFPage
from pdfminer.converter import TextConverter
from pdfminer.layout import LAParams
import io
def pdfparser(data):

    fp = open(data, 'rb')
    print(fp)
    rsrcmgr = PDFResourceManager()
    retstr = io.StringIO()
    codec = 'utf-8'
    laparams = LAParams()
    device = TextConverter(rsrcmgr, retstr, codec=codec, laparams=laparams)
    # Create a PDF interpreter object.
    interpreter = PDFPageInterpreter(rsrcmgr, device)
    # Process each page contained in the document.
    try:
        for page in PDFPage.get_pages(fp):
            interpreter.process_page(page)
            data =  retstr.getvalue()
        
    except:
        data = None
        print('failure')
    return data


# In[18]:

l = []
for i, link in links.loc[:2463].iteritems():
    data = pdfparser('pdf/'+link.split('/')[-1])
    l.append([i,data])
    print(i)


# In[ ]:

1


# In[19]:

l


# In[ ]:



