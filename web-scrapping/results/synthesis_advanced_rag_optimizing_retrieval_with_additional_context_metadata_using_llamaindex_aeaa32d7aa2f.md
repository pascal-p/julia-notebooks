# Article Synthesis: Advanced RAG with LlamaIndex
## Article Details
- **Title**: Advanced RAG: Optimizing Retrieval with Additional Context & MetaData using LlamaIndex🦙
- **Author**: Akash Mathur
- **Date of Publication**: December 23, 2023
- **Reading Time**: 11 minutes
- **Link**: [Medium Article](https://akash-mathur.medium.com/advanced-rag-optimizing-retrieval-with-additional-context-metadata-using-llamaindex-aeaa32d7aa2f)
## Introduction
The article by Akash Mathur is the first part of the Advanced RAG learning series, focusing on optimizing retrieval augmented generation (RAG) by incorporating additional context and metadata using LlamaIndex. RAG is a technique that enhances the knowledge of large language models (LLMs) by integrating external data, which can be private or updated post the model's training cutoff. The article outlines the key stages of RAG and introduces an advanced technique called Parent-Child Chunks Retrieval. It also provides a step-by-step implementation guide using open-source tools and Python code snippets.
## Key Concepts and Implementation
### Stages of RAG
1. **Splitting**: Large text sections are split into smaller chunks to reduce noise and fit within the LLM's maximum context length.
2. **Indexing**: Creation of vector embeddings and metadata strategies to facilitate accurate data retrieval.
3. **Storing**: Indexed data and metadata are stored to avoid re-indexing.
4. **Querying**: Various querying strategies are employed using LLMs and LlamaIndex data structures.
5. **Evaluation**: The effectiveness of the retrieval pipeline is assessed through objective measures.
### Parent-Child Chunks Retrieval
This retrieval technique involves breaking down documents into a hierarchy of chunks, indexing the smallest leaf chunks, and retrieving parent chunks based on the aggregation of child chunks during retrieval. It allows for efficient retrieval of contextually relevant data and provides a more comprehensive context for the LLM's response.
### Step-by-Step Implementation
#### A. Load Data
Data connectors, referred to as `Reader`, are used to ingest data from various sources and format it into `Document` objects.
#### B. Chunking
The `SentenceSplitter` function is utilized to split text into smaller sections without breaking sentences.
#### C. Open Source LLM and Embedding
The open-source LLM `zephyr-7b-alpha` and the embedding model `hkunlp/instructor-large` are used for the implementation. The embedding model generates text embeddings tailored to specific tasks.
#### Indexing and Querying
The article details the process of indexing the data into `Document` objects and querying them using a `QueryEngine`. The querying process is described as a prompt to an LLM, which can be a question, a request for summarization, or a complex instruction.
#### Recursive Retrieval
The implementation includes recursive retrieval, where references to parent nodes are retrieved instead of raw text, allowing for the retrieval of larger context chunks.
#### Metadata Extraction
Additional context, such as summaries and generated questions, is added to the nodes as metadata to enhance the retrieval process.
#### Storage
The article explains how to use Chroma to store embeddings from a `VectorStoreIndex` to avoid re-indexing.
## Conclusion
The article provides a comprehensive guide to enhancing RAG with additional context and metadata using LlamaIndex. It introduces the concept of Parent-Child Chunks Retrieval and walks through the implementation process, including loading data, chunking, indexing, querying, and storage. The article also includes Python code snippets to demonstrate the practical application of these concepts.
## Python Code Snippets
The article includes several Python code snippets, which are essential for understanding the implementation of the advanced RAG technique. Below are the code snippets as presented in the article:
```python
# Code snippet for loading data and chunking
PDFReader = download_loader("PDFReader")
loader = PDFReader()
docs = loader.load_data(file=Path("./data/QLoRa.pdf"))
# combine all the text
doc_text = "\n\n".join([d.get_content() for d in docs])
documents = [Document(text=doc_text)]
node_parser = SentenceSplitter(chunk_size=1024)
base_nodes = node_parser.get_nodes_from_documents(documents)
# set node ids to be a constant
for idx, node in enumerate(base_nodes):
    node.id_ = f"node-{idx}"
# print all the node ids corresponding to all the chunks
for node in base_nodes:
    print(node.id_)
```
```python
# Code snippet for LLM and embedding setup
from google.colab import userdata
# huggingface api token for downloading zephyr-7b
hf_token = userdata.get('hf_token')
quantization_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_compute_dtype=torch.float16,
    bnb_4bit_quant_type="nf4",
    bnb_4bit_use_double_quant=True,
)
def messages_to_prompt(messages):
    # Function to format messages into a prompt
    # ...
# LLM
llm = HuggingFaceLLM(
    model_name="HuggingFaceH4/zephyr-7b-alpha",
    # Additional setup parameters
    # ...
)
# Embedding
embed_model = HuggingFaceInstructEmbeddings(
    model_name="hkunlp/instructor-large", model_kwargs={"device": DEVICE}
)
# ServiceContext setup
service_context = ServiceContext.from_defaults(
    llm=llm, embed_model=embed_model
)
```
```python
# Code snippet for indexing and querying
# Index setup
base_index = VectorStoreIndex(base_nodes, service_context=service_context)
# Retriever setup
base_retriever = base_index.as_retriever(similarity_top_k=2)
# Retrieval example
retrievals = base_retriever.retrieve(
    "Can you tell me about the Paged Optimizers?"
)
for n in retrievals:
    display_source_node(n, source_length=1500)
# Query engine setup
query_engine_base = RetrieverQueryEngine.from_args(
    base_retriever, service_context=service_context
)
# Query example
response = query_engine_base.query(
    "Can you tell me about the Paged Optimizers?"
)
```
```python
# Code snippet for recursive retrieval and metadata extraction
# Recursive retriever setup
retriever_chunk = RecursiveRetriever(
    "vector",
    retriever_dict={"vector": vector_retriever_chunk},
    node_dict=all_nodes_dict,
    verbose=True,
)
# Metadata extraction setup
import nest_asyncio
nest_asyncio.apply()
extractors = [
    # SummaryExtractor(summaries=["self"], llm=llm, show_progress=True),
    QuestionsAnsweredExtractor(questions=1, llm=llm, show_progress=True),
]
# Metadata extraction example
metadata_dicts = []
for extractor in extractors:
    metadata_dicts.extend(extractor.extract(base_nodes))
```
```python
# Code snippet for storage using Chroma
# Initialize client and create collection
db = chromadb.PersistentClient(path="./chroma_db")
chroma_collection = db.get_or_create_collection("QLoRa_knowledge_database")
# Assign Chroma as the vector_store to the context
vector_store = ChromaVectorStore(chroma_collection=chroma_collection)
storage_context = StorageContext.from_defaults(vector_store=vector_store)
# Create your index with storage context
vector_index_metadata_db = VectorStoreIndex(
    all_nodes,
    storage_context=storage_context,
    service_context=service_context
)
```
## External Links and References
The article references several external links and GitHub repositories, which are crucial for accessing the tools and code used in the implementation. Here is a list of the links mentioned in the article:
- [Medium Article](https://akash-mathur.medium.com/advanced-rag-optimizing-retrieval-with-additional-context-metadata-using-llamaindex-aeaa32d7aa2f)
- [Zephyr-7b-alpha LLM](https://huggingface.co/HuggingFaceH4/zephyr-7b-alpha)
- [Instructor-large Embedding Model](https://huggingface.co/hkunlp/instructor-large)
- [MTEB Leaderboard](https://huggingface.co/spaces/mteb/leaderboard)
- [GitHub Notebook for Parent-Child Document Retriever with Metadata Extraction](https://github.com/akashmathur-2212/LLMs-playground/blob/main/LlamaIndex-applications/Advanced-RAG/parent_child_document_retriever/parent_child_document_retriever_metadata_extraction.ipynb)
- [GitHub Repository for Advanced RAG Methods](https://github.com/akashmathur-2212/LLMs-playground/tree/main/LlamaIndex-applications/Advanced-RAG)
- [Akash Mathur's LinkedIn Profile](https://www.linkedin.com/in/akashmathur22/)
- [Akash Mathur's GitHub Profile](https://github.com/akashmathur-2212)
The article also includes tags for further exploration on Medium, such as [Retrieval Augmented](https://medium.com/tag/retrieval-augmented), [LlamaIndex](https://medium.com/tag/llamaindex), [Zephyr](https://medium.com/tag/zephyr), [Open Source LLM](https://medium.com/tag/open-source-llm), and [Metadata](https://medium.com/tag/metadata).
## Final Remarks
The article by Akash Mathur is a valuable resource for those interested in enhancing the capabilities of LLMs through advanced RAG techniques. It provides a clear explanation of the concepts, a detailed implementation guide, and access to the necessary tools and code. The inclusion of Python code snippets and external links further enriches the learning experience for readers.