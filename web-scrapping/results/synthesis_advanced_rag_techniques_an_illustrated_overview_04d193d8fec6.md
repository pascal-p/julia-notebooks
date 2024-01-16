# Advanced RAG Techniques: an Illustrated Overview
## Article Details
- **Title**: Advanced RAG Techniques: an Illustrated Overview
- **Author**: IVAN ILIN
- **Publication Date**: December 17, 2023
- **Reading Time**: 19 minutes
- **Publication**: Towards AI
- **Article Link**: [Advanced RAG Techniques: an Illustrated Overview](https://pub.towardsai.net/advanced-rag-techniques-an-illustrated-overview-04d193d8fec6)
## Introduction
The article provides a comprehensive study of advanced Retrieval Augmented Generation (RAG) techniques and algorithms, aiming to systematize various approaches. The author, Ivan Ilin, published the article on December 17, 2023, in Towards AI. RAG combines search algorithms with Large Language Models (LLMs) to generate answers grounded in retrieved information. The article does not delve into implementation details but references extensive documentation and tutorials.
RAG has become the most popular architecture for LLM-based systems in 2023, with applications ranging from QA services to chat-with-your-data apps. The vector search area has also seen growth, with databases like Chroma, weaviate.io, and Pinecone building upon open-source search indices like faiss and nmslib.
Two prominent open-source libraries for LLM-based pipelines and applications are LangChain and LlamaIndex, which have seen massive adoption following the launch of ChatGPT.
The article's purpose is to systematize key advanced RAG techniques with references to their implementations, mostly in LlamaIndex, to aid developers in understanding the technology. The author notes that most tutorials focus on a few techniques rather than the full variety of available tools.
## Naive RAG
The starting point of a RAG pipeline is a corpus of text documents. The vanilla RAG case involves splitting texts into chunks, embedding these chunks into vectors using a Transformer Encoder model, indexing these vectors, and creating a prompt for an LLM that includes the retrieved context. During runtime, the user's query is vectorized and searched against the index to find the top-k results, which are then used as context in the LLM prompt. Prompt engineering is highlighted as a cost-effective way to improve RAG pipelines, with a reference to OpenAI's prompt engineering guide.
## Advanced RAG
The advanced RAG section overviews core steps and algorithms, excluding logic loops and complex multistep behaviors for clarity. The article discusses chunking & vectorization, search index, hierarchical indices, hypothetical questions and HyDE, context enrichment, fusion retrieval or hybrid search, reranking & filtering, query transformations, reference citations, chat engine, query routing, agents in RAG, response synthesizer, and encoder and LLM fine-tuning.
### 1. Chunking & Vectorisation
Chunking involves splitting documents into meaningful chunks to better represent their semantic meaning. The chunk size is a critical parameter that balances context for the LLM against specific text embedding for efficient search. Vectorisation involves choosing a model to embed chunks, with search-optimized models like bge-large or E5 embeddings being popular choices. An end-to-end implementation example is provided for LlamaIndex.
### 2. Search Index
The search index stores vectorized content and is crucial for RAG pipelines. Naive implementations use a flat index, while proper search indices like faiss, nmslib, or annoy use Approximate Nearest Neighbours algorithms for efficient retrieval. Managed solutions and vector databases are also mentioned. Metadata storage and filters can enhance search capabilities.
### 3. Reranking & Filtering
After retrieval, results can be refined through filtering, re-ranking, or transformation using various postprocessors. These can filter out results based on similarity score, keywords, metadata, or rerank them with other models like an LLM, sentence-transformer cross-encoder, or Cohere reranking endpoint.
### 4. Query Transformations
Query transformations use an LLM to modify user input to improve retrieval quality. Techniques include decomposing complex queries into subqueries, step-back prompting, and query re-writing. Both LangChain and LlamaIndex have implementations for these techniques.
### 5. Chat Engine
Chat engines manage dialogue context for follow-up questions and user commands. Context compression techniques take chat history into account. Examples include ContextChatEngine and CondensePlusContextMode. OpenAI agents based Chat Engine is also supported by LlamaIndex.
### 6. Query Routing
Query routing involves LLM-powered decision-making on the next steps given a user query. Query routers select an index or data store for the query, which can include multiple sources or hierarchical indices. Both LlamaIndex and LangChain support query routers.
### 7. Agents in RAG
Agents provide an LLM with tools and tasks to complete, which can include deterministic functions, external APIs, or other agents. The concept of chaining agents is where LangChain got its name. The article briefly discusses OpenAI Assistants and their function calling API, with LlamaIndex integrating this logic with ChatEngine and QueryEngine classes.
### 8. Response Synthesiser
The final step in a RAG pipeline is to generate an answer based on retrieved context and the initial user query. Techniques include iteratively refining the answer, summarising the retrieved context, and generating multiple answers based on different context chunks.
### Encoder and LLM Fine-Tuning
Fine-tuning the Transformer Encoder or LLM can improve the quality of embeddings and the LLM's use of provided context. The article discusses the performance increase from fine-tuning and provides examples and references for further reading.
## Evaluation
The article mentions several frameworks for RAG systems performance evaluation, focusing on metrics like answer relevance, groundedness, and retrieved context relevance. Examples of evaluation frameworks include Ragas, Truelens, and LangSmith.
## Conclusion
The author summarizes the core algorithmic approaches to RAG and hopes to inspire novel ideas for RAG pipelines. The article also touches on other considerations like web search-based RAG, agentic architectures, and LLMs long-term memory. The main production challenge for RAG systems is speed, especially in agent-based schemes.
## References and Links
The article includes a comprehensive list of references and links to various implementations, studies, and documentation related to the discussed RAG techniques. The main references are collected in the author's knowledge base, accessible at [https://app.iki.ai/playlist/236](https://app.iki.ai/playlist/236).
The author, Ivan Ilin, can be found on [LinkedIn](https://www.linkedin.com/in/ivan-ilin-/) and [Twitter](https://medium.com/@ivanilin_iki?source=post_page-----04d193d8fec6--------------------------------).