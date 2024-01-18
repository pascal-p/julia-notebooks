### Article Overview
#### Title and Metadata
- **Title:** Advanced RAG Implementation on Custom Data Using Hybrid Search, Embed Caching And Mistral-AI
- **Author and Date:** Plaban Nayak, Published on Oct 8, 2023
- **Publication:** AI Planet
- **Reading Time:** 40 min read
#### Introduction
The article discusses the implementation of an advanced Retrieval Augmented Generation (RAG) pipeline on custom data. It incorporates concepts such as caching embeddings, hybrid vector search, and in-memory caching, with the goal of improving the quality and relevance of generated text for complex language tasks.
#### What is RAG?
RAG combines information retrieval and natural language generation (NLG) to enhance the generation process by incorporating relevant information from retrieval into the NLG model. This aims to improve the accuracy, coherence, and informativeness of the generated content.
#### Advanced RAG Concepts Implemented
- **Caching Embeddings:** Using `CacheBackedEmbeddings` to store embeddings in a key-value store to avoid recomputation.
- **Hybrid Vector Search:** Combining keyword search (using BM25 algorithm) and semantic search (using FAISS) to implement hybrid search with `EnsembleRetriever`.
- **InMemoryCaching:** Caching user queries and responses to reduce computation cost and inference time.
#### Implementation Stack
- **Embedder:** BAAI general embedding
- **Retrieval:** FAISS Vectorstore
- **Generation:** Mistral-7B-Instruct GPTQ model
- **Infrastructure:** Google Colab, A100 GPU
- **Data:** Financial Documents
#### Implementation Details
- **Install required Packages:**
  ```python
  !pip install -q git+https://github.com/huggingface/transformers
  !pip install -qU langchain Faiss-gpu tiktoken sentence-transformers
  !pip install -qU trl Py7zr auto-gptq optimum
  !pip install -q rank_bm25
  !pip install -q PyPdf
  ```
- **Import Necessary packages:**
  ```python
  import langchain
  from langchain.embeddings import CacheBackedEmbeddings,HuggingFaceEmbeddings
  from langchain.vectorstores import FAISS
  from langchain.storage import LocalFileStore
  from langchain.retrievers import BM25Retriever,EnsembleRetriever
  from langchain.document_loaders import PyPDFLoader,DirectoryLoader
  from langchain.llms import HuggingFacePipeline
  from langchain.cache import InMemoryCache
  from langchain.text_splitter import RecursiveCharacterTextSplitter
  from langchain.schema import prompt
  from langchain.chains import RetrievalQA
  from langchain.callbacks import StdOutCallbackHandler
  from langchain import PromptTemplate
  #
  from transformers import AutoModelForCausalLM, AutoTokenizer, pipeline
  ```
- **Data parsing and Loading using LangChain:**
  ```python
  dir_loader = DirectoryLoader("/content/Data",
  glob="*.pdf",
  loader_cls=PyPDFLoader)
  docs = dir_loader.load()
  #
  print(f"len of documents in :{len(docs)}")
  ```
  ```output
  len of documents in :85
  ```
- **Create Manageable pieces of text by using RecursiveCharacterTextSplitter:**
  ```python
  text_splitter = RecursiveCharacterTextSplitter(chunk_size=500,
  chunk_overlap=200,)
  #
  esops_documents = text_splitter.transform_documents(docs)
  print(f"number of chunks in barbie documents : {len(esops_documents)}")
  ```
  ```output
  number of chunks in barbie documents : 429
  ```
- **Create Vectorstore:**
  ```python
  store = LocalFileStore("./cache/")
  embed_model_id = 'BAAI/bge-small-en-v1.5'
  core_embeddings_model = HuggingFaceEmbeddings(model_name=embed_model_id)
  embedder = CacheBackedEmbeddings.from_bytes_store(core_embeddings_model,
  store,
  namespace=embed_model_id)
  # Create VectorStore
  vectorstore = FAISS.from_documents(esops_documents,embedder)
  ```
- **Create Sparse Embedding:**
  ```python
  bm25_retriever = BM25Retriever.from_documents(esops_documents)
  bm25_retriever.k=5
  ```
- **Setup Ensemble Retriever (Hybrid Search):**
  ```python
  faiss_retriever = vectorstore.as_retriever(search_kwargs={"k":5})
  ensemble_retriever = EnsembleRetriever(retrievers=[bm25_retriever,faiss_retriever],
  weights=[0.5,0.5])
  ```
- **Download the quantized GPTQ Model:**
  ```python
  from transformers import AutoModelForCausalLM, AutoTokenizer, pipeline
  model_name_or_path = "TheBloke/Mistral-7B-Instruct-v0.1-GPTQ"
  # To use a different branch, change revision
  # For example: revision="gptq-4bit-32g-actorder_True"
  model = AutoModelForCausalLM.from_pretrained(model_name_or_path,
  device_map="auto",
  trust_remote_code=False,
  revision="gptq-8bit-32g-actorder_True")
  #
  tokenizer = AutoTokenizer.from_pretrained(model_name_or_path, use_fast=True)
  ```
- **Create Pipeline:**
  ```python
  pipe = pipeline(
  "text-generation",
  model=model,
  tokenizer=tokenizer,
  max_new_tokens=512,
  do_sample=True,
  temperature=0.1,
  top_p=0.95,
  top_k=40,
  repetition_penalty=1.1
  )
  ```
- **Initialize LLM using a quantized GPTQ Model:**
  ```python
  from langchain.llms import HuggingFacePipeline
  llm = HuggingFacePipeline(pipeline=pipe)
  ```
- **Setup Caching:**
  ```python
  langchain.llm_cache = InMemoryCache()
  ```
- **Formulate the Prompt Template:**
  ```python
  PROMPT_TEMPLATE = '''
  You are my financial advisor. You are great at providing tips on investments, savings and on financial markets with your knowledge in finances.
  With the information being provided try to answer the question.
  If you cant answer the question based on the information either say you cant find an answer or unable to find an answer.
  So try to understand in depth about the context and answer only based on the information provided. Dont generate irrelevant answers
  Context: {context}
  Question: {question}
  Do provide only helpful answers
  Helpful answer:
  '''
  #
  input_variables = ['context', 'question']
  #
  custom_prompt = PromptTemplate(template=PROMPT_TEMPLATE,
  input_variables=input_variables)
  ```
- **Setup Retrieval chain — with Hybrid Search:**
  ```python
  handler = StdOutCallbackHandler()
  #
  qa_with_sources_chain = RetrievalQA.from_chain_type(
  llm=llm,
  chain_type="stuff",
  retriever = ensemble_retriever,
  callbacks=[handler],
  chain_type_kwargs={"prompt": custom_prompt},
  return_source_documents=True
  )
  ```
#### Conclusion
The article demonstrates that hybrid search using `EnsembleRetriever` provides better context to the Generative AI Model, resulting in more accurate responses. Caching the response and query significantly reduces inference time and computation cost. The use of caching for query embeddings helps to avoid unnecessary recomputation.
#### References
- [Caching Embeddings](https://python.langchain.com/docs/modules/data_connection/text_embedding/caching_embeddings)
- [LLM Caching](https://python.langchain.com/docs/integrations/llms/llm_caching)
- [Retrievers](https://python.langchain.com/docs/modules/data_connection/retrievers)
- [Ensemble Retrievers](https://python.langchain.com/docs/modules/data_connection/retrievers/ensemble)
#### Connect with the Author
- [Hugging Face](https://medium.com/tag/hugging-face?source=post_page-----ce78fdae4ef6---------------hugging_face-----------------)
- [Mistral Ai](https://medium.com/tag/mistral-ai?source=post_page-----ce78fdae4ef6---------------mistral_ai-----------------)
- [Langchain](https://medium.com/tag/langchain?source=post_page-----ce78fdae4ef6---------------langchain-----------------)
- [BM25](https://medium.com/tag/bm25?source=post_page-----ce78fdae4ef6---------------bm25-----------------)
- [Semantic Search](https://medium.com/tag/semantic-search?source=post_page-----ce78fdae4ef6---------------semantic_search-----------------)
#### Links:
  - [Open in app](https://rsci.app.link/?%24canonical_url=https%3A%2F%2Fmedium.com%2Fp%2Fce78fdae4ef6&%7Efeature=LoOpenInAppButton&%7Echannel=ShowPostUnderCollection&source=---two_column_layout_nav----------------------------------)
  - [medium.com](https://medium.com/?source=---two_column_layout_nav----------------------------------)
  - [medium.com](https://medium.com/search?source=---two_column_layout_nav----------------------------------)
  - [nayakpplaban.medium.com](https://nayakpplaban.medium.com/?source=post_page-----ce78fdae4ef6--------------------------------)
  - [medium.aiplanet.com](https://medium.aiplanet.com/?source=post_page-----ce78fdae4ef6--------------------------------)
  - [https://python.langchain.com/docs/modules/data_connection/text_embedding/caching_embeddings](https://python.langchain.com/docs/modules/data_connection/text_embedding/caching_embeddings)
  - [https://python.langchain.com/docs/integrations/llms/llm_caching](https://python.langchain.com/docs/integrations/llms/llm_caching)
  - [https://python.langchain.com/docs/modules/data_connection/retrievers](https://python.langchain.com/docs/modules/data_connection/retrievers/)
  - [https://python.langchain.com/docs/modules/data_connection/retrievers/ensemble](https://python.langchain.com/docs/modules/data_connection/retrievers/ensemble)
  - [Hugging Face](https://medium.com/tag/hugging-face?source=post_page-----ce78fdae4ef6---------------hugging_face-----------------)
  - [Mistral Ai](https://medium.com/tag/mistral-ai?source=post_page-----ce78fdae4ef6---------------mistral_ai-----------------)
  - [Langchain](https://medium.com/tag/langchain?source=post_page-----ce78fdae4ef6---------------langchain-----------------)
  - [Bm25](https://medium.com/tag/bm25?source=post_page-----ce78fdae4ef6---------------bm25-----------------)
  - [Semantic Search](https://medium.com/tag/semantic-search?source=post_page-----ce78fdae4ef6---------------semantic_search-----------------)
  - [Status](https://medium.statuspage.io/?source=post_page-----ce78fdae4ef6--------------------------------)
  - [Blog](https://blog.medium.com/?source=post_page-----ce78fdae4ef6--------------------------------)
  - [Text to speech](https://speechify.com/medium?source=post_page-----ce78fdae4ef6--------------------------------)
  - [Teams](https://medium.com/business?source=post_page-----ce78fdae4ef6--------------------------------)