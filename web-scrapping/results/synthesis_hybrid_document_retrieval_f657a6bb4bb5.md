# Hybrid Document Retrieval
## Article Overview
- **Title**: Hybrid Document Retrieval
- **Author**: Isabelle Nguyen
- **Publication Date**: August 25, 2023
- **Published In**: deepset-ai
- **Reading Time**: 6 min read
## Introduction
The article "Hybrid Document Retrieval" by Isabelle Nguyen, published on August 25, 2023, in deepset-ai, explores the concept of combining different document retrieval methods to enhance the effectiveness of extracting relevant documents from a corpus. The author discusses the advantages and limitations of both keyword-based and semantic embedding-based approaches and introduces the idea of a hybrid retrieval system that leverages the strengths of both methods.
## Document Retrieval and Its Importance
Document retrieval is defined as the process of finding relevant documents from a large corpus in response to a user's query. The article emphasizes the importance of document retrieval in large-scale NLP systems, where it is impractical to run language models on the entire corpus due to resource and time constraints. Retrievers are presented as a solution, pre-selecting documents for further processing in tasks such as extractive question answering, generative AI, or summarization.
## Types of Retrievers
Retrievers are categorized into two main types:
### Sparse Retrievers
- **Characteristics**: Sparse retrievers generate long vectors with many zeroes, corresponding to the size of the vocabulary. They are lexical, meaning they can only match words that are part of the vocabulary.
- **Common Algorithm**: BM25, an advancement over Tf-Idf, is the most commonly used sparse retrieval algorithm today.
- **Advantages**: No training required, making them language- and domain-agnostic.
### Dense Retrievers
- **Characteristics**: Dense retrievers require data and training to produce shorter, semantic feature-based vectors.
- **Training**: The language model learns to embed documents as vectors from the data.
- **Limitations**: Performance can be poor on data that is outside the domain of the training data.
## Combining Retrievers
The article proposes combining dense and sparse retrievers to create a hybrid retrieval pipeline, which can be easily set up using a modular framework like Haystack.
### Hybrid Retrieval Pipeline in Haystack
Haystack's modular pipelines and nodes facilitate the customization of retrieval systems. A hybrid retrieval pipeline can include two retriever nodes and a `JoinDocuments` node to merge the output from both retrievers. The author describes several methods for joining the results:
#### Concatenation
- **Description**: Documents are appended to the final results list, without concern for order.
- **Use Case**: Suitable for pipelines where all results are used, such as extractive question answering.
#### Reciprocal Rank Fusion (RRF)
- **Description**: Reranks documents, prioritizing those appearing in both results lists.
- **Use Case**: Useful when the order of results is important.
#### Merging
- **Description**: Documents are ranked according to the scores from the retrievers.
- **Use Case**: Applicable when combining documents from similar retrievers, not ideal for hybrid retrieval.
### Intermediate Ranking Step
An intermediate ranking step can be added after merging documents to further refine the order of the results. The `SentenceTransformersRanker` node is mentioned as a powerful tool for this purpose, capable of determining the relevance of a document to a given query.
## Conclusion
The article concludes by endorsing Haystack as a preferred framework for developers to build customizable natural language search systems. It invites readers to join the Haystack community for support and discussions on open-source NLP and the latest language models.
## Author Information
- **Written by**: Isabelle Nguyen
- **Followers**: 17
- **Editor for**: deepset-ai
The article does not contain any code snippets to extract.
#### Links:
  - [Open in app](https://rsci.app.link/?%24canonical_url=https%3A%2F%2Fmedium.com%2Fp%2Ff657a6bb4bb5&%7Efeature=LoOpenInAppButton&%7Echannel=ShowPostUnderCollection&source=---two_column_layout_nav----------------------------------)
  - [medium.com](https://medium.com/deepset-ai?source=post_page-----f657a6bb4bb5--------------------------------)
  - [Haystack](https://github.com/deepset-ai/haystack)
  - [Haystack](https://github.com/deepset-ai/haystack/tree/main)
  - [Status](https://medium.statuspage.io/?source=post_page-----f657a6bb4bb5--------------------------------)
  - [Blog](https://blog.medium.com/?source=post_page-----f657a6bb4bb5--------------------------------)
  - [Text to speech](https://speechify.com/medium?source=post_page-----f657a6bb4bb5--------------------------------)