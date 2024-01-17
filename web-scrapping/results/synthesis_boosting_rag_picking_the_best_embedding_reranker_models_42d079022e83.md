### Article Overview
#### Title
Boosting RAG: Picking the Best Embedding & Reranker models
#### Author and Publication Date
Ravi Theja, November 3, 2023
#### Source
Published in LlamaIndex Blog
#### Link
[Boosting RAG: Picking the Best Embedding & Reranker models](https://blog.llamaindex.ai/boosting-rag-picking-the-best-embedding-reranker-models-42d079022e83)
### Introduction
The article by Ravi Theja, published on November 3, 2023, in the LlamaIndex Blog, discusses the optimization of Retrieval Augmented Generation (RAG) pipelines by selecting the most effective combination of embedding and reranker models. The author presents an evaluation using the LlamaIndex's Retrieval Evaluation module, focusing on two key metrics: Hit Rate and Mean Reciprocal Rank (MRR). The article also provides a practical guide, including code snippets, for setting up the evaluation environment and conducting the experiment.
### Understanding Metrics in Retrieval Evaluation
The article explains two primary metrics used to assess the retrieval system's performance:
- **Hit Rate**: This metric calculates the proportion of queries where the correct answer is found within the top-k retrieved documents, essentially measuring the frequency of accurate retrievals.
- **Mean Reciprocal Rank (MRR)**: MRR evaluates the accuracy of the system by considering the rank of the highest-placed relevant document for each query. It is the average of the reciprocals of these ranks across all queries.
### Setting Up the Environment
The article provides code to set up the necessary environment for the experiment:
```bash
!pip install llama-index sentence-transformers cohere anthropic voyageai protobuf pypdf
```
### Setting Up the Keys
API keys for various services are set up as follows:
```python
openai_api_key = 'YOUR OPENAI API KEY'
cohere_api_key = 'YOUR COHEREAI API KEY'
anthropic_api_key = 'YOUR ANTHROPIC API KEY'
openai.api_key = openai_api_key
```
### Download the Data
The Llama2 paper is used for the experiment, and the following command downloads it:
```bash
!wget --user-agent "Mozilla" "https://arxiv.org/pdf/2307.09288.pdf" -O "llama2.pdf"
```
### Load the Data
The data is loaded and parsed into nodes with a chunk size of 512:
```python
documents = SimpleDirectoryReader(input_files=["llama2.pdf"]).load_data()
node_parser = SimpleNodeParser.from_defaults(chunk_size=512)
nodes = node_parser.get_nodes_from_documents(documents)
```
### Generating Question-Context Pairs
A dataset of question-context pairs is created for evaluation, using a prompt template and the Anthropic LLM:
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
llm = Anthropic(api_key=anthropic_api_key)
qa_dataset = generate_question_context_pairs(
nodes, llm=llm, num_questions_per_chunk=2
)
```
### Filtering the Dataset
A function is provided to clean the dataset by filtering out unwanted phrases:
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
### Custom Retriever
A custom retriever is defined, combining an embedding model and a reranker:
```python
embed_model = OpenAIEmbedding()
service_context = ServiceContext.from_defaults(llm=None, embed_model = embed_model)
vector_index = VectorStoreIndex(nodes, service_context=service_context)
vector_retriever = VectorIndexRetriever(index=vector_index, similarity_top_k = 10)
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
### Evaluation
The evaluation is performed using the RetrieverEvaluator, computing MRR and Hit Rate metrics:
```python
retriever_evaluator = RetrieverEvaluator.from_metric_names(
  ["mrr", "hit_rate"], retriever=custom_retriever
)
eval_results = await retriever_evaluator.aevaluate_dataset(qa_dataset)
```
### Results and Analysis
The article presents a detailed analysis of the performance of various embedding models and rerankers. The key insights include:
- **Performance by Embedding**: Different embeddings show varying levels of improvement with rerankers. OpenAI and JinaAI-Base embeddings, in particular, demonstrate strong performance when paired with rerankers like CohereRerank and bge-reranker-large.
- **Impact of Rerankers**: Rerankers generally improve both hit rate and MRR across embeddings, with CohereRerank and bge-reranker-large often providing the best results.
- **Necessity of Rerankers**: The data underscores the importance of rerankers in enhancing search results, with nearly all embeddings benefiting from reranking.
- **Overall Superiority**: The combination of OpenAI or JinaAI-Base embeddings with CohereRerank or bge-reranker-large rerankers is identified as the most effective for achieving high hit rate and MRR.
### Conclusions
The article concludes that the right mix of embeddings and rerankers is crucial for optimizing retriever performance. OpenAI and JinaAI-Base embeddings, coupled with CohereRerank or bge-reranker-large rerankers, are recommended for achieving the best results in terms of hit rate and MRR. The importance of rerankers in improving search results is emphasized, and the article suggests that the foundation of a good initial search is key to the overall success of the retrieval system.
### Additional Information
The article includes links to various resources and encourages readers to follow along with the provided Google Colab Notebook for a hands-on experience. It also notes that the results are specific to the dataset and task used in the experiment and may vary with different data characteristics.
#### Links:
  - [Open in app](https://rsci.app.link/?%24canonical_url=https%3A%2F%2Fmedium.com%2Fp%2F42d079022e83&%7Efeature=LoOpenInAppButton&%7Echannel=ShowPostUnderCollection&source=---two_column_layout_nav----------------------------------)
  - [medium.com](https://medium.com/?source=---two_column_layout_nav----------------------------------)
  - [medium.com](https://medium.com/search?source=---two_column_layout_nav----------------------------------)
  - [ravidesetty.medium.com](https://ravidesetty.medium.com/?source=post_page-----42d079022e83--------------------------------)
  - [blog.llamaindex.ai](https://blog.llamaindex.ai/?source=post_page-----42d079022e83--------------------------------)
  - [Ravi Theja](https://ravidesetty.medium.com/?source=post_page-----42d079022e83--------------------------------)
  - [LlamaIndex Blog](https://blog.llamaindex.ai/?source=post_page-----42d079022e83--------------------------------)
  - [CohereAI Embedding](https://txt.cohere.com/introducing-embed-v3/)
  - [Jina Embeddings](https://huggingface.co/jinaai/jina-embeddings-v2-small-en)
  - [BAAI/bge-large-en](https://huggingface.co/BAAI/bge-large-en)
  - [CohereAI](https://txt.cohere.com/rerank/)
  - [bge-reranker-base](https://huggingface.co/BAAI/bge-reranker-base)
  - [bge-reranker-large](https://huggingface.co/BAAI/bge-reranker-large)
  - [Embedding](https://medium.com/tag/embedding?source=post_page-----42d079022e83---------------embedding-----------------)
  - [Llm](https://medium.com/tag/llm?source=post_page-----42d079022e83---------------llm-----------------)
  - [OpenAI](https://medium.com/tag/openai?source=post_page-----42d079022e83---------------openai-----------------)
  - [Search](https://medium.com/tag/search?source=post_page-----42d079022e83---------------search-----------------)
  - [Llamaindex](https://medium.com/tag/llamaindex?source=post_page-----42d079022e83---------------llamaindex-----------------)
  - [ravidesetty.medium.com](https://ravidesetty.medium.com/?source=post_page-----42d079022e83--------------------------------)
  - [blog.llamaindex.ai](https://blog.llamaindex.ai/?source=post_page-----42d079022e83--------------------------------)
  - [Written by
Ravi Theja](https://ravidesetty.medium.com/?source=post_page-----42d079022e83--------------------------------)
  - [LlamaIndex Blog](https://blog.llamaindex.ai/?source=post_page-----42d079022e83--------------------------------)
  - [Help](https://help.medium.com/hc/en-us?source=post_page-----42d079022e83--------------------------------)
  - [Status](https://medium.statuspage.io/?source=post_page-----42d079022e83--------------------------------)
  - [About](https://medium.com/about?autoplay=1&source=post_page-----42d079022e83--------------------------------)
  - [Careers](https://medium.com/jobs-at-medium/work-at-medium-959d1a85284e?source=post_page-----42d079022e83--------------------------------)
  - [Blog](https://blog.medium.com/?source=post_page-----42d079022e83--------------------------------)
  - [Text to speech](https://speechify.com/medium?source=post_page-----42d079022e83--------------------------------)
  - [Teams](https://medium.com/business?source=post_page-----42d079022e83--------------------------------)