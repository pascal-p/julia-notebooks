### Article Overview
- **Title**: Improving Retrieval Performance in RAG Pipelines with Hybrid Search
- **Author**: Leonie Monigatti
- **Publication Date**: November 28, 2023
- **Published In**: Towards Data Science
- **Reading Time**: 8 minutes
- **Link**: [Improving Retrieval Performance in RAG Pipelines with Hybrid Search](https://towardsdatascience.com/improving-retrieval-performance-in-rag-pipelines-with-hybrid-search-c75203c2f2f5)
### Introduction
The article by Leonie Monigatti, published in Towards Data Science on November 28, 2023, discusses the challenges in achieving production-ready performance in Retrieval-Augmented Generation (RAG) pipelines. It emphasizes the Pareto Principle, where the last 20% of achieving full production readiness is the most challenging. The focus of the article is on enhancing the retrieval component of RAG pipelines using hybrid search, combining traditional keyword-based search with modern vector search to retrieve more relevant results.
### Understanding Hybrid Search
Hybrid search is a technique that merges two or more search algorithms to enhance the relevance of search results. It typically combines keyword-based search and vector search. Keyword-based search is precise but sensitive to typos and synonyms, while vector search is robust to typos and semantically aware but can miss essential keywords. The synergy of these methods in hybrid search aims to leverage their respective advantages for improved search outcomes.
#### Sparse and Dense Vector Representations
- Sparse embeddings example:
  ```code
  [0, 0, 0, 0, 0, 1, 0, 0, 0, 24, 3, 0, 0, 0, 0, ...]
  ```
- Dense embeddings example:
  ```code
  [0.634, 0.234, 0.867, 0.042, 0.249, 0.093, 0.029, 0.123, 0.234, ...]
  ```
#### Fusion of Search Results
The fusion process involves scoring and re-ranking the results from both keyword-based and vector searches. The scores are weighted by a parameter `alpha`, which influences the final hybrid score:
```code
hybrid_score = (1 - alpha) * sparse_score + alpha * dense_score
```
### Enhancing RAG Pipeline Performance with Hybrid Search
In a RAG pipeline, the relevance of the retrieved context is crucial for the language model to generate accurate answers. The `alpha` parameter, which balances keyword and semantic search, is treated as a hyperparameter to be tuned for optimal performance.
#### Code Example for Hybrid Search in LangChain
- Setting up a vector store as a retriever:
  ```python
  # Define and populate vector store
  # See details here https://towardsdatascience.com/retrieval-augmented-generation-rag-from-theory-to-langchain-implementation-4e9bd5f6a4f2
  vectorstore = ...
  # Set vectorstore as retriever
  retriever = vectorstore.as_retriever()
  ```
- Enabling hybrid search with `WeaviateHybridSearchRetriever`:
  ```python
  from langchain.retrievers.weaviate_hybrid_search import WeaviateHybridSearchRetriever
  retriever = WeaviateHybridSearchRetriever(
    alpha = 0.5,               # defaults to 0.5, which is equal weighting between keyword and semantic search
    client = client,           # keyword arguments to pass to the Weaviate client
    index_name = "LangChain",  # The name of the index to use
    text_key = "text",         # The name of the text key to use
    attributes = [],           # The attributes to return in the results
  )
  ```
### Use Cases for Hybrid Search
Hybrid search is particularly beneficial for platforms like Stack Overflow, where users need to search using natural language and also require exact phrase matching for specific terms. The article references Stack Overflow's implementation of semantic search using hybrid search to illustrate the practical application of this technique.
### Conclusion
The article concludes by summarizing the benefits of hybrid search in RAG pipelines, highlighting the importance of the `alpha` parameter in tuning the balance between keyword-based and semantic searches. It also provides a real-world example of hybrid search's effectiveness in improving search experiences while maintaining the necessity for exact keyword matching.
### Author Information and References
Leonie Monigatti is a Developer Advocate at Weaviate, an open-source vector database, and a writer for Towards Data Science. The article cites literature from Benham and Culpepper (2017) on rank fusion trade-offs and a case study from Stack Overflow on implementing semantic search.
### Additional Information
The article includes a disclaimer about the author's affiliation with Weaviate and provides links to her professional profiles on LinkedIn, Twitter, and Kaggle. It also invites readers to subscribe to get notified of new stories published by the author.
#### Links:
  - [Open in app](https://rsci.app.link/?%24canonical_url=https%3A%2F%2Fmedium.com%2Fp%2Fc75203c2f2f5&%7Efeature=LoOpenInAppButton&%7Echannel=ShowPostUnderCollection&source=---two_column_layout_nav----------------------------------)
  - [medium.com](https://medium.com/?source=---two_column_layout_nav----------------------------------)
  - [medium.com](https://medium.com/search?source=---two_column_layout_nav----------------------------------)
  - [medium.com](https://medium.com/@iamleonie?source=post_page-----c75203c2f2f5--------------------------------)
  - [Retrieval-Augmented Generation](https://medium.com/p/4e9bd5f6a4f2)
  - [started sharing their insights](https://medium.com/towards-data-science/the-untold-side-of-rag-addressing-its-challenges-in-domain-specific-searches-808956e3ecc8)
  - [BM25](https://en.wikipedia.org/wiki/Okapi_BM25)
  - [Transformers](https://huggingface.co/docs/transformers/index)
  - [Benham and Culpepper](https://rodgerbenham.github.io/bc17-adcs.pdf)
  - [retriever](https://python.langchain.com/docs/integrations/retrievers)
  - [Subscribe for free](https://medium.com/subscribe/@iamleonie)
  - [Get an email whenever Leonie Monigatti publishes.
Get an email whenever Leonie Monigatti publishes. By signing up, you will create a Medium account if you don’t already…
medium.com](https://medium.com/@iamleonie/subscribe?source=post_page-----c75203c2f2f5--------------------------------)
  - [LinkedIn](https://www.linkedin.com/in/804250ab/)
  - [Data Science](https://medium.com/tag/data-science?source=post_page-----c75203c2f2f5---------------data_science-----------------)
  - [Machine Learning](https://medium.com/tag/machine-learning?source=post_page-----c75203c2f2f5---------------machine_learning-----------------)
  - [Programming](https://medium.com/tag/programming?source=post_page-----c75203c2f2f5---------------programming-----------------)
  - [Rag](https://medium.com/tag/rag?source=post_page-----c75203c2f2f5---------------rag-----------------)
  - [Tips And Tricks](https://medium.com/tag/tips-and-tricks?source=post_page-----c75203c2f2f5---------------tips_and_tricks-----------------)
  - [linkedin.com/in/804250ab](http://linkedin.com/in/804250ab)
  - [Status](https://medium.statuspage.io/?source=post_page-----c75203c2f2f5--------------------------------)
  - [Blog](https://blog.medium.com/?source=post_page-----c75203c2f2f5--------------------------------)
  - [Text to speech](https://speechify.com/medium?source=post_page-----c75203c2f2f5--------------------------------)
  - [Teams](https://medium.com/business?source=post_page-----c75203c2f2f5--------------------------------)