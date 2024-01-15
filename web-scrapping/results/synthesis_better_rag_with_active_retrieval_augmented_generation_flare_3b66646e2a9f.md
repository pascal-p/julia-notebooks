### Article Analysis: "Better RAG with Active Retrieval Augmented Generation FLARE"
#### Article Details
- **Title**: Better RAG with Active Retrieval Augmented Generation FLARE
- **Author**: Akash A Desai
- **Publication Date**: November 18, 2023
- **Publication**: LanceDB
- **Reading Time**: 7 minutes
- **Article Link**: [Better RAG with FLARE](https://blog.lancedb.com/better-rag-with-active-retrieval-augmented-generation-flare-3b66646e2a9f)
#### Main Content Summary
The article introduces the Forward-Looking Active Retrieval Augmented Generation (FLARE), a novel methodology designed to enhance the accuracy and reliability of large language models (LLMs). FLARE addresses the issue of hallucination in LLMs, which is the generation of incorrect or baseless content, particularly in complex, long-form content generation tasks.
FLARE differentiates itself from traditional retrieval-augmented generation models by performing multiple retrievals at various intervals during the content generation process. It actively incorporates external information, determining both when to retrieve (when the LLM lacks required knowledge or generates low-probability tokens) and what to retrieve (considering what the LLM intends to generate in the future).
The article describes two types of FLARE's iterative generation process:
1. **FLARE Instruct**: It iteratively generates a temporary next sentence, uses it as a query to retrieve relevant documents if they contain low-probability tokens, and regenerates the next sentence until the end of the overall generation.
2. **FLARE Direct**: This method uses the generated content as a direct query for retrieval when it encounters tokens with low confidence. It employs two approaches to rectify or verify low-confidence information.
The author emphasizes the importance of using an LLM that returns log probabilities (logprobs) to identify uncertain tokens, recommending the use of the OpenAI wrapper (excluding the ChatOpenAI wrapper, which does not return logprobs).
#### Code Snippet
The article provides a Python code snippet using the `gradio` library to demonstrate a local system implementation of FLARE with `lancedb` and `bge` embedding. The code includes the setup of the OpenAI LLM, the use of `ArxivLoader` to fetch documents from arXiv, and the creation of a `FlareChain` instance. A Gradio interface is then launched to generate FLARE output based on user input.
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
#### External Links and References
The article includes several external links, such as:
- [LanceDB Blog](https://blog.lancedb.com/better-rag-with-active-retrieval-augmented-generation-flare-3b66646e2a9f)
- [ArXiv FLARE Paper](https://arxiv.org/pdf/2305.06983.pdf)
- [LanceDB GitHub Repository](https://github.com/lancedb/lancedb)
- [VectorDB Recipes GitHub Repository](https://github.com/lancedb/vectordb-recipes)
#### Conclusion
FLARE represents a significant advancement in the field of LLMs by actively integrating external information to reduce hallucination in content generation. The article showcases FLARE's capabilities through the FLARE Instruct and FLARE Direct processes and provides a practical example of its implementation. The author encourages readers to explore the LanceDB repository and the vector-recipes repository for further insights and applications of this technology. The article concludes with an invitation to stay tuned for upcoming blogs on LLMs and an appreciation for reader support.