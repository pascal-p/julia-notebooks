# Advanced RAG and the 3 Types of Recursive Retrieval
## Introduction
- **Title**: Advanced RAG and the 3 types of Recursive Retrieval
- **Author and Date**: Chia Jeng Yang, January 31, 2024
- **Publication**: Enterprise RAG
- **Reading Time**: 7 min read
## Main Content
This article explores the utilization of Recursive or Iterative Retrieval in the development of self-learning RAG (Retrieval-Augmented Generation) systems. These systems are designed to learn over time and deeply explore unstructured data, autonomously or directed towards specific knowledge areas. Recursive retrieval involves applying a query across smaller chunks of the corpus, with intermediate results fed into subsequent steps and aggregation to combine outputs. This process enables an LLM (Large Language Model) agent to continuously scan for relevant sentences and paragraphs, retrieve them, and then combine and examine the answer for any references to other concepts or pages, hinting at the final answer.
### Implications of Recursive or Iterative Retrieval
1. **Consistent and Exhaustive Retrieval**: Acts as a memory base for future reference.
2. **Multi-hop Retrieval**: Allows for exploration across multiple documents.
3. **Increased LLM Accuracy**: Ties unstructured data input to tangible accuracy improvements.
### Types of Recursive Retrieval
Recursive retrieval can be classified into three main approaches:
1. **Page-Based Recursive Retrieval**: Focuses on tracking and diving deeper into subsequent pages referenced in the initial query. This approach is particularly useful for navigating highly technical manuals in manufacturing industries, where page references guide the retrieval process. However, it faces limitations when references are not present or consistent, necessitating a knowledge graph for concept grouping across unstructured data.
2. **Information-Centric Recursive Retrieval**: Centers around a fixed seed node or concept, allowing the LLM to discover key relationships for exploration. This method is advantageous for focusing on specific relationships and expanding the knowledge graph iteratively, making it directionally smarter over time. It serves as a memory base for recursive or multi-hop retrieval, facilitating information retrieval over time and across documents.
3. **Concept-Centric Recursive Retrieval**: Involves retrieval exercises for concepts, where the LLM decides on top-level nodes and n+2 nodes based on their potential relevance to the question. This approach requires controlling the LLM to ensure relevance and employing prompt engineering or pre-processing work to map relevant concepts in a contextual dictionary.
### Conclusion
The article highlights the significant potential of Recursive or Iterative Retrieval in enhancing the capabilities of RAG systems. By employing page-based, information-centric, or concept-centric retrieval methods, developers can create self-learning systems that efficiently navigate and extract knowledge from unstructured data. The exploration of these retrieval methods opens up new possibilities for developing more intelligent and responsive RAG systems.
#### Links:
  - [Open in app - rsci.app.link](https://rsci.app.link/?%24canonical_url=https%3A%2F%2Fmedium.com%2Fp%2Fcdd0fa52e1ba&%7Efeature=LoOpenInAppButton&%7Echannel=ShowPostUnderCollection&source=---two_column_layout_nav----------------------------------)
  - [medium.com](https://medium.com/enterprise-rag?source=post_page-----cdd0fa52e1ba--------------------------------)
  - [medium.statuspage.io](https://medium.statuspage.io/?source=post_page-----cdd0fa52e1ba--------------------------------)
  - [speechify.com](https://speechify.com/medium?source=post_page-----cdd0fa52e1ba--------------------------------)