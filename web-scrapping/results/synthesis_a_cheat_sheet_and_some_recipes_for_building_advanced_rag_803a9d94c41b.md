# Synthesis of "A Cheat Sheet and Some Recipes For Building Advanced RAG"
## Article Information
- **Title:** A Cheat Sheet and Some Recipes For Building Advanced RAG
- **Author:** Andrei
- **Publication Date:** 2 days ago from the knowledge cutoff date
- **Reading Time:** 7 min read
- **Publication Platform:** LlamaIndex Blog
- **Article Link:** [A Cheat Sheet and Some Recipes For Building Advanced RAG](https://blog.llamaindex.ai/a-cheat-sheet-and-some-recipes-for-building-advanced-rag-803a9d94c41b)
## Introduction
The article is intended for individuals looking to either start building Retrieval-Augmented Generation (RAG) systems or enhance their existing basic RAG systems. It aims to provide guidance and a mental model for making decisions in the construction of advanced RAG systems. The inspiration for the RAG cheat sheet provided in the article comes from a recent survey paper by Gao, Yunfan, et al. (2023) titled "Retrieval-Augmented Generation for Large Language Models: A Survey."
## Main Content
### Definition of RAG
RAG systems involve three main components:
1. A Retrieval component
2. An External Knowledge database
3. A Generation component
These systems retrieve documents from an external knowledge database and use them along with the user's query to generate responses.
### Success Requirements for RAG Systems
For a RAG system to be successful, it must meet two high-level requirements:
1. Accurate retrieval of relevant documents.
2. Generation of useful and relevant answers to user questions.
Advanced RAG systems apply sophisticated techniques to the Retrieval or Generation components to meet these requirements.
### Techniques for Advanced RAG Systems
#### For Accurate Retrieval
1. **LlamaIndex Chunk Size Optimization Recipe**:
   - A notebook guide is mentioned but not provided in the excerpt.
2. **Structured External Knowledge**:
   - Complex scenarios may require structured external knowledge to allow recursive retrievals or routed retrieval for sensibly separated knowledge sources.
   - **LlamaIndex Recursive Retrieval Recipe**:
     - A notebook guide is mentioned but not provided in the excerpt.
#### For Aligned Generation
1. **LlamaIndex Information Compression Recipe**:
   - A notebook guide is mentioned but not provided in the excerpt.
2. **Result Re-Rank**:
   - To counter the "Lost in the Middle" phenomenon in LLMs, re-ranking retrieved documents before generation can be beneficial.
   - **LlamaIndex Re-Ranking For Better Generation Recipe**:
     - A notebook guide is mentioned but not provided in the excerpt.
#### For Synergistic Techniques
1. **LlamaIndex Generator-Enhanced Retrieval Recipe**:
   - A notebook guide is mentioned but not provided in the excerpt.
2. **Iterative Retrieval-Generator RAG**:
   - Multi-step reasoning may be required for complex user queries.
   - **LlamaIndex Iterative Retrieval-Generator Recipe**:
     - A notebook guide is mentioned but not provided in the excerpt.
### Evaluation of RAG Systems
The article references the survey paper by Gao, Yunfan, et al. for seven measurement aspects important for evaluating RAG systems. The llama-index library offers several evaluation abstractions and integrations to RAGAs for builders to assess their systems.
### Python Code Snippets
The article includes several Python code snippets demonstrating how to use the llama_index library for building and evaluating RAG systems. These snippets cover loading data, building indexes, defining query engines, and performing hyperparameter tuning, among other tasks.
```python
from llama_index import SimpleDirectoryReader, VectorStoreIndex
# load data
documents = SimpleDirectoryReader(input_dir="...").load_data()
# build VectorStoreIndex that takes care of chunking documents
# and encoding chunks to embeddings for future retrieval
index = VectorStoreIndex.from_documents(documents=documents)
# The QueryEngine class is equipped with the generator
# and facilitates the retrieval and generation steps
query_engine = index.as_query_engine()
# Use your Default RAG
response = query_engine.query("A user's query")
```
```python
from llama_index import ServiceContext
from llama_index.param_tuner.base import ParamTuner, RunResult
from llama_index.evaluation import SemanticSimilarityEvaluator, BatchEvalRunner
# ... [Objective function and hyperparameter tuning code omitted for brevity]
```
```python
from llama_index import SimpleDirectoryReader, VectorStoreIndex
from llama_index.node_parser import SentenceSplitter
from llama_index.schema import IndexNode
# ... [Recursive retriever building code omitted for brevity]
```
```python
from llama_index import SimpleDirectoryReader, VectorStoreIndex
from llama_index.query_engine import RetrieverQueryEngine
from llama_index.postprocessor import LongLLMLinguaPostprocessor
# ... [Postprocessor and QueryEngine definition code omitted for brevity]
```
```python
import os
from llama_index import SimpleDirectoryReader, VectorStoreIndex
from llama_index.postprocessor.cohere_rerank import CohereRerank
from llama_index.postprocessor import LongLLMLinguaPostprocessor
# ... [CohereRerank postprocessor and QueryEngine code omitted for brevity]
```
```python
from llama_index.llms import OpenAI
from llama_index.query_engine import FLAREInstructQueryEngine
from llama_index import (
VectorStoreIndex,
SimpleDirectoryReader,
ServiceContext,
)
# ... [FLAREInstructQueryEngine building code omitted for brevity]
```
```python
from llama_index.query_engine import RetryQueryEngine
from llama_index.evaluation import RelevancyEvaluator
# ... [RetryQueryEngine building code omitted for brevity]
```
## External Links and References
The article provides several external links and references, including notebook guides, survey papers, and the llama-index library documentation. However, the full details of these links are not provided within the excerpt. Notably, the links to the notebook guides are mentioned multiple times but are not directly accessible from the excerpt.
## Conclusion
The blog post aims to equip readers with the knowledge and confidence to apply sophisticated techniques for building advanced RAG systems. It emphasizes the importance of accurate retrieval and relevant response generation, and it provides a variety of recipes and code examples to guide users in enhancing their RAG systems. The article also underscores the significance of evaluating RAG systems to ensure they meet the defined success requirements.