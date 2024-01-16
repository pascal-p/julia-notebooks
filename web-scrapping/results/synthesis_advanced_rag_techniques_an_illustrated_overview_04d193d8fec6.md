### Article Details
- **Title**: Advanced RAG Techniques: an Illustrated Overview
- **Author**: IVAN ILIN
- **Publication Date**: December 17, 2023
- **Reading Time**: 19 minutes
- **Publication**: Towards AI
- **Link**: [Advanced RAG Techniques: an Illustrated Overview](https://pub.towardsai.net/advanced-rag-techniques-an-illustrated-overview-04d193d8fec6)
### Introduction
The article provides a comprehensive study of advanced Retrieval Augmented Generation (RAG) techniques and algorithms, aiming to systematize various approaches. The author, Ivan Ilin, published the article on December 17, 2023, in Towards AI. It is intended to give an overview and explanation of available RAG algorithms and techniques without delving into implementation details, referencing extensive documentation and tutorials.
### RAG Concept
RAG combines search algorithms with Large Language Models (LLMs) to generate answers grounded in retrieved information. It has become the most popular architecture for LLM-based systems in 2023, with applications ranging from QA services to chat-with-your-data apps. The vector search area has also been influenced by RAG, with databases like Chroma, weavaite.io, and Pinecone building upon search indices like faiss and nmslib.
### Open Source Libraries
Two prominent open-source libraries for LLM-based pipelines and applications are LangChain and LlamaIndex, which have seen massive adoption in 2023.
### Naive RAG
The article begins with a description of a vanilla RAG case, which involves splitting texts into chunks, embedding them into vectors, indexing these vectors, and creating prompts for an LLM to answer user queries.
### Advanced RAG Techniques
The author provides an overview of advanced RAG techniques, including:
1. **Chunking & Vectorisation**: Documents are chunked and embedded into vectors for indexing. The LlamaIndex's NodeParser class offers advanced options for this process.
2. **Search Index**: The article discusses the importance of a proper search index, like faiss, nmslib, or annoy, for efficient retrieval.
3. **Hierarchical Indices**: For large databases, two-step searching using summaries and document chunks is efficient.
4. **Hypothetical Questions and HyDE**: Generating hypothetical questions for each chunk to improve search quality.
5. **Context Enrichment**: Retrieving smaller chunks for better search quality and adding surrounding context for LLM reasoning.
6. **Fusion Retrieval**: Combining keyword-based search with vector search for better retrieval results.
7. **Reranking & Filtering**: Refining retrieval results through filtering and reranking using various postprocessors.
8. **Query Transformations**: Using LLMs to modify user input to improve retrieval quality.
9. **Reference Citations**: Accurately back-referencing sources used to generate an answer.
10. **Chat Engine**: Supporting dialogue context for follow-up questions and user commands.
11. **Query Routing**: Decision making on what to do next given the user query.
12. **Agents in RAG**: Providing LLMs with tools and tasks to complete, including other agents.
13. **Response Synthesiser**: Generating an answer based on retrieved context and the initial user query.
14. **Encoder and LLM Fine-Tuning**: Fine-tuning models to improve embeddings quality and LLM's usage of context.
### Evaluation
The article mentions several frameworks for RAG systems performance evaluation, focusing on metrics like answer relevance, groundedness, and retrieved context relevance.
### Conclusion
The author concludes by highlighting the core algorithmic approaches to RAG and the main challenges for RAG systems, such as speed and answer relevance. The article also points to the potential of smaller LLMs in the future.
### References and Links
The article includes a comprehensive collection of links to various implementations, studies, and documentation related to RAG techniques. Some of the key references and links provided in the article are:
- [LangChain Documentation](https://python.langchain.com/docs/get_started/introduction)
- [LlamaIndex Documentation](https://docs.llamaindex.ai/en/stable/)
- [MTEB Leaderboard](https://huggingface.co/spaces/mteb/leaderboard)
- [LlamaIndex NodeParser Class](https://docs.llamaindex.ai/en/stable/api_reference/service_context/node_parser.html)
- [LlamaIndex Ingestion Pipeline Example](https://docs.llamaindex.ai/en/latest/module_guides/loading/ingestion_pipeline/root.html#)
- [HyDE Paper](http://boston.lti.cs.cmu.edu/luyug/HyDE/HyDE.pdf)
- [LangChain Ensemble Retriever](https://python.langchain.com/docs/modules/data_connection/retrievers/ensemble)
- [LlamaIndex Reciprocal Rerank Fusion](https://docs.llamaindex.ai/en/stable/examples/retrievers/reciprocal_rerank_fusion.html)
- [OpenAI Fine-Tuning API](https://docs.llamaindex.ai/en/stable/examples/finetuning/openai_fine_tuning.html)
- [RA-DIT Paper](https://arxiv.org/pdf/2310.01352.pdf)
- [Truelens Evaluation Framework](https://github.com/truera/trulens/tree/main)
- [LlamaIndex Evaluation Pipeline](https://github.com/run-llama/finetune-embedding/blob/main/evaluate.ipynb)
- [OpenAI Cookbook for RAG Evaluation](https://github.com/openai/openai-cookbook/blob/main/examples/evaluation/Evaluate_RAG_with_LlamaIndex.ipynb)
- [LangChain Evaluation Framework LangSmith](https://docs.smith.langchain.com)
- [LlamaIndex RAG Evaluator](https://github.com/run-llama/llama-hub/tree/dac193254456df699b4c73dd98cdbab3d1dc89b0/llama_hub/llama_packs/rag_evaluator)
The author's knowledge base with a collection of references can be accessed at [https://app.iki.ai/playlist/236](https://app.iki.ai/playlist/236). Ivan Ilin can be found on [LinkedIn](https://www.linkedin.com/in/ivan-ilin-/) and [Twitter](https://medium.com/@ivanilin_iki?source=post_page-----04d193d8fec6--------------------------------).