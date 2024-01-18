### Article Synthesis: Advanced RAG Implementation on Custom Data Using Hybrid Search, Embed Caching And Mistral-AI
#### Article Details
- **Title:** Advanced RAG Implementation on Custom Data Using Hybrid Search, Embed Caching And Mistral-AI
- **Author:** Plaban Nayak
- **Publication Date:** Oct 8, 2023
- **Published In:** AI Planet
- **Read Time:** 40 min read
#### Introduction
The article discusses an advanced implementation of Retrieval Augmented Generation (RAG) on custom data, utilizing concepts such as caching embeddings, hybrid vector search, and in-memory caching. The implementation leverages the capabilities of Mistral-AI and is executed on Google Colab with an A100 GPU. The data used for this implementation consists of financial documents.
#### What is RAG?
RAG is a methodology that combines information retrieval and natural language generation to enhance the quality and relevance of generated text for complex language tasks. It aims to improve the accuracy, coherence, and informativeness of the content by incorporating relevant information from retrieval into the generation process.
#### Advanced RAG Concepts Implemented
The advanced RAG pipeline includes the following concepts:
- **Caching Embeddings:** Using `CacheBackedEmbeddings`, embeddings are stored or temporarily cached to avoid recomputation. The cache-backed embedder is a wrapper around an embedder that caches embeddings in a key-value store using the text hash as the key.
- **Hybrid Vector Search:** A combination of keyword search (using BM25 algorithm) and semantic search (using FAISS for semantic search and BM25 for keyword search). The `EnsembleRetriever` ensembles the results of multiple retrievers and reranks them using the Reciprocal Rank Fusion algorithm.
- **InMemoryCaching:** Caching happens for every user query and response generated, provided the user query does not match an already requested query.
#### Implementation Stack
- **Embedder:** BAAI general embedding
- **Retrieval:** FAISS Vectorstore
- **Generation:** Mistral-7B-Instruct GPTQ model
- **Infrastructure:** Google Colab, A100 GPU
- **Data:** Financial Documents
#### Implementation Details
The implementation involves installing necessary packages, importing packages, parsing and loading data, creating vector stores, setting up retrievers, downloading the quantized GPTQ model, creating pipelines, setting up caching, formulating prompt templates, and setting up retrieval chains with and without hybrid search.
#### Code Snippets
The article includes several code snippets demonstrating the setup and usage of various components in the RAG implementation. These snippets cover package installation, imports, data loading, text splitting, vector store creation, retriever setup, model downloading, pipeline creation, caching, prompt formulation, and retrieval chain setup.
#### Conclusion
The hybrid search using `EnsembleRetriever` provides better context to the Generative AI Model, resulting in more accurate responses. Caching the response and query reduces inference time and computation cost. The article demonstrates the effectiveness of these advanced RAG concepts in processing and generating responses from financial documents.
#### References
The article references several resources, including the official documentation for langchain, Hugging Face, Mistral Ai, BM25, and Semantic Search.
#### Performance Metrics
The article includes performance metrics such as response times and the number of documents returned, highlighting the efficiency gains from caching and hybrid search techniques.
#### Contact Information
The author, Plaban Nayak, is an editor for AI Planet and a machine learning and deep learning enthusiast. The article provides links to connect with the author and the publication AI Planet.
#### Additional Information
The article also includes links to various Medium resources, such as the author's profile, AI Planet publication, and additional tags related to the article's content.
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