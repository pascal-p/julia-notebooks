### Article Analysis
#### Article Details
- **Title**: Boosting RAG: Picking the Best Embedding & Reranker models
- **Author**: Ravi Theja
- **Publication Date**: November 3, 2023
- **Publication**: LlamaIndex Blog
- **Reading Time**: 7 minutes
- **Link**: [Boosting RAG Article](https://blog.llamaindex.ai/boosting-rag-picking-the-best-embedding-reranker-models-42d079022e83)
#### Introduction
The article discusses the process of enhancing Retrieval Augmented Generation (RAG) pipelines by selecting the most effective combination of embedding and reranker models. The author, Ravi Theja, presents an evaluation using the Retrieval Evaluation module from LlamaIndex to swiftly determine the best mix for optimal retrieval performance. The article includes an update on the pooling method for Jina AI embeddings, which now uses mean pooling, leading to improved Hit Rate and Mean Reciprocal Rank (MRR) metrics.
#### Understanding Metrics in Retrieval Evaluation
Two primary metrics are used to assess the retrieval system's efficacy:
- **Hit Rate**: The proportion of queries where the correct answer is found within the top-k retrieved documents.
- **Mean Reciprocal Rank (MRR)**: The average of the reciprocals of the ranks of the highest-placed relevant document for each query.
#### Experimental Setup
The experiment involves setting up the environment, downloading the Llama2 paper, and loading the data for evaluation. The data is parsed into nodes with a chunk size of 512. Question-context pairs are generated using an Anthropic LLM to remove bias in the evaluation of embeddings and rerankers.
##### Environment Setup
```bash
!pip install llama-index sentence-transformers cohere anthropic voyageai protobuf pypdf
```
##### API Keys Setup
```python
openai_api_key = 'YOUR OPENAI API KEY'
cohere_api_key = 'YOUR COHEREAI API KEY'
anthropic_api_key = 'YOUR ANTHROPIC API KEY'
openai.api_key = openai_api_key
```
##### Data Download
```bash
!wget --user-agent "Mozilla" "https://arxiv.org/pdf/2307.09288.pdf" -O "llama2.pdf"
```
##### Data Loading
```python
documents = SimpleDirectoryReader(input_files=["llama2.pdf"]).load_data()
node_parser = SimpleNodeParser.from_defaults(chunk_size=512)
nodes = node_parser.get_nodes_from_documents(documents)
```
##### Generating Question-Context Pairs
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
##### Filtering the Dataset
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
#### Custom Retriever
A custom retriever is created by combining an embedding model with a reranker. The `VectorIndexRetriever` is used as the base, and a reranker is applied to refine the results.
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
#### Evaluation
The retriever is evaluated using the MRR and Hit Rate metrics.
```python
retriever_evaluator = RetrieverEvaluator.from_metric_names(
    ["mrr", "hit_rate"], retriever=custom_retriever
)
eval_results = await retriever_evaluator.aevaluate_dataset(qa_dataset)
```
#### Results and Analysis
The evaluation tested various embedding models and rerankers, including OpenAI Embedding, Voyage Embedding, CohereAI Embedding, Jina Embeddings, BAAI/bge-large-en, Google PaLM Embedding, and rerankers like CohereAI, bge-reranker-base, and bge-reranker-large.
##### Performance by Embedding
- **OpenAI**: Strong performance with CohereRerank and bge-reranker-large.
- **bge-large**: Significant improvement with rerankers, especially CohereRerank.
- **llm-embedder**: Greatly benefits from reranking, particularly with CohereRerank.
- **Cohere**: Cohere v3.0 embeddings outperform v2.0 and improve metrics with CohereRerank.
- **Voyage**: Strong initial performance, further amplified by CohereRerank.
- **JinaAI**: Notable gains with bge-reranker-large and CohereRerank.
- **Google-PaLM**: Strong performance, with gains using CohereRerank.
##### Impact of Rerankers
- **WithoutReranker**: Baseline performance for each embedding.
- **bge-reranker-base**: Generally improves both hit rate and MRR.
- **bge-reranker-large**: Often offers the highest MRR for embeddings.
- **CohereRerank**: Consistently enhances performance across all embeddings.
##### Necessity of Rerankers
Rerankers are significant in refining search results, with nearly all embeddings benefiting from reranking, particularly CohereRerank.
##### Overall Superiority
The combinations of OpenAI + CohereRerank and JinaAI-Base + bge-reranker-large/CohereRerank emerge as top contenders.
#### Conclusions
The article concludes that OpenAI and JinaAI-Base embeddings, paired with CohereRerank/bge-reranker-large reranker, set the standard for hit rate and MRR. Rerankers, especially CohereRerank/bge-reranker-large, are crucial for improving MRR and making search results better. The right mix of embeddings and rerankers is essential for optimal retriever performance.
#### Author and Source Information
- **Author**: Ravi Theja, with 604 followers.
- **Source**: LlamaIndex Blog
#### Additional Links
- [Open in app](https://rsci.app.link/?%24canonical_url=https%3A%2F%2Fmedium.com%2Fp%2F42d079022e83&%7Efeature=LoOpenInAppButton&%7Echannel=ShowPostUnderCollection&source=---two_column_layout_nav----------------------------------)
- [CohereAI Embedding](https://txt.cohere.com/introducing-embed-v3/)
- [Jina Embeddings](https://huggingface.co/jinaai/jina-embeddings-v2-small-en)
- [BAAI/bge-large-en](https://huggingface.co/BAAI/bge-large-en)
- [CohereAI Rerankers](https://txt.cohere.com/rerank/)
- [bge-reranker-base](https://huggingface.co/BAAI/bge-reranker-base)
- [bge-reranker-large](https://huggingface.co/BAAI/bge-reranker-large)
- [Help](https://help.medium.com/hc/en-us?source=post_page-----42d079022e83--------------------------------)
- [Status](https://medium.statuspage.io/?source=post_page-----42d079022e83--------------------------------)
- [About](https://medium.com/about?autoplay=1&source=post_page-----42d079022e83--------------------------------)
- [Careers](https://medium.com/jobs-at-medium/work-at-medium-959d1a85284e?source=post_page-----42d079022e83--------------------------------)
- [Blog](https://blog.medium.com/?source=post_page-----42d079022e83--------------------------------)
- [Text to speech](https://speechify.com/medium?source=post_page-----42d079022e83--------------------------------)
- [Teams](https://medium.com/business?source=post_page-----42d079022e83--------------------------------)
#### Links:
  - [Open in app](https://rsci.app.link/?%24canonical_url=https%3A%2F%2Fmedium.com%2Fp%2F42d079022e83&%7Efeature=LoOpenInAppButton&%7Echannel=ShowPostUnderCollection&source=---two_column_layout_nav----------------------------------)
  - [...](https://medium.com/?source=---two_column_layout_nav----------------------------------)
  - [...](https://medium.com/search?source=---two_column_layout_nav----------------------------------)
  - [...](https://ravidesetty.medium.com/?source=post_page-----42d079022e83--------------------------------)
  - [...](https://blog.llamaindex.ai/?source=post_page-----42d079022e83--------------------------------)
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
  - [...](https://ravidesetty.medium.com/?source=post_page-----42d079022e83--------------------------------)
  - [...](https://blog.llamaindex.ai/?source=post_page-----42d079022e83--------------------------------)
  - [Written by
Ravi Theja](https://ravidesetty.medium.com/?source=post_page-----42d079022e83--------------------------------)
  - [604 Followers](https://ravidesetty.medium.com/followers?source=post_page-----42d079022e83--------------------------------)
  - [LlamaIndex Blog](https://blog.llamaindex.ai/?source=post_page-----42d079022e83--------------------------------)
  - [Help](https://help.medium.com/hc/en-us?source=post_page-----42d079022e83--------------------------------)
  - [Status](https://medium.statuspage.io/?source=post_page-----42d079022e83--------------------------------)
  - [About](https://medium.com/about?autoplay=1&source=post_page-----42d079022e83--------------------------------)
  - [Careers](https://medium.com/jobs-at-medium/work-at-medium-959d1a85284e?source=post_page-----42d079022e83--------------------------------)
  - [Blog](https://blog.medium.com/?source=post_page-----42d079022e83--------------------------------)
  - [Text to speech](https://speechify.com/medium?source=post_page-----42d079022e83--------------------------------)
  - [Teams](https://medium.com/business?source=post_page-----42d079022e83--------------------------------)