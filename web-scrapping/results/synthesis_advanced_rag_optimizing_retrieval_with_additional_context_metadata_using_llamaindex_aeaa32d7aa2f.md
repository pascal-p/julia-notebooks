### Article Overview
#### Title:
Advanced RAG: Optimizing Retrieval with Additional Context & MetaData using LlamaIndex🦙
#### Author and Date:
Akash Mathur, December 23, 2023
#### Source:
[Medium Article](https://akash-mathur.medium.com/advanced-rag-optimizing-retrieval-with-additional-context-metadata-using-llamaindex-aeaa32d7aa2f)
#### Main Content:
The article is the first part of the Advanced RAG learning series, focusing on optimizing retrieval augmented generation (RAG) with additional context and metadata using LlamaIndex. RAG is a technique that augments large language models (LLMs) with additional data, which can be private or real-time, to enhance their knowledge base. The article outlines the five key stages within RAG: Splitting, Indexing, Storing, Querying, and Evaluation. It then introduces an advanced RAG technique called Parent-Child Chunks Retrieval, which involves breaking down documents into a hierarchy of chunks and retrieving them efficiently.
#### Key Concepts and Implementations:
- **Parent-Child Chunks Retrieval**: This retrieval method involves splitting documents into smaller chunks and indexing them. During retrieval, smaller chunks are fetched first, and if multiple chunks refer to the same parent chunk, the parent chunk is used to provide a broader context for the LLM.
- **Implementation Steps**:
  - **A. Load Data**: Data is loaded using data connectors (Readers) and formatted into Document objects.
  - **B. Chunking**: The `SentenceSplitter` function is used to split text into smaller sections without breaking sentences.
  - **C. Open Source LLM and Embedding**: The open-source LLM `zephyr-7b-alpha` and the embedding model `hkunlp/instructor-large` are used for generating embeddings.
- **Indexing and Querying**:
  - **a) Indexing**: Document objects are indexed to enable querying by an LLM.
  - **b) Base Retriever**: A baseline retriever fetches the top-k raw text nodes by embedding similarity.
  - **c) Querying**: The `QueryEngine` is used to prompt the LLM for various tasks.
- **Recursive Retrieval**:
  - **a) Indexing (from these smaller chunks)**: References are retrieved instead of raw text, with multiple references pointing to the same node.
  - **b) Recursive Retriever**: This retriever follows references to retrieve larger context chunks.
  - **c) Querying (with MetaData)**: Additional context, such as summaries and questions, is added to the nodes.
- **Storage and Evaluation**:
  - The indexed data is stored using Chroma to avoid re-indexing costs.
  - Evaluations are run on retrievers to measure hit rate and MRR for the specific use case.
#### Code Snippets:
The article includes Python code snippets demonstrating the implementation of the discussed concepts. These snippets cover the loading of data, chunking, setting up the LLM and embedding models, indexing, querying, adding metadata, and storing the indexed data.
#### References and Links:
The article provides several references and links to resources such as GitHub repositories, the MTEB leaderboard, and the Hugging Face models used in the implementation.
#### Conclusion:
The article provides a detailed explanation of how to enhance the retrieval capabilities of LLMs using advanced RAG techniques with LlamaIndex. It offers a step-by-step guide on implementing Parent-Child Chunks Retrieval, including code examples and references to external resources.
### External Links and References
- [MTEB Leaderboard](https://huggingface.co/spaces/mteb/leaderboard)
- [GitHub Repository for Notebook Code](https://github.com/akashmathur-2212/LLMs-playground/blob/main/LlamaIndex-applications/Advanced-RAG/parent_child_document_retriever/parent_child_document_retriever_metadata_extraction.ipynb)
- [GitHub Repository for Advanced RAG Methods](https://github.com/akashmathur-2212/LLMs-playground/tree/main/LlamaIndex-applications/Advanced-RAG)
- [Hugging Face Model - zephyr-7b-alpha](https://huggingface.co/HuggingFaceH4/zephyr-7b-alpha)
- [Hugging Face Model - hkunlp/instructor-large](https://huggingface.co/hkunlp/instructor-large)
(Note: The full details of some links or references may not be available within the provided excerpt. The links are rendered as per the information available in the excerpt.)