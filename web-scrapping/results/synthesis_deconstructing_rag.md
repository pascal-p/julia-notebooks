# Deconstructing RAG
## Article Overview
- **Title**: Deconstructing RAG
- **Author and date**: Deconstructing RAG, 7 min read, Nov 30, 2023
- **Link**: [Deconstructing RAG](https://blog.langchain.dev/deconstructing-rag)
## Main Content
### Context
The article begins by referencing a recent overview by Karpathy, which likens large language models (LLMs) to the kernel process of a new kind of operating system. In this analogy, LLMs have a context window similar to RAM in computers, which can be loaded with information from various data sources. This process of loading information into the context window for LLM output generation is known as retrieval augmented generation (RAG). RAG is crucial in LLM app development, especially for tasks that require factual recall, as it provides an easier alternative to complex fine-tuning.
RAG systems typically involve a user's question that prompts information retrieval from a data source, which is then passed directly to the LLM as part of the prompt.
### Challenge
The RAG landscape has grown significantly, causing confusion among users about the various approaches. The authors have categorized RAG concepts and released guides for each, aiming to clarify these methods and discuss future work.
### Major RAG Themes
#### Query Transformations
Query transformations are approaches that modify user input to improve retrieval, especially when dealing with poorly worded questions.
- **Query expansion**: Decomposes a question into sub-questions, each a narrower retrieval challenge. The multi-query retriever generates sub-questions, retrieves information, and returns the combined results. RAG fusion then ranks the returned documents.
- **Step-back prompting**: Generates a higher-level question to ground the answer synthesis in broader concepts.
- **Query re-writing**: Improves retrieval by re-writing poorly framed user questions.
- **Query compression**: Compresses chat history into a final question for retrieval in applications like WebLang.
#### Routing
Routing addresses where the data resides, which is often in various datastores in production settings. LLMs can support dynamic query routing effectively.
#### Query Construction
Query construction involves converting natural language into a query syntax for retrieval from databases or vectorstores.
- **Text-to-SQL**: Translates natural language into SQL requests, with open source LLMs proving effective at this task.
- **Text-to-Cypher**: Provides a natural language interface for graph databases using text-to-Cypher.
- **Text-to-metadata filters**: Translates natural language into structured queries with metadata filters for vectorstores.
#### Indexing
Indexing involves designing the index for vectorstores, with opportunities to tune parameters like chunk size and document embedding strategy.
- **Chunk size**: Affects how much information is loaded into the context window.
- **Document embedding strategy**: Decouples what is embedded for retrieval from what is passed to the LLM for answer synthesis.
#### Post-Processing
Post-processing combines the retrieved documents, considering the limited size of the context window.
- **Re-ranking**: Uses endpoints like Cohere ReRank for document compression and RAG-fusion for reciprocal rank fusion.
- **Classification**: Classifies each document based on content and chooses prompts based on that classification.
### Future Plans
The authors plan to focus on open source models and benchmarks. They will release templates showcasing the use of open source models in the RAG stack and expand public datasets for evaluating RAG challenges and the incorporation of open source LLMs.
### Links
The article includes a series of links to resources, papers, and templates related to the discussed RAG concepts and strategies.
## Conclusion
The article "Deconstructing RAG" provides a comprehensive overview of the current state of retrieval augmented generation (RAG) in the context of large language models. It addresses the challenges faced by users due to the expanding landscape of RAG methods and offers a structured categorization of major RAG themes, including query transformations, routing, query construction, indexing, and post-processing. The authors also outline their future plans to focus on open source solutions and benchmarks to further refine and evaluate RAG approaches.
#### Links:
  - [recent overview - www.youtube.com](https://www.youtube.com/watch?v=zjkBMFhNj_g&ref=blog.langchain.dev)
  - [Karpathy+x.com karpathy status 1727731541781152035](https://x.com/karpathy/status/1727731541781152035?s=20&ref=blog.langchain.dev)
  - [require+www.youtube.com watch?v=hhiLw5Q_UFg&ref=bl](https://www.youtube.com/watch?v=hhiLw5Q_UFg&ref=blog.langchain.dev)
  - [factual+github.com openai openai-cookbook blob mai](https://github.com/openai/openai-cookbook/blob/main/examples/Question_answering_using_embeddings.ipynb?ref=blog.langchain.dev)
  - [recall+www.anyscale.com blog fine-tuning-is-for-fo](https://www.anyscale.com/blog/fine-tuning-is-for-form-not-facts?ref=blog.langchain.dev)
  - [smith.langchain.com hub rlm rag-prompt?ref=blog.la](https://smith.langchain.com/hub/rlm/rag-prompt?ref=blog.langchain.dev)
  - [ulti-query retriever - python.langchain.com](https://python.langchain.com/docs/modules/data_connection/retrievers/MultiQueryRetriever?ref=blog.langchain.dev)
  - [RAG fusion - github.com](https://github.com/langchain-ai/langchain/blob/master/cookbook/rag_fusion.ipynb?ref=blog.langchain.dev)
  - [Step-back prompting - github.com](https://github.com/langchain-ai/langchain/blob/master/cookbook/stepback-qa.ipynb?ref=blog.langchain.dev)
  - [paper+arxiv.org pdf 2310.06117.pdf?ref=blog.langch](https://arxiv.org/pdf/2310.06117.pdf?ref=blog.langchain.dev)
  - [paper+arxiv.org pdf 2305.14283.pdf?ref=blog.langch](https://arxiv.org/pdf/2305.14283.pdf?ref=blog.langchain.dev)
  - [re-writes user questions - github.com](https://github.com/langchain-ai/langchain/blob/master/cookbook/rewrite.ipynb?ref=blog.langchain.dev)
  - [WebLang+blog.langchain.dev weblangchain](https://blog.langchain.dev/weblangchain/)
  - [this prompt - smith.langchain.com](https://smith.langchain.com/hub/langchain-ai/weblangchain-search-query?ref=blog.langchain.dev&organizationId=1fa8b1f4-fcb9-4072-9aa9-983e35ad61b8)
  - [query transformations - blog.langchain.dev](https://blog.langchain.dev/query-transformations/)
  - [RAG strategies - blog.langchain.dev](https://blog.langchain.dev/applying-openai-rag/)
  - [python.langchain.com docs expression_language how_](https://python.langchain.com/docs/expression_language/how_to/routing?ref=blog.langchain.dev)
  - [python.langchain.com docs expression_language cook](https://python.langchain.com/docs/expression_language/cookbook/sql_db?ref=blog.langchain.dev)
  - [github.com langchain-ai langchain tree master temp](https://github.com/langchain-ai/langchain/tree/master/templates/sql-ollama?ref=blog.langchain.dev)
  - [github.com langchain-ai langchain tree master temp](https://github.com/langchain-ai/langchain/tree/master/templates/sql-llama2?ref=blog.langchain.dev)
  - [www.youtube.com watch?v=MDxEXKkxf2Q&ref=blog.langc](https://www.youtube.com/watch?v=MDxEXKkxf2Q&ref=blog.langchain.dev)
  - [open-source+github.com pgvector pgvector?ref=blog.](https://github.com/pgvector/pgvector?ref=blog.langchain.dev)
  - [cookbook+github.com langchain-ai langchain blob ma](https://github.com/langchain-ai/langchain/blob/master/cookbook/retrieval_in_sql.ipynb?ref=blog.langchain.dev)
  - [template+github.com langchain-ai langchain tree ma](https://github.com/langchain-ai/langchain/tree/master/templates/sql-pgvector?ref=blog.langchain.dev)
  - [designed to provide a visual way of matching patte](https://blog.langchain.dev/using-a-knowledge-graph-to-implement-a-devops-rag-application/)
  - [github.com langchain-ai langchain tree master temp](https://github.com/langchain-ai/langchain/tree/master/templates/neo4j-cypher?ref=blog.langchain.dev)
  - [github.com langchain-ai langchain tree master temp](https://github.com/langchain-ai/langchain/tree/master/templates/neo4j-advanced-rag?ref=blog.langchain.dev)
  - [metadata filtering - docs.trychroma.com](https://docs.trychroma.com/usage-guide?ref=blog.langchain.dev#filtering-by-metadata)
  - [self-query retriever - python.langchain.com](https://python.langchain.com/docs/modules/data_connection/retrievers/self_query/?ref=blog.langchain.dev#constructing-from-scratch-with-lcel)
  - [template+github.com langchain-ai langchain tree ma](https://github.com/langchain-ai/langchain/tree/master/templates/rag-self-query?ref=blog.langchain.dev)
  - [query construction - blog.langchain.dev](https://blog.langchain.dev/query-construction/)
  - [open source - github.com](https://github.com/langchain-ai/text-split-explorer?ref=blog.langchain.dev)
  - [Streamlit app - x.com](https://x.com/hwchase17/status/1689015952623771648?s=20&ref=blog.langchain.dev)
  - [multi-vector+blog.langchain.dev semi-structured-mu](https://blog.langchain.dev/semi-structured-multi-modal-rag/)
  - [parent-document+python.langchain.com docs modules ](https://python.langchain.com/docs/modules/data_connection/retrievers/parent_document_retriever?ref=blog.langchain.dev)
  - [cookbook+github.com langchain-ai langchain blob ma](https://github.com/langchain-ai/langchain/blob/master/cookbook/Semi_Structured_RAG.ipynb?ref=blog.langchain.dev)
  - [template+github.com langchain-ai langchain tree ma](https://github.com/langchain-ai/langchain/tree/master/templates/rag-semi-structured?ref=blog.langchain.dev)
  - [multi-modal LLMs - openai.com](https://openai.com/research/gpt-4v-system-card?ref=blog.langchain.dev)
  - [cookbook+github.com langchain-ai langchain blob ma](https://github.com/langchain-ai/langchain/blob/master/cookbook/Multi_modal_RAG.ipynb?ref=blog.langchain.dev)
  - [@jaminball+twitter.com jaminball?ref=blog.langchai](https://twitter.com/jaminball?ref=blog.langchain.dev)
  - [cookbook+github.com langchain-ai langchain blob ma](https://github.com/langchain-ai/langchain/blob/master/cookbook/multi_modal_RAG_chroma.ipynb?ref=blog.langchain.dev)
  - [OpenCLIP+github.com mlfoundations open_clip?ref=bl](https://github.com/mlfoundations/open_clip?ref=blog.langchain.dev)
  - [Cohere ReRank - python.langchain.com](https://python.langchain.com/docs/integrations/retrievers/cohere-reranker?ref=blog.langchain.dev)
  - [blog+towardsdatascience.com forget-rag-the-future-](https://towardsdatascience.com/forget-rag-the-future-is-rag-fusion-1147298d8ad1?ref=blog.langchain.dev)
  - [tagging+python.langchain.com docs modules chains h](https://python.langchain.com/docs/modules/chains/how_to/openai_functions?ref=blog.langchain.dev)
  - [of+github.com langchain-ai langchain tree master t](https://github.com/langchain-ai/langchain/tree/master/templates/extraction-openai-functions?ref=blog.langchain.dev)
  - [public datasets - blog.langchain.dev](https://blog.langchain.dev/public-langsmith-benchmarks/)