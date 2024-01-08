# Synthesis of "A Cheat Sheet and Some Recipes For Building Advanced RAG"
## Article Metadata
- **Title:** A Cheat Sheet and Some Recipes For Building Advanced RAG
- **Author:** Andrei
- **Publication Date:** Published 2 days ago from the knowledge cutoff date
- **Reading Time:** 7 min read
- **Publication Outlet:** LlamaIndex Blog
- **Article Link:** [A Cheat Sheet and Some Recipes For Building Advanced RAG](https://blog.llamaindex.ai/a-cheat-sheet-and-some-recipes-for-building-advanced-rag-803a9d94c41b)
## Introduction
The article begins by addressing the audience's potential interest in entering the Retrieval-Augmented Generation (RAG) field, either as newcomers or as developers looking to advance their existing basic RAG systems. The author aims to provide guidance and a mental model for building sophisticated RAG systems, drawing inspiration from a recent survey paper by Gao, Yunfan, et al., titled "Retrieval-Augmented Generation for Large Language Models: A Survey" published in 2023.
## Main Concepts
### Definition of RAG
RAG is defined as a system that involves three main components:
1. **Retrieval Component:** Fetches documents from an external knowledge database.
2. **External Knowledge Database:** The source of information for the retrieval process.
3. **Generation Component:** A Large Language Model (LLM) that generates responses based on the user's query and the retrieved documents.
### Success Requirements for RAG Systems
The article outlines two high-level requirements for a RAG system to be considered successful:
1. The system must provide useful answers.
2. The system must provide relevant answers to user questions.
Building advanced RAG systems involves applying sophisticated techniques to the Retrieval or Generation components to meet these requirements.
## Advanced Techniques for RAG Systems
### Techniques for the First Success Requirement
#### LlamaIndex Chunk Size Optimization Recipe
- **Notebook Guide:** A guide is mentioned but not linked directly in the excerpt.
#### Structured External Knowledge
- The necessity for structured external knowledge is highlighted for complex scenarios, allowing for recursive retrievals or routed retrieval.
#### LlamaIndex Recursive Retrieval Recipe
- **Notebook Guide:** A guide is mentioned but not linked directly in the excerpt.
### Techniques for the Second Success Requirement
#### LlamaIndex Information Compression Recipe
- **Notebook Guide:** A guide is mentioned but not linked directly in the excerpt.
#### Result Re-Rank
- The article discusses the "Lost in the Middle" phenomenon affecting LLMs and suggests re-ranking retrieved documents before they are passed to the Generation component.
#### LlamaIndex Re-Ranking For Better Generation Recipe
- **Notebook Guide:** A guide is mentioned but not linked directly in the excerpt.
### Techniques Addressing Both Requirements
#### LlamaIndex Generator-Enhanced Retrieval Recipe
- **Notebook Guide:** A guide is mentioned but not linked directly in the excerpt.
#### Iterative Retrieval-Generator RAG
- Multi-step reasoning is presented as a method for complex cases requiring sophisticated responses.
#### LlamaIndex Iterative Retrieval-Generator Recipe
- **Notebook Guide:** A guide is mentioned but not linked directly in the excerpt.
## Evaluation of RAG Systems
The importance of evaluating RAG systems is underscored, referencing the seven measurement aspects indicated by Gao, Yunfan, et al. in their survey paper. The llama-index library offers several evaluation abstractions and integrations to RAGAs for builders to assess their RAG systems.
### Evaluation Notebook Guides
- A few evaluation notebook guides are mentioned but not linked directly in the excerpt.
## Conclusion
The blog post concludes with the hope that readers will feel more equipped and confident in applying sophisticated techniques to build advanced RAG systems.
## External Links and References
- **Survey Paper:** [Retrieval-Augmented Generation for Large Language Models: A Survey](https://arxiv.org/pdf/2312.10997.pdf) by Gao, Yunfan, et al. 2023.
- **GitHub Repository:** [llama_index](https://github.com/run-llama/llama_index)
  - **Parameter Optimizer Notebook Guide:** [param_optimizer.ipynb](https://github.com/run-llama/llama_index/blob/main/docs/examples/param_optimizer/param_optimizer.ipynb)
  - **Retriever Evaluation Notebook Guide:** [retriever_eval.ipynb](https://github.com/run-llama/llama_index/blob/main/docs/examples/evaluation/retrieval/retriever_eval.ipynb)
- **Author's LinkedIn Profile:** [Andrei's LinkedIn](https://ca.linkedin.com/in/nerdai)
## Additional Notes
The synthesis has captured all the information provided in the excerpt. However, it should be noted that some notebook guides mentioned in the article are referenced without direct links. The synthesis assumes these guides are accessible through the provided GitHub repository or other means not specified in the excerpt.