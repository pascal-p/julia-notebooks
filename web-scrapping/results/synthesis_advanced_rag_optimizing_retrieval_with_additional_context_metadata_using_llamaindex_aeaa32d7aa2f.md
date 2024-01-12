# Article Synthesis: Advanced RAG with LlamaIndex
## Article Overview
- **Title**: Advanced RAG: Optimizing Retrieval with Additional Context & MetaData using LlamaIndex🦙
- **Author**: Akash Mathur
- **Date**: December 23, 2023
- **Reading Time**: 11 minutes
- **Link**: [Medium Article](https://akash-mathur.medium.com/advanced-rag-optimizing-retrieval-with-additional-context-metadata-using-llamaindex-aeaa32d7aa2f)
## Introduction
The article by Akash Mathur is the first part of the Advanced RAG learning series, focusing on optimizing retrieval augmented generation (RAG) by incorporating additional context and metadata using LlamaIndex. RAG is a technique that enhances language model knowledge with external data, which is particularly useful for reasoning about private or real-time data not included in the model's training. The article outlines the five key stages of RAG and introduces an advanced technique called Parent-Child Chunks Retrieval. It also provides a step-by-step guide, complete with code snippets, on implementing this technique using LlamaIndex, an open-source LLM, and embedding models.
## Key Concepts and Implementation
### Stages of RAG
1. **Splitting**: Large sections of text are split into smaller chunks to reduce noise and fit within the maximum context length of language models.
2. **Indexing**: Creating vector embeddings and metadata strategies for querying data.
3. **Storing**: Indexed data and metadata are stored to avoid re-indexing.
4. **Querying**: Utilizing various querying strategies with LlamaIndex data structures.
5. **Evaluation**: Assessing the effectiveness of the retrieval pipeline.
### Parent-Child Chunks Retrieval
This retrieval technique involves breaking down documents into a hierarchy of chunks, indexing the smallest leaf chunks, and retrieving them based on relevance. If multiple leaf chunks refer to the same parent chunk, they are replaced with the parent chunk for answer generation. The search is performed within the child nodes index.
### Step-by-Step Implementation
#### A. Load Data
Data connectors, referred to as `Reader`, ingest data from various sources and format it into `Document` objects.
#### B. Chunking
The `SentenceSplitter` function is used to split text into smaller sections, creating an initial set of nodes.
#### C. Open Source LLM and Embedding
The article uses the open-source LLM `zephyr-7b-alpha` and the embedding model `hkunlp/instructor-large`. The `ServiceContext` object is set up for constructing an index and querying.
#### Indexing and Querying
The data is indexed, and a baseline retriever fetches the top-k raw text nodes by embedding similarity. The `QueryEngine` is then used for querying.
#### Recursive Retrieval
The article demonstrates recursive retrieval, where smaller chunks are retrieved first, followed by references to bigger chunks, providing more context for synthesis.
#### Metadata Addition
Additional metadata, including summaries and generated questions, are added to the nodes to enhance the context.
#### Storage
The indexed data is stored using Chroma to avoid re-indexing costs.
### Code Snippets
The article includes several Python code snippets demonstrating the loading of data, chunking, indexing, querying, and storage using LlamaIndex and associated tools.
## Conclusion
The article provides a comprehensive guide on enhancing RAG with additional context and metadata using LlamaIndex. It showcases an advanced retrieval technique that improves the efficiency and relevance of data retrieval for language models. The step-by-step instructions and code snippets offer practical insights into implementing this technique.
## External Links and References
The article references several external links, including GitHub repositories for the notebook code and advanced RAG methods, as well as links to the open-source LLM and embedding models used in the implementation.
- [Notebook on GitHub](https://github.com/akashmathur-2212/LLMs-playground/blob/main/LlamaIndex-applications/Advanced-RAG/parent_child_document_retriever/parent_child_document_retriever_metadata_extraction.ipynb)
- [Advanced RAG Methods Repository](https://github.com/akashmathur-2212/LLMs-playground/tree/main/LlamaIndex-applications/Advanced-RAG)
- [Open Source LLM: zephyr-7b-alpha](https://huggingface.co/HuggingFaceH4/zephyr-7b-alpha)
- [Embedding Model: hkunlp/instructor-large](https://huggingface.co/hkunlp/instructor-large)
- [MTEB Leaderboard](https://huggingface.co/spaces/mteb/leaderboard)
The article also includes a list of tags and additional resources for further reading and exploration.
## Code Snippets
The code snippets provided in the article are in Python and cover various aspects of the RAG implementation using LlamaIndex. They are presented verbatim as they appear in the article.
```python
PDFReader = download_loader("PDFReader")
loader = PDFReader()
docs = loader.load_data(file=Path("./data/QLoRa.pdf"))
# combine all the text
doc_text = "\n\n".join([d.get_content() for d in docs])
documents = [Document(text=doc_text)]
```
```python
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
    prompt = ""
    for message in messages:
        if message.role == 'system':
            prompt += f"<|system|>\n{message.content}</s>\n"
        elif message.role == 'user':
            prompt += f"<|user|>\n{message.content}</s>\n"
        elif message.role == 'assistant':
            prompt += f"<|assistant|>\n{message.content}</s>\n"
    # ensure we start with a system prompt, insert blank if needed
    if not prompt.startswith("<|system|>\n"):
        prompt = "<|system|>\n</s>\n" + prompt
    # add final assistant prompt
    prompt = prompt + "<|assistant|>\n"
    return prompt
# LLM
llm = HuggingFaceLLM(
    model_name="HuggingFaceH4/zephyr-7b-alpha",
    tokenizer_name="HuggingFaceH4/zephyr-7b-alpha",
    query_wrapper_prompt=PromptTemplate("<|system|>\n</s>\n<|user|>\n{query_str}</s>\n<|assistant|>\n"),
    context_window=3900,
    max_new_tokens=256,
    model_kwargs={"quantization_config": quantization_config},
    # tokenizer_kwargs={},
    generate_kwargs={"temperature": 0.7, "top_k": 50, "top_p": 0.95},
    messages_to_prompt=messages_to_prompt,
    device_map="auto",
)
# Embedding
embed_model = HuggingFaceInstructEmbeddings(
    model_name="hkunlp/instructor-large", model_kwargs={"device": DEVICE}
)
# set your ServiceContext for all the next steps
service_context = ServiceContext.from_defaults(
    llm=llm, embed_model=embed_model
)
```
```python
# index
base_index = VectorStoreIndex(base_nodes, service_context=service_context)
```
```python
# find top 2 nodes
base_retriever = base_index.as_retriever(similarity_top_k=2)
retrievals = base_retriever.retrieve(
    "Can you tell me about the Paged Optimizers?"
)
for n in retrievals:
    display_source_node(n, source_length=1500)
```
```python
# create a query engine
query_engine_base = RetrieverQueryEngine.from_args(
    base_retriever, service_context=service_context
)
# query
response = query_engine_base.query(
    "Can you tell me about the Paged Optimizers?"
)
```
```python
sub_chunk_sizes = [256, 512]
sub_node_parsers = [SentenceSplitter(chunk_size=c) for c in sub_chunk_sizes]
all_nodes = []
for base_node in base_nodes:
    for n in sub_node_parsers:
        sub_nodes = n.get_nodes_from_documents([base_node])
        sub_inodes = [
            IndexNode.from_text_node(sn, base_node.node_id) for sn in sub_nodes
        ]
        all_nodes.extend(sub_inodes)
    # also add original node to node
    original_node = IndexNode.from_text_node(base_node, base_node.node_id)
    all_nodes.append(original_node)
all_nodes_dict = {n.node_id: n for n in all_nodes}
```
```python
vector_index_chunk = VectorStoreIndex(
    all_nodes, service_context=service_context
)
vector_retriever_chunk = vector_index_chunk.as_retriever(similarity_top_k=2)
```
```python
# Recursive Retriever
retriever_chunk = RecursiveRetriever(
    "vector",
    retriever_dict={"vector": vector_retriever_chunk},
    node_dict=all_nodes_dict,
    verbose=True,
)
# query
nodes = retriever_chunk.retrieve(
    "Can you tell me about the Paged Optimizers?"
)
for node in nodes:
    display_source_node(node, source_length=2000)
```
```python
# Retriever Query Engine
query_engine_chunk = RetrieverQueryEngine.from_args(
    retriever_chunk, service_context=service_context
)
# query
response = query_engine_chunk.query(
    "Can you tell me about the Paged Optimizers?"
)
```
```python
import nest_asyncio
nest_asyncio.apply()
extractors = [
    # SummaryExtractor(summaries=["self"], llm=llm, show_progress=True),
    QuestionsAnsweredExtractor(questions=1, llm=llm, show_progress=True),
]
# run metadata extractor across base nodes, get back dictionaries
metadata_dicts = []
for extractor in extractors:
    metadata_dicts.extend(extractor.extract(base_nodes))
```
```python
# all nodes consists of source nodes, along with metadata
import copy
all_nodes = copy.deepcopy(base_nodes)
for idx, d in enumerate(metadata_dicts):
    # QnA node
    inode_q = IndexNode(
        text=d["questions_this_excerpt_can_answer"],
        index_id=base_nodes[idx].node_id,
    )
    # Summary node
    # inode_s = IndexNode(
    #     text=d["section_summary"], index_id=base_nodes[idx].node_id)
    all_nodes.extend([inode_q]) #, inode_s
    # all_nodes_dict
    all_nodes_dict = {n.node_id: n for n in all_nodes}
```
```python
vector_index_metadata = VectorStoreIndex(all_nodes, service_context=service_context)
vector_retriever_metadata = vector_index_metadata.as_retriever(similarity_top_k=2)
```
```python
retriever_metadata = RecursiveRetriever(
    "vector",
    retriever_dict={"vector": vector_retriever_metadata},
    node_dict=all_nodes_dict,
    verbose=True,
)
nodes = retriever_metadata.retrieve(
    "Can you tell me about the Paged Optimizers?"
)
for node in nodes:
    display_source_node(node, source_length=2000)
```
```python
query_engine_metadata = RetrieverQueryEngine.from_args(
    retriever_metadata, service_context=service_context
)
response = query_engine_metadata.query(
    "Can you tell me about the Paged Optimizers?"
)
```
```python
# initialize client, setting path to save data
db = chromadb.PersistentClient(path="./chroma_db")
# create collection
chroma_collection = db.get_or_create_collection("QLoRa_knowledge_database")
# assign chroma as the vector_store to the context
vector_store = ChromaVectorStore(chroma_collection=chroma_collection)
storage_context = StorageContext.from_defaults(vector_store=vector_store)
# create your index
vector_index_metadata_db = VectorStoreIndex(
    all_nodes,
    storage_context=storage_context,
    service_context=service_context
)
```
## Additional Information
The author encourages readers to refer to the provided GitHub repositories for the notebook code and other advanced RAG methods. The article concludes with an invitation to engage with the content and the author's work.
- [LLMs Playground GitHub Repository](https://github.com/akashmathur-2212/LLMs-playground)
- [Advanced RAG GitHub Repository](https://github.com/akashmathur-2212/LLMs-playground/tree/main/LlamaIndex-applications/Advanced-RAG)
- [Akash Mathur's LinkedIn Profile](https://www.linkedin.com/in/akashmathur22/)
- [Akash Mathur's GitHub Profile](https://github.com/akashmathur-2212)
The article also includes a variety of tags for further exploration on Medium, such as Retrieval Augmented, LlamaIndex, Zephyr, Open Source LLM, and Metadata.