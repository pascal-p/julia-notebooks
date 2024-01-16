### Article Analysis
#### Article Details
- **Title**: Boosting RAG: Picking the Best Embedding & Reranker models
- **Author**: Ravi Theja
- **Publication Date**: Nov 3, 2023
- **Publication**: LlamaIndex Blog
- **Reading Time**: 7 min read
- **Link**: [Boosting RAG Article](https://blog.llamaindex.ai/boosting-rag-picking-the-best-embedding-reranker-models-42d079022e83)
#### Introduction
The article discusses the process of enhancing Retrieval Augmented Generation (RAG) pipelines by selecting the most effective combination of embedding and reranker models. The author, Ravi Theja, presents an evaluation using the Retrieval Evaluation module from LlamaIndex to determine the best mix for optimal retrieval performance. The article includes an update on the pooling method for Jina AI embeddings, which now uses mean pooling, and presents updated results for the JinaAI-v2-base-en model with different rerankers.
#### Metrics for Retrieval Evaluation
The evaluation of retrieval systems is based on two primary metrics:
- **Hit Rate**: The proportion of queries where the correct answer is within the top-k retrieved documents.
- **Mean Reciprocal Rank (MRR)**: The average of the reciprocals of the ranks of the highest-placed relevant document for each query.
#### Experimental Setup
The experiment involves the following steps:
1. **Setting Up the Environment**: Installation of necessary packages.
   ```shell
   !pip install llama-index sentence-transformers cohere anthropic voyageai protobuf pypdf
   ```
2. **Setting Up the Keys**: Configuration of API keys for various services.
   ```python
   openai_api_key = 'YOUR OPENAI API KEY'
   cohere_api_key = 'YOUR COHEREAI API KEY'
   anthropic_api_key = 'YOUR ANTHROPIC API KEY'
   openai.api_key = openai_api_key
   ```
3. **Downloading Data**: Retrieval of the Llama2 paper for the experiment.
   ```shell
   !wget --user-agent "Mozilla" "https://arxiv.org/pdf/2307.09288.pdf" -O "llama2.pdf"
   ```
4. **Loading Data**: Parsing the downloaded paper and converting it to nodes with a chunk size of 512.
   ```python
   documents = SimpleDirectoryReader(input_files=["llama2.pdf"]).load_data()
   node_parser = SimpleNodeParser.from_defaults(chunk_size=512)
   nodes = node_parser.get_nodes_from_documents(documents)
   ```
5. **Generating Question-Context Pairs**: Using an Anthropic LLM to generate question-context pairs to remove bias in the evaluation.
   ```python
   # Prompt to generate questions
   qa_generate_prompt_tmpl = """\
   Context information is below.
   ---------------------
   {context_str}
   ---------------------
   Given the context information and not prior knowledge.
   generate only questions based on the below query.
   You are a Professor. Your task is to setup \
   {num_questions_per_chunk} questions for an upcoming \
   quiz/examination. The questions should be diverse in nature \
   across the document. The questions should not contain options, not start with Q1/ Q2. \
   Restrict the questions to the context information provided.\
   """
   ```
   ```python
   llm = Anthropic(api_key=anthropic_api_key)
   qa_dataset = generate_question_context_pairs(
   nodes, llm=llm, num_questions_per_chunk=2
   )
   ```
6. **Filtering the Dataset**: Cleaning the dataset to remove certain phrases.
   ```python
   # function to clean the dataset
   def filter_qa_dataset(qa_dataset):
   """
   Filters out queries from the qa_dataset that contain certain phrases and the corresponding
   entries in the relevant_docs, and creates a new EmbeddingQAFinetuneDataset object with
   the filtered data.
   :param qa_dataset: An object that has 'queries', 'corpus', and 'relevant_docs' attributes.
   :return: An EmbeddingQAFinetuneDataset object with the filtered queries, corpus and relevant_docs.
   """
   # Extract keys from queries and relevant_docs that need to be removed
   queries_relevant_docs_keys_to_remove = {
   k for k, v in qa_dataset.queries.items()
   if 'Here are 2' in v or 'Here are two' in v
   }
   # Filter queries and relevant_docs using dictionary comprehensions
   filtered_queries = {
   k: v for k, v in qa_dataset.queries.items()
   if k not in queries_relevant_docs_keys_to_remove
   }
   filtered_relevant_docs = {
   k: v for k, v in qa_dataset.relevant_docs.items()
   if k not in queries_relevant_docs_keys_to_remove
   }
   # Create a new instance of EmbeddingQAFinetuneDataset with the filtered data
   return EmbeddingQAFinetuneDataset(
   queries=filtered_queries,
   corpus=qa_dataset.corpus,
   relevant_docs=filtered_relevant_docs
   )
   # filter out pairs with phrases `Here are 2 questions based on provided context`
   qa_dataset = filter_qa_dataset(qa_dataset)
   ```
7. **Custom Retriever**: Creation of a custom retriever that combines an embedding model and a reranker.
   ```python
   embed_model = OpenAIEmbedding()
   service_context = ServiceContext.from_defaults(llm=None, embed_model = embed_model)
   vector_index = VectorStoreIndex(nodes, service_context=service_context)
   vector_retriever = VectorIndexRetriever(index=vector_index, similarity_top_k = 10)
   ```
   ```python
   class CustomRetriever(BaseRetriever):
   """Custom retriever that performs both Vector search and Knowledge Graph search"""
   def __init__(
   self,
   vector_retriever: VectorIndexRetriever,
   ) -> None:
   """Init params."""
   self._vector_retriever = vector_retriever
   def _retrieve(self, query_bundle: QueryBundle) -> List[NodeWithScore]:
   """Retrieve nodes given query."""
   retrieved_nodes = self._vector_retriever.retrieve(query_bundle)
   if reranker != 'None':
   retrieved_nodes = reranker.postprocess_nodes(retrieved_nodes, query_bundle)
   else:
   retrieved_nodes = retrieved_nodes[:5]
   return retrieved_nodes
   async def _aretrieve(self, query_bundle: QueryBundle) -> List[NodeWithScore]:
   """Asynchronously retrieve nodes given query.
   Implemented by the user.
   """
   return self._retrieve(query_bundle)
   async def aretrieve(self, str_or_query_bundle: QueryType) -> List[NodeWithScore]:
   if isinstance(str_or_query_bundle, str):
   str_or_query_bundle = QueryBundle(str_or_query_bundle)
   return await self._aretrieve(str_or_query_bundle)
   custom_retriever = CustomRetriever(vector_retriever)
   ```
8. **Evaluation**: Computing MRR and Hit Rate metrics for the custom retriever.
   ```python
   retriever_evaluator = RetrieverEvaluator.from_metric_names(
   ["mrr", "hit_rate"], retriever=custom_retriever
   )
   eval_results = await retriever_evaluator.aevaluate_dataset(qa_dataset)
   ```
#### Results and Analysis
The evaluation tested various embedding models and rerankers. The models considered include OpenAI Embedding, Voyage Embedding, CohereAI Embedding (v2.0/ v3.0), Jina Embeddings (small/ base), BAAI/bge-large-en, and Google PaLM Embedding. Rerankers tested include CohereAI, bge-reranker-base, and bge-reranker-large.
The results showed that:
- **OpenAI** and **JinaAI** embeddings, especially when paired with **CohereRerank** or **bge-reranker-large**, performed exceptionally well.
- **Cohere** v3.0 embeddings outperformed v2.0 and showed significant improvement with native **CohereRerank**.
- **Voyage** and **Google-PaLM** embeddings also demonstrated strong performance, particularly when paired with **CohereRerank**.
- Rerankers, especially **CohereRerank** and **bge-reranker-large**, consistently enhanced performance across all embeddings.
#### Conclusions
The study concludes that:
- The right combination of embeddings and rerankers is crucial for optimal retriever performance.
- **OpenAI** and **JinaAI-Base** embeddings, paired with **CohereRerank** or **bge-reranker-large**, set the standard for hit rate and MRR.
- Rerankers play a key role in improving search results, with **CohereRerank** and **bge-reranker-large** showing the most significant impact.
- The initial choice of embedding is critical, as even the best reranker cannot compensate for poor initial search results.
#### Additional Information
The author, Ravi Theja, is a writer for the LlamaIndex Blog and is involved in open-source work at Llama Index. The article encourages readers to follow along with the experiment using a provided Google Colab Notebook and to treat the results as estimates for their own data.
#### External Links and References
The article contains numerous external links, including links to the LlamaIndex Blog, Medium, Cohere, Jina AI, BAAI, and various tags on Medium. These links provide additional context, resources, and information related to the topic of the article.