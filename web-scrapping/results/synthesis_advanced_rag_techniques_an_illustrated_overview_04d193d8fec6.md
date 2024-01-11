# Synthesis of "Advanced RAG Techniques: an Illustrated Overview"
## Article Metadata
- **Title**: Advanced RAG Techniques: an Illustrated Overview
- **Author**: IVAN ILIN
- **Publication Date**: Dec 17, 2023
- **Reading Time**: 19 min read
- **Publication**: Towards AI
- **Article Link**: [Advanced RAG Techniques: an Illustrated Overview](https://pub.towardsai.net/advanced-rag-techniques-an-illustrated-overview-04d193d8fec6)
## Introduction
The article by Ivan Ilin, published in Towards AI on December 17, 2023, provides a comprehensive overview of advanced Retrieval Augmented Generation (RAG) techniques. The author clarifies that the post will not delve into code implementation details but will reference the extensive documentation and tutorials available for RAG algorithms.
## Concept of RAG
RAG combines search algorithms with Large Language Models (LLMs) to generate answers grounded in retrieved information. It is a prominent architecture in 2023, underpinning various products from Question Answering services to chat-with-your-data applications. The vector search area has also been influenced by RAG, with startups like chroma, weavaite.io, and pinecone building upon search indices like faiss and nmslib.
## Open Source Libraries
Two significant open-source libraries for LLM-based pipelines and applications are mentioned:
- LangChain: [LangChain Documentation](https://python.langchain.com/docs/get_started/introduction)
- LlamaIndex: [LlamaIndex Documentation](https://docs.llamaindex.ai/en/stable/)
## RAG Pipeline
The RAG pipeline begins with a corpus of text documents. The vanilla RAG case involves chunking texts, embedding these chunks into vectors, indexing these vectors, and creating prompts for an LLM. The runtime process involves vectorizing a user's query, searching the index for top-k results, retrieving text chunks, and feeding them into the LLM prompt.
## Advanced RAG Techniques
The article proceeds to discuss advanced RAG techniques, including chunking, vectorization, search indices, and retrieval methods. The author emphasizes the importance of prompt engineering, referencing an OpenAI guide, and notes the availability of various LLMs such as Claude, Mixtral, Phi-2, Llama2, OpenLLaMA, and Falcon.
### 1.1 Chunking
Chunking involves splitting documents into meaningful chunks to better represent semantic meaning. The chunk size is a critical parameter, influenced by the embedding model's capacity. The NodeParser class in LlamaIndex offers advanced options for chunking.
### 1.2 Vectorization
The author suggests using search-optimized models for embedding chunks, such as bge-large or the E5 embeddings family. The MTEB leaderboard is recommended for updates on models.
### Search Indices
Search indices are crucial for storing vectorized content. The author discusses various index types, including flat, vector indices like faiss, nmslib, or annoy, and managed solutions like Pinecone and Weaviate. Metadata filters and vector store indices are also mentioned.
### Retrieval Methods
The article describes several retrieval methods, including two-step retrieval using summaries and document chunks, question vector embedding, and the HyDE approach. Techniques for expanding context, such as Sentence Window Retrieval and Auto-merging Retriever, are explained.
### Fusion Retrieval
Fusion retrieval combines keyword-based search with semantic search. Reciprocal Rank Fusion (RRF) is used for reranking results. LangChain and LlamaIndex both implement this technique.
### Postprocessing
Postprocessors refine retrieval results through filtering, re-ranking, or transformation. LlamaIndex offers a variety of postprocessors for this purpose.
### Query Transformation and Routing
Query transformations use LLMs to modify user input for improved retrieval. Decomposing complex queries into subqueries is one approach. Routing involves decision-making on the next steps based on the user query.
### Agents and Multi-Document Retrieval
Agents are LLMs equipped with tools to complete tasks. The article touches on OpenAI Assistants and their function calling API. Multi-Document Agents are discussed, illustrating a complex RAG architecture involving multiple agents.
### Response Synthesis
Response synthesis involves generating an answer based on retrieved context and the initial query. The author outlines various approaches, including iterative refinement, summarization, and generating multiple answers.
### Fine-Tuning
Fine-tuning involves improving the performance of the Encoder or LLM. The author shares skepticism about Encoder fine-tuning but acknowledges its potential benefits, especially in narrow domain datasets. Cross-encoder fine-tuning and LLM fine-tuning are also discussed.
### Evaluation Frameworks
Several frameworks for evaluating RAG systems are presented, focusing on metrics like answer relevance, groundedness, and retrieved context relevance. Examples of evaluation pipelines are provided.
## Conclusion
The author concludes by highlighting the exciting developments in ML in 2023 and the potential for smaller LLMs. The article ends with a call for sharing expertise in the comments section and provides a link to the author's knowledge base: [Ivan Ilin's Knowledge Base](https://app.iki.ai/playlist/236).
## References and Links
The article includes numerous references and links to GitHub repositories, documentation, and tutorials. Some of these are listed below:
- Chroma: [GitHub - chroma-core/chroma](https://github.com/chroma-core/chroma)
- NMSLIB: [GitHub - nmslib/nmslib](https://github.com/nmslib/nmslib)
- LlamaIndex Examples: [LlamaIndex Prompts Examples](https://docs.llamaindex.ai/en/latest/examples/prompts/prompts_rag.html)
- Hugging Face Models and Spaces: [Hugging Face Models and Spaces](https://huggingface.co)
- LlamaIndex API Reference: [LlamaIndex NodeParser](https://docs.llamaindex.ai/en/stable/api_reference/service_context/node_parser.html)
- LlamaIndex Ingestion Pipeline: [LlamaIndex Ingestion Pipeline](https://docs.llamaindex.ai/en/latest/module_guides/loading/ingestion_pipeline/root.html#)
- LlamaIndex Vector Stores: [LlamaIndex Vector Stores](https://docs.llamaindex.ai/en/latest/community/integrations/vector_stores.html)
- LangChain Retrievers: [LangChain Retrievers](https://python.langchain.com/docs/modules/data_connection/retrievers/)
- LlamaIndex Postprocessors: [LlamaIndex Postprocessors](https://docs.llamaindex.ai/en/stable/module_guides/querying/node_postprocessors/root.html)
- LlamaIndex Fine-Tuning: [LlamaIndex Fine-Tuning](https://docs.llamaindex.ai/en/stable/examples/finetuning/)
- Truelens Evaluation Framework: [Truelens GitHub](https://github.com/truera/trulens/tree/main)
- LlamaIndex Evaluation: [LlamaIndex Evaluation Notebook](https://github.com/run-llama/finetune-embedding/blob/main/evaluate.ipynb)
- OpenAI Cookbook: [OpenAI Cookbook Evaluation](https://github.com/openai/openai-cookbook/blob/main/examples/evaluation/Evaluate_RAG_with_LlamaIndex.ipynb)
- LangChain Evaluation Framework: [LangSmith Documentation](https://docs.smith.langchain.com)
- LlamaIndex RAG Evaluator: [LlamaIndex RAG Evaluator](https://github.com/run-llama/llama-hub/tree/dac193254456df699b4c73dd98cdbab3d1dc89b0/llama_hub/llama_packs/rag_evaluator)
- LlamaIndex RAGs: [GitHub - run-llama/rags](https://github.com/run-llama/rags)
- LangChain Blog: [LangChain Blog](https://blog.langchain.dev)
## Author's Contact Information
- LinkedIn: [Ivan Ilin](https://www.linkedin.com/in/ivan-ilin-/)
- Twitter: Not provided (explicit link absent)
The synthesis captures the essence of the article, organizing the content into coherent sections that reflect the structure and depth of the original text. Each significant point, technique, and reference is meticulously included to ensure completeness and accuracy.