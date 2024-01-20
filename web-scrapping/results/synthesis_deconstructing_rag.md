### Article Analysis: "Deconstructing RAG"
#### Article Details
- **Title**: Deconstructing RAG
- **Author and Date**: Deconstructing RAG, 7 min read, Nov 30, 2023
- **Link**: [Deconstructing RAG Article](https://blog.langchain.dev/deconstructing-rag)
#### Introduction
The article provides an in-depth analysis of Retrieval Augmented Generation (RAG) and its significance in the development of large language models (LLMs). It outlines the challenges faced by users due to the expanding landscape of RAG methods and offers a categorization of RAG concepts along with guides for each category. The main themes discussed are Query Transformations, Routing, Query Construction, Indexing, and Post-Processing.
#### Main Content
##### Context
- LLMs are compared to an operating system kernel, with a context window functioning like RAM, loaded with information from various data sources.
- Retrieval is a key component of this LLM "operating system," where information is retrieved and used in LLM output generation, a process known as RAG.
- RAG systems typically involve a user's question, retrieval of information from data sources, and passing this information to the LLM as part of the prompt.
##### Challenge
- The RAG method landscape has grown, causing confusion among users about where to start and how to approach the various methods.
- The authors have categorized RAG concepts into several themes and released guides for each to help users navigate the complexity.
##### Major RAG Themes
###### Query Transformations
- Query transformations aim to make retrieval robust to variability in user input, such as poorly worded questions.
- Approaches include:
  - **Query expansion**: Decomposes input into sub-questions for more focused retrieval.
  - **RAG fusion**: Ranks returned documents from sub-questions.
  - **Step-back prompting**: Generates higher-level questions to ground answer synthesis in broader concepts or principles.
###### Routing
- Routing addresses where data is stored and how incoming queries are directed to various datastores.
- LLMs can support dynamic query routing effectively.
###### Query Construction
- Query construction involves converting natural language queries into a syntax suitable for data retrieval from sources like relational or graph databases.
- Approaches include:
  - **Text-to-SQL**: Translates natural language into SQL requests.
  - **Text-to-Cypher**: Provides a visual way of matching patterns and relationships in graph databases.
  - **Text-to-metadata filters**: Translates natural language into structured queries with metadata filters for vectorstores.
###### Indexing
- Indexing involves designing the index for vectorstores, tuning parameters like chunk size and document embedding strategy.
- Approaches include:
  - **Chunk size**: Adjusting chunk size during document embedding to control information loaded into the context window.
  - **Document embedding strategy**: Decoupling what is embedded for retrieval from what is passed to the LLM for answer synthesis.
###### Post-Processing
- Post-processing combines retrieved documents, considering the limited size of the context window and the need to avoid redundancy.
- Approaches include:
  - **Re-ranking**: Reduces redundancy in retrieved documents.
  - **Classification**: Classifies documents based on content and chooses prompts accordingly.
##### Future Plans
- The authors plan to focus on integrating open source models into the RAG stack and developing benchmarks for evaluating RAG approaches and the incorporation of open source LLMs.
#### Conclusion
The article "Deconstructing RAG" provides a comprehensive overview of the current state of RAG in LLMs, addressing the challenges and presenting a structured approach to understanding and implementing RAG methods. It highlights the importance of query transformations, routing, query construction, indexing, and post-processing in the development of effective RAG systems. The authors also outline their future plans to further refine RAG strategies and evaluate their effectiveness.
#### Links:
  - [recent overview](https://www.youtube.com/watch?v=zjkBMFhNj_g&ref=blog.langchain.dev)
  - [Karpathy](https://x.com/karpathy/status/1727731541781152035?s=20&ref=blog.langchain.dev)
  - [require](https://www.youtube.com/watch?v=hhiLw5Q_UFg&ref=blog.langchain.dev)
  - [factual](https://github.com/openai/openai-cookbook/blob/main/examples/Question_answering_using_embeddings.ipynb?ref=blog.langchain.dev)
  - [recall](https://www.anyscale.com/blog/fine-tuning-is-for-form-not-facts?ref=blog.langchain.dev)
  - [here](https://smith.langchain.com/hub/rlm/rag-prompt?ref=blog.langchain.dev)
  - [ulti-query retriever](https://python.langchain.com/docs/modules/data_connection/retrievers/MultiQueryRetriever?ref=blog.langchain.dev)
  - [RAG fusion](https://github.com/langchain-ai/langchain/blob/master/cookbook/rag_fusion.ipynb?ref=blog.langchain.dev)
  - [Step-back prompting](https://github.com/langchain-ai/langchain/blob/master/cookbook/stepback-qa.ipynb?ref=blog.langchain.dev)
  - [paper](https://arxiv.org/pdf/2310.06117.pdf?ref=blog.langchain.dev)
  - [paper](https://arxiv.org/pdf/2305.14283.pdf?ref=blog.langchain.dev)
  - [re-writes user questions](https://github.com/langchain-ai/langchain/blob/master/cookbook/rewrite.ipynb?ref=blog.langchain.dev)
  - [WebLang](https://blog.langchain.dev/weblangchain/)
  - [this prompt](https://smith.langchain.com/hub/langchain-ai/weblangchain-search-query?ref=blog.langchain.dev&organizationId=1fa8b1f4-fcb9-4072-9aa9-983e35ad61b8)
  - [query transformations](https://blog.langchain.dev/query-transformations/)
  - [RAG strategies](https://blog.langchain.dev/applying-openai-rag/)
  - [here](https://python.langchain.com/docs/expression_language/how_to/routing?ref=blog.langchain.dev)
  - [here](https://python.langchain.com/docs/expression_language/cookbook/sql_db?ref=blog.langchain.dev)
  - [here](https://github.com/langchain-ai/langchain/tree/master/templates/sql-ollama?ref=blog.langchain.dev)
  - [here](https://github.com/langchain-ai/langchain/tree/master/templates/sql-llama2?ref=blog.langchain.dev)
  - [here](https://www.youtube.com/watch?v=MDxEXKkxf2Q&ref=blog.langchain.dev)
  - [open-source](https://github.com/pgvector/pgvector?ref=blog.langchain.dev)
  - [cookbook](https://github.com/langchain-ai/langchain/blob/master/cookbook/retrieval_in_sql.ipynb?ref=blog.langchain.dev)
  - [template](https://github.com/langchain-ai/langchain/tree/master/templates/sql-pgvector?ref=blog.langchain.dev)
  - [designed to provide a visual way of matching patte](https://blog.langchain.dev/using-a-knowledge-graph-to-implement-a-devops-rag-application/)
  - [here](https://github.com/langchain-ai/langchain/tree/master/templates/neo4j-cypher?ref=blog.langchain.dev)
  - [here](https://github.com/langchain-ai/langchain/tree/master/templates/neo4j-advanced-rag?ref=blog.langchain.dev)
  - [metadata filtering](https://docs.trychroma.com/usage-guide?ref=blog.langchain.dev#filtering-by-metadata)
  - [self-query retriever](https://python.langchain.com/docs/modules/data_connection/retrievers/self_query/?ref=blog.langchain.dev#constructing-from-scratch-with-lcel)
  - [template](https://github.com/langchain-ai/langchain/tree/master/templates/rag-self-query?ref=blog.langchain.dev)
  - [query construction](https://blog.langchain.dev/query-construction/)
  - [open source](https://github.com/langchain-ai/text-split-explorer?ref=blog.langchain.dev)
  - [Streamlit app](https://x.com/hwchase17/status/1689015952623771648?s=20&ref=blog.langchain.dev)
  - [multi-vector](https://blog.langchain.dev/semi-structured-multi-modal-rag/)
  - [parent-document](https://python.langchain.com/docs/modules/data_connection/retrievers/parent_document_retriever?ref=blog.langchain.dev)
  - [cookbook](https://github.com/langchain-ai/langchain/blob/master/cookbook/Semi_Structured_RAG.ipynb?ref=blog.langchain.dev)
  - [template](https://github.com/langchain-ai/langchain/tree/master/templates/rag-semi-structured?ref=blog.langchain.dev)
  - [multi-modal LLMs](https://openai.com/research/gpt-4v-system-card?ref=blog.langchain.dev)
  - [cookbook](https://github.com/langchain-ai/langchain/blob/master/cookbook/Multi_modal_RAG.ipynb?ref=blog.langchain.dev)
  - [@jaminball](https://twitter.com/jaminball?ref=blog.langchain.dev)
  - [cookbook](https://github.com/langchain-ai/langchain/blob/master/cookbook/multi_modal_RAG_chroma.ipynb?ref=blog.langchain.dev)
  - [OpenCLIP](https://github.com/mlfoundations/open_clip?ref=blog.langchain.dev)
  - [Cohere ReRank](https://python.langchain.com/docs/integrations/retrievers/cohere-reranker?ref=blog.langchain.dev)
  - [blog](https://towardsdatascience.com/forget-rag-the-future-is-rag-fusion-1147298d8ad1?ref=blog.langchain.dev)
  - [tagging](https://python.langchain.com/docs/modules/chains/how_to/openai_functions?ref=blog.langchain.dev)
  - [of](https://github.com/langchain-ai/langchain/tree/master/templates/extraction-openai-functions?ref=blog.langchain.dev)
  - [public datasets](https://blog.langchain.dev/public-langsmith-benchmarks/)