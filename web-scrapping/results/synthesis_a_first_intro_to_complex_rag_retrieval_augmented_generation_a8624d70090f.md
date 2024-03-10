### Article Overview
- **Title**: A first intro to Complex RAG (Retrieval Augmented Generation)
- **Author and Date**: Chia Jeng Yang, Dec 14, 2023
- **Publication**: Enterprise RAG
- **Reading Time**: 11 min read
- **Link**: [Article Link](https://medium.com/enterprise-rag/a-first-intro-to-complex-rag-retrieval-augmented-generation-a8624d70090f)
### Introduction
The article by Chia Jeng Yang, published on December 14, 2023, in Enterprise RAG, provides a technical exploration of Retrieval Augmented Generation (RAG) systems. It delves into the intricacies of document preparation, chunking, query augmentation, document hierarchies, multi-hop reasoning, and knowledge graphs. The article also touches upon the unsolved problems and opportunities within the RAG infrastructure space and introduces infrastructure solutions for building RAG pipelines.
### Main Content
#### Document Preparation and Information Retrieval
The initial challenge in building a RAG system is the preparation of documents for storage and information extraction. The article emphasizes the distinction between "relevance" and "similarity" in effective information retrieval. Relevance pertains to the connectedness of ideas, while similarity is about word matching. Sophisticated tooling is required to retrieve relevant content beyond semantically close content identified by vector database queries.
#### Chunking Strategy
Chunking is the segmentation of text into small, meaningful units. The article discusses the balance required in determining the optimal chunk size to ensure essential information is captured without compromising speed. Overlapping chunks are suggested as a method to balance the constraints of larger and smaller chunks. However, this strategy assumes that all necessary information is contained within a single document, which may not always be the case.
#### Document Hierarchies
To improve information retrieval, the article introduces the concept of document hierarchies, likening them to a table of contents for a RAG system. They organize chunks in a structured manner, allowing for efficient retrieval of relevant data. Document hierarchies are particularly useful in cases where documents follow a similar format but contain different specific information, such as country-specific HR policies within a company.
#### Knowledge Graphs
Knowledge graphs are presented as a deterministic framework for mapping relationships between concepts and entities. They can enforce consistency in information retrieval and reduce hallucinations by providing a structured approach to answering questions. The article provides an example of how knowledge graphs can be used to map document hierarchies and guide the LLM in retrieving and comparing information from specific documents.
#### Query Augmentation
The article discusses query augmentation as a solution to poorly phrased questions. It highlights the domain-specific nature of language and the importance of providing context to maximize relevancy. Examples are given to illustrate how company or domain-specific context can be added to queries to distinguish between similar terms.
#### Query Planning
Query Planning involves generating sub-questions to contextualize and generate comprehensive answers. The article describes the use of sub-questions in a RAG system and acknowledges the challenges in accuracy when relying solely on LLMs for reasoning. It suggests the use of external reasoning structures and rules to guide the LLM in answering questions.
#### Multi-hop Reasoning
The article briefly mentions multi-hop retrieval within complex RAG systems and the challenges that arise in building them. It provides an example from the medical field to illustrate the steps involved in a RAG system's process, from query planning to augmented response.
#### Future Directions
The article concludes by discussing short-term opportunities for enhancing cost efficiency and accuracy in RAG systems and long-term opportunities for building and storing semantic reasoning in a scalable way. It hints at future articles that will review specific implementation techniques of knowledge graphs for complex RAG and multi-hop processes.
### Conclusion
Chia Jeng Yang's article provides a comprehensive introduction to the technical aspects of RAG systems, covering the importance of document preparation, the nuances of chunking, the organization of data through document hierarchies, the deterministic nature of knowledge graphs, and the intricacies of query planning and augmentation. It also outlines the challenges and opportunities in the field, setting the stage for further exploration of knowledge graphs and multi-hop reasoning in future discussions.
#### Links:
  - [Open in app - rsci.app.link](https://rsci.app.link/?%24canonical_url=https%3A%2F%2Fmedium.com%2Fp%2Fa8624d70090f&%7Efeature=LoOpenInAppButton&%7Echannel=ShowPostUnderCollection&source=---two_column_layout_nav----------------------------------)
  - [medium.com](https://medium.com/enterprise-rag?source=post_page-----a8624d70090f--------------------------------)
  - [capturing all essential information without sacrif](https://blog.llamaindex.ai/evaluating-the-ideal-chunk-size-for-a-rag-system-using-llamaindex-6207e5d3fec5)
  - [Overlapping chunks - betterprogramming.pub](https://betterprogramming.pub/getting-started-with-llamaindex-part-2-a66618df3cd)
  - [sub-questions+docs.llamaindex.ai en stable example](https://docs.llamaindex.ai/en/stable/examples/agent/openai_agent_query_plan.html)
  - [implemented the example - github.com](https://github.com/pchunduri6/rag-demystified/blob/main/llama_index_baseline.py)
  - [Pramod Chunduri on building Advanced RAG pipelines](https://github.com/pchunduri6/rag-demystified)
  - [article+www.linkedin.com pulse multi-hop-question-](https://www.linkedin.com/pulse/multi-hop-question-answering-llms-knowledge-graphs-wisecube/)
  - [https://docs.llamaindex.ai/en/latest/getting_start](https://docs.llamaindex.ai/en/latest/getting_started/concepts.html#)
  - [Status+medium.statuspage.io ?source=post_page-----](https://medium.statuspage.io/?source=post_page-----a8624d70090f--------------------------------)
  - [Text to speech - speechify.com](https://speechify.com/medium?source=post_page-----a8624d70090f--------------------------------)