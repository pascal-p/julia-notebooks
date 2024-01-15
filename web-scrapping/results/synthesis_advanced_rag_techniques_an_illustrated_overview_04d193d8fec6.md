# Advanced RAG Techniques: an Illustrated Overview
## Article Information
- **Title**: Advanced RAG Techniques: an Illustrated Overview
- **Author**: IVAN ILIN
- **Publication Date**: Dec 17, 2023
- **Published In**: Towards AI
- **Reading Time**: 19 min read
- **Article Link**: [https://pub.towardsai.net/advanced-rag-techniques-an-illustrated-overview-04d193d8fec6](https://pub.towardsai.net/advanced-rag-techniques-an-illustrated-overview-04d193d8fec6)
## Introduction
The article by Ivan Ilin, published in Towards AI on December 17, 2023, provides an in-depth overview of advanced Retrieval Augmented Generation (RAG) techniques. The author clarifies that the post will not delve into code implementation details but will reference the extensive documentation and tutorials available for RAG algorithms and techniques. The article is intended for readers who are already familiar with the RAG concept.
## Overview of RAG
RAG combines search algorithms with Large Language Models (LLMs) to generate answers grounded in information retrieved from a data source. This architecture has become the foundation for many products in 2023, including Question Answering services and chat-with-your-data applications. The vector search area has also seen a boost from the RAG hype, with startups like chroma, weavaite.io, and pinecone building upon open-source search indices such as faiss and nmslib.
Two significant open-source libraries for LLM-based pipelines and applications are LangChain and LlamaIndex, both of which have seen substantial adoption in 2023.
## Vanilla RAG Case
The vanilla RAG process involves splitting texts into chunks, embedding these chunks into vectors using a Transformer Encoder model, indexing these vectors, and creating a prompt for an LLM that includes the context retrieved from the search step. During runtime, the user's query is vectorized and searched against the index to find the top-k results, which are then used as context in the LLM prompt.
## Advanced RAG Techniques
The article proceeds to discuss advanced RAG techniques, including:
### 1.1 Chunking
Chunking involves splitting documents into meaningful chunks to better represent their semantic meaning. The size of the chunk is a critical parameter that depends on the embedding model used. The author references research on chunk size selection and mentions the NodeParser class in LlamaIndex for advanced chunking options.
### 1.2 Vectorisation
The next step is choosing a model to embed chunks. The author suggests using search-optimized models like bge-large or E5 embeddings and refers to the MTEB leaderboard for updates. An end-to-end implementation example of chunking and vectorization is available in LlamaIndex.
### Search Index
The search index is crucial for storing vectorized content. The author discusses the use of vector indices like faiss, nmslib, or annoy for efficient retrieval and managed solutions like Pinecone and Weaviate. LlamaIndex supports various vector store indices and simpler index implementations.
### Context Enlarging Approaches
The article describes methods to create two indices, one for summaries and one for document chunks, to improve retrieval efficiency. Another approach is to generate a question for each chunk and embed these questions in vectors, improving search quality due to higher semantic similarity.
### Fusion Retrieval
The author discusses the combination of keyword-based search and vector search using Reciprocal Rank Fusion (RRF) for reranking. This hybrid search usually yields better results by considering both semantic similarity and keyword matching.
### Postprocessors
LlamaIndex offers a variety of postprocessors for filtering and reranking retrieval results based on similarity score, keywords, metadata, or other models.
### Query Transformation and Routing
Query transformations involve using an LLM to modify user input to improve retrieval quality. The author describes techniques for decomposing complex queries into subqueries and references implementations in LangChain and LlamaIndex.
### Source Referencing
The article touches on the importance of accurately referencing sources when generating answers from multiple documents.
### Chat Logic
Chat logic is necessary for handling follow-up questions and dialogue context. The author describes context compression techniques and references implementations in LlamaIndex.
### Query Routing
Query routing involves LLM-powered decision-making on the next steps given a user query. Both LlamaIndex and LangChain support query routers.
### Agents
Agents provide an LLM with tools and tasks to complete. The article briefly discusses agent-based multi-document retrieval and references OpenAI Assistants as a new development in this area.
### Response Synthesis
The final step in a RAG pipeline is generating an answer based on retrieved context and the initial user query. The author outlines various approaches to response synthesis and references the Response synthesizer module in LlamaIndex.
### Model Fine-Tuning
The article discusses fine-tuning the Transformer Encoder or LLM to improve the quality of embeddings and answers. The author shares skepticism about Encoder fine-tuning but acknowledges its potential benefits, especially in narrow domain datasets.
### Evaluation Frameworks
Several frameworks for evaluating RAG systems are mentioned, including Ragas, Truelens, and LangChain's LangSmith. These frameworks assess metrics like answer relevance, groundedness, and retrieved context relevance.
## Conclusion
The author concludes by highlighting the core algorithmic approaches to RAG and the excitement surrounding ML advancements in 2023. The article emphasizes the importance of speed in RAG systems and predicts a bright future for smaller LLMs.
## References and External Links
The article includes numerous references and external links to GitHub repositories, documentation, research papers, and tutorials. Some of the key references are:
- [LangChain Documentation](https://python.langchain.com/docs/get_started/introduction)
- [LlamaIndex Documentation](https://docs.llamaindex.ai/en/stable/)
- [MTEB Leaderboard](https://huggingface.co/spaces/mteb/leaderboard)
- [HyDE Paper](http://boston.lti.cs.cmu.edu/luyug/HyDE/HyDE.pdf)
- [RA-DIT Paper](https://arxiv.org/pdf/2310.01352.pdf)
- [Truelens GitHub Repository](https://github.com/truera/trulens/tree/main)
- [LlamaIndex Fine-Tuning Tutorial](https://docs.llamaindex.ai/en/stable/examples/finetuning/knowledge/finetune_retrieval_aug.html#fine-tuning-with-retrieval-augmentation)
The author also provides a link to their knowledge base and social media profiles:
- [Ivan Ilin's Knowledge Base](https://app.iki.ai/playlist/236)
- [LinkedIn Profile](https://www.linkedin.com/in/ivan-ilin-/)
- [Twitter Profile](https://medium.com/@ivanilin_iki?source=post_page-----04d193d8fec6--------------------------------)
The article is rich with insights and practical information for those interested in developing and optimizing RAG systems.