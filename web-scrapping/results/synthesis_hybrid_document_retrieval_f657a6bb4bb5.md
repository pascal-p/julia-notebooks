# Hybrid Document Retrieval: A Comprehensive Synthesis
## Article Overview
- **Title**: Hybrid Document Retrieval
- **Author**: Isabelle Nguyen
- **Publication Date**: August 25, 2023
- **Published In**: deepset-ai
- **Read Time**: 6 minutes
- **Article Link**: [Hybrid Document Retrieval](https://medium.com/deepset-ai/hybrid-document-retrieval-f657a6bb4bb5)
## Introduction
The article "Hybrid Document Retrieval" by Isabelle Nguyen, published on August 25, 2023, in deepset-ai, explores the concept of combining different document retrieval methods to enhance the efficiency and accuracy of extracting relevant documents from a corpus. The author discusses the advantages and limitations of both keyword-based and dense encoder models for document retrieval and proposes a hybrid approach that leverages the strengths of both. The article also introduces Haystack, a framework that facilitates the creation of such hybrid retrieval pipelines.
## Main Concepts and Discussion
### The Need for Hybrid Document Retrieval
Document retrieval is crucial in processing large collections of documents, especially when it is impractical to run language models on the entire corpus. The author emphasizes the importance of using retrievers to efficiently pre-select documents for further processing, such as extractive question answering or summarization.
### Types of Retrievers
Retrievers are categorized into two main types:
1. **Sparse Retrievers**: These rely on keyword-based methods like BM25, which produce long, sparse vectors representing documents. Sparse retrievers are lexical, language- and domain-agnostic, and do not require training.
   
2. **Dense Retrievers**: These use Transformers and require data and training to produce shorter, dense vectors that represent semantic features. However, they may perform poorly on data that is outside the domain of their training.
### Combining Dense and Sparse Retrievers
The author suggests combining dense and sparse retrievers to mitigate their individual weaknesses and capitalize on their strengths. This hybrid approach involves using two retrievers and merging their outputs, potentially with a ranker to improve the relevance of the results.
### Implementing a Hybrid Retrieval Pipeline in Haystack
Haystack is presented as a modular framework that simplifies the creation of hybrid retrieval pipelines. The author describes how to customize a pipeline with two retriever nodes and a `JoinDocuments` node to combine the results. Different methods for merging results are discussed:
- **Concatenation**: Combines all documents without considering their order.
- **Reciprocal Rank Fusion (RRF)**: Reranks documents, prioritizing those appearing in both result lists.
- **Merging**: Ranks documents according to the scores from the retrievers, which is not recommended for hybrid retrieval due to score incompatibility.
An additional ranking step can be added using a `SentenceTransformersRanker` node, which re-ranks documents and standardizes relevance scores for downstream tasks.
## Conclusion and Additional Resources
The article concludes by endorsing Haystack as the preferred framework for building natural language search systems that incorporate the latest language models. The author invites readers to join the Haystack Discord community for further assistance and discussion on open-source NLP and LLMs.
## Links and References
The article provides several links for further exploration and resources:
- [Open in app](https://rsci.app.link/?%24canonical_url=https%3A%2F%2Fmedium.com%2Fp%2Ff657a6bb4bb5&%7Efeature=LoOpenInAppButton&%7Echannel=ShowPostUnderCollection&source=---two_column_layout_nav----------------------------------)
- [deepset-ai](https://medium.com/deepset-ai?source=post_page-----f657a6bb4bb5--------------------------------)
- [Haystack on GitHub](https://github.com/deepset-ai/haystack)
- [Status](https://medium.statuspage.io/?source=post_page-----f657a6bb4bb5--------------------------------)
- [Blog](https://blog.medium.com/?source=post_page-----f657a6bb4bb5--------------------------------)
- [Text to speech](https://speechify.com/medium?source=post_page-----f657a6bb4bb5--------------------------------)
The article does not contain any code snippets to be rendered verbatim.
#### Links:
  - [Open in app](https://rsci.app.link/?%24canonical_url=https%3A%2F%2Fmedium.com%2Fp%2Ff657a6bb4bb5&%7Efeature=LoOpenInAppButton&%7Echannel=ShowPostUnderCollection&source=---two_column_layout_nav----------------------------------)
  - [medium.com](https://medium.com/deepset-ai?source=post_page-----f657a6bb4bb5--------------------------------)
  - [deepset-ai](https://medium.com/deepset-ai?source=post_page-----f657a6bb4bb5--------------------------------)
  - [Haystack](https://github.com/deepset-ai/haystack)
  - [Haystack](https://github.com/deepset-ai/haystack/tree/main)
  - [medium.com](https://medium.com/deepset-ai?source=post_page-----f657a6bb4bb5--------------------------------)
  - [deepset-ai](https://medium.com/deepset-ai?source=post_page-----f657a6bb4bb5--------------------------------)
  - [Status](https://medium.statuspage.io/?source=post_page-----f657a6bb4bb5--------------------------------)
  - [Blog](https://blog.medium.com/?source=post_page-----f657a6bb4bb5--------------------------------)
  - [Text to speech](https://speechify.com/medium?source=post_page-----f657a6bb4bb5--------------------------------)