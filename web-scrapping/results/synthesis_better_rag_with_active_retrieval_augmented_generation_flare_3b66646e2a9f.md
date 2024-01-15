### Article Analysis: "Better RAG with Active Retrieval Augmented Generation FLARE"
#### Article Details
- **Title**: Better RAG with Active Retrieval Augmented Generation FLARE
- **Author**: Akash A Desai
- **Publication Date**: November 18, 2023
- **Publication**: LanceDB
- **Reading Time**: 7 min read
- **Article Link**: [Better RAG with FLARE](https://blog.lancedb.com/better-rag-with-active-retrieval-augmented-generation-flare-3b66646e2a9f)
#### Introduction
The article introduces an innovative approach called Forward-Looking Active Retrieval Augmented Generation (FLARE), which aims to enhance the accuracy and reliability of large language models (LLMs). The focus is on addressing the issue of hallucination in LLMs, particularly in complex, long-form content generation tasks. Hallucination refers to the generation of incorrect or baseless content, a problem that becomes more pronounced in tasks requiring extensive outputs.
#### Traditional Retrieval-Augmented Generation
Traditional retrieval-augmented generation models typically perform a single retrieval at the beginning of the generation process. This method has limitations, especially when dealing with long and complex texts.
#### FLARE's Methodology
FLARE improves upon traditional models by using multiple retrievals at different intervals. It determines both when to retrieve (when the LLM lacks required knowledge or generates low-probability tokens) and what to retrieve (considering what the LLM intends to generate in the future).
#### Understanding FLARE's Iterative Generation Process
FLARE operates iteratively, generating a temporary next sentence and using it as a query to retrieve relevant documents if they contain low-probability tokens. This process continues until the end of the overall generation. The article describes two types of FLARE's processes: FLARE Instruct and FLARE Direct.
#### FLARE Direct
FLARE Direct uses the generated content as a direct query for retrieval when encountering tokens with low confidence. The article provides an example involving the generation of a summary about Joe Biden. It explains how FLARE Direct addresses low-confidence information using two approaches, though these approaches are not specified in the provided excerpt.
#### Implementation Essentials
The article recommends using the OpenAI wrapper (excluding the ChatOpenAI wrapper) for the LLM that generates the answer, as it needs to return log probabilities to identify uncertain tokens. For generating hypothetical questions to use in retrieval, ChatOpenAI is suggested due to its speed and cost-effectiveness.
#### Practical Application Example
The article includes a practical application example using Gradio code, which can be run on a local system. It utilizes the `ArxivLoader` to ask questions directly to a paper, specifically the FLARE paper with the query number "2305.06983".
#### Gradio Code Example
The provided Gradio code example is written in Python and demonstrates how to implement FLARE with LanceDB and BGE embeddings. The code is as follows:
```python
from langchain import PromptTemplate, LLMChain
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.chains import RetrievalQA
from langchain.embeddings import HuggingFaceBgeEmbeddings
from langchain.document_loaders import PyPDFLoader
from langchain.vectorstores import LanceDB
from langchain.document_loaders import ArxivLoader
from langchain.chains import FlareChain
from langchain.prompts import PromptTemplate
from langchain.chains import LLMChain
import os
import gradio as gr
import lancedb
from io import BytesIO
from langchain.llms import OpenAI
import getpass
# pass your api key
os.environ["OPENAI_API_KEY"] = "sk-yourapikeyforopenai"
llm = OpenAI()
os.environ["OPENAI_API_KEY"] = "sk-yourapikeyforopenai"
llm = OpenAI()
model_name = "BAAI/bge-large-en"
model_kwargs = {'device': 'cpu'}
encode_kwargs = {'normalize_embeddings': False}
embeddings = HuggingFaceBgeEmbeddings(
model_name=model_name,
model_kwargs=model_kwargs,
encode_kwargs=encode_kwargs
)
# here is example https://arxiv.org/pdf/2305.06983.pdf
# you need to pass this number to query 2305.06983
# fetch docs from arxiv, in this case it's the FLARE paper
docs = ArxivLoader(query="2305.06983", load_max_docs=2).load()
# instantiate text splitter
text_splitter = RecursiveCharacterTextSplitter(chunk_size=1500, chunk_overlap=150)
# split the document into chunks
doc_chunks = text_splitter.split_documents(docs)
# lancedb vectordb
db = lancedb.connect('/tmp/lancedb')
table = db.create_table("documentsai", data=[
{"vector": embeddings.embed_query("Hello World"), "text": "Hello World", "id": "1"}
], mode="overwrite")
vector_store = LanceDB.from_documents(doc_chunks, embeddings, connection=table)
vector_store_retriever = vector_store.as_retriever()
flare = FlareChain.from_llm(
llm=llm,
retriever=vector_store_retriever,
max_generation_len=300,
min_prob=0.45
)
# Define a function to generate FLARE output based on user input
def generate_flare_output(input_text):
output = flare.run(input_text)
return output
input = gr.Text(
label="Prompt",
show_label=False,
max_lines=1,
placeholder="Enter your prompt",
container=False,
)
iface = gr.Interface(fn=generate_flare_output,
inputs=input,
outputs="text",
title="My AI bot",
description="FLARE implementation with lancedb & bge embedding.",
allow_screenshot=False,
allow_flagging=False
)
iface.launch(debug=True)
```
#### Conclusion
FLARE represents a significant advancement in the field of LLMs by actively integrating external information to reduce hallucination in content generation. The article highlights the dynamic nature of FLARE's multiple retrievals and its ability to adapt to evolving contexts. It also points to further resources, such as the LanceDB repository and the vector-recipes repository on GitHub, for those interested in exploring the full potential of this technology.
#### External Links and References
- [LanceDB Blog Post](https://blog.lancedb.com/better-rag-with-active-retrieval-augmented-generation-flare-3b66646e2a9f)
- [FLARE Paper on Arxiv](https://arxiv.org/pdf/2305.06983.pdf)
- [LanceDB GitHub Repository](https://github.com/lancedb/lancedb)
- [VectorDB Recipes GitHub Repository](https://github.com/lancedb/vectordb-recipes)
The article also contains numerous links to Medium's sign-in, registration, and other related pages, as well as the author's Medium profile. However, these links are not directly related to the content of the article and are part of the Medium platform's user interface.