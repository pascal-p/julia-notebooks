### Article Overview
- **Title**: A Cheat Sheet and Some Recipes For Building Advanced RAG
- **Author**: Andrei
- **Publication Date**: January 5
- **Published In**: LlamaIndex Blog
- **Reading Time**: 7 minutes
- **Main URL**: [LlamaIndex Blog Article](https://blog.llamaindex.ai/a-cheat-sheet-and-some-recipes-for-building-advanced-rag-803a9d94c41b)
### Introduction
The article provides a comprehensive guide for building advanced Retrieval-Augmented Generation (RAG) systems. It begins by discussing the motivations for RAG and then delves into various techniques and strategies to enhance basic RAG builds. The guide is inspired by a recent survey paper on RAG for Large Language Models.
### Basic RAG
Basic RAG involves three main components: a Retrieval component, an External Knowledge database, and a Generation component. The process includes retrieving documents from an external database and passing them along with the user's query to a Large Language Model (LLM) for response generation.
#### LlamaIndex Basic RAG Recipe
```python
from llama_index import SimpleDirectoryReader, VectorStoreIndex
# load data
documents = SimpleDirectoryReader(input_dir="...").load_data()
# build VectorStoreIndex that takes care of chunking documents
# and encoding chunks to embeddings for future retrieval
index = VectorStoreIndex.from_documents(documents=documents)
# The QueryEngine class is equipped with the generator
# and facilitates the retrieval and generation steps
query_engine = index.as_query_engine()
# Use your Default RAG
response = query_engine.query("A user's query")
```
### Success Requirements for RAG
Two high-level requirements are identified for a successful RAG system:
1. Retrieval must find the most relevant documents to a user query.
2. Generation must effectively use the retrieved documents to answer the user query.
### Advanced RAG
Advanced RAG involves applying sophisticated techniques to the Retrieval or Generation components to meet the success requirements. Techniques can address either one of the requirements independently or both simultaneously.
#### Advanced Techniques for Retrieval
1. **Chunk-Size Optimization**: Adjusting the chunk size of documents to optimize for context length limitations of LLMs.
##### LlamaIndex Chunk Size Optimization Recipe
```python
from llama_index import ServiceContext
from llama_index.param_tuner.base import ParamTuner, RunResult
from llama_index.evaluation import SemanticSimilarityEvaluator, BatchEvalRunner
# Recipe
# Perform hyperparameter tuning as in traditional ML via grid-search
# 1. Define an objective function that ranks different parameter combos
# 2. Build ParamTuner object
# 3. Execute hyperparameter tuning with ParamTuner.tune()
# 1. Define objective function
def objective_function(params_dict):
    chunk_size = params_dict["chunk_size"]
    docs = params_dict["docs"]
    top_k = params_dict["top_k"]
    eval_qs = params_dict["eval_qs"]
    ref_response_strs = params_dict["ref_response_strs"]
    # build RAG pipeline
    index = _build_index(chunk_size, docs)  # helper function not shown here
    query_engine = index.as_query_engine(similarity_top_k=top_k)
    # perform inference with RAG pipeline on a provided questions `eval_qs`
    pred_response_objs = get_responses(
        eval_qs, query_engine, show_progress=True
    )
    # perform evaluations of predictions by comparing them to reference
    # responses `ref_response_strs`
    evaluator = SemanticSimilarityEvaluator(...)
    eval_batch_runner = BatchEvalRunner(
        {"semantic_similarity": evaluator}, workers=2, show_progress=True
    )
    eval_results = eval_batch_runner.evaluate_responses(
        eval_qs, responses=pred_response_objs, reference=ref_response_strs
    )
    # get semantic similarity metric
    mean_score = np.array(
        [r.score for r in eval_results["semantic_similarity"]]
    ).mean()
    return RunResult(score=mean_score, params=params_dict)
# 2. Build ParamTuner object
param_dict = {"chunk_size": [256, 512, 1024]} # params/values to search over
fixed_param_dict = { # fixed hyperparams
    "top_k": 2,
    "docs": docs,
    "eval_qs": eval_qs[:10],
    "ref_response_strs": ref_response_strs[:10],
}
param_tuner = ParamTuner(
    param_fn=objective_function,
    param_dict=param_dict,
    fixed_param_dict=fixed_param_dict,
    show_progress=True,
)
# 3. Execute hyperparameter search
results = param_tuner.tune()
best_result = results.best_run_result
best_chunk_size = results.best_run_result.params["chunk_size"]
```
2. **Structured External Knowledge**: Creating a structured external knowledge base to allow for recursive retrievals or routed retrieval in complex scenarios.
##### LlamaIndex Recursive Retrieval Recipe
```python
from llama_index import SimpleDirectoryReader, VectorStoreIndex
from llama_index.node_parser import SentenceSplitter
from llama_index.schema import IndexNode
# Recipe
# Build a recursive retriever that retrieves using small chunks
# but passes associated larger chunks to the generation stage
# load data
documents = SimpleDirectoryReader(
    input_file="some_data_path/llama2.pdf"
).load_data()
# build parent chunks via NodeParser
node_parser = SentenceSplitter(chunk_size=1024)
base_nodes = node_parser.get_nodes_from_documents(documents)
# define smaller child chunks
sub_chunk_sizes = [256, 512]
sub_node_parsers = [
    SentenceSplitter(chunk_size=c, chunk_overlap=20) for c in sub_chunk_sizes
]
all_nodes = []
for base_node in base_nodes:
    for n in sub_node_parsers:
        sub_nodes = n.get_nodes_from_documents([base_node])
        sub_inodes = [
            IndexNode.from_text_node(sn, base_node.node_id) for sn in sub_nodes
        ]
        all_nodes.extend(sub_inodes)
# also add original node to node
original_node = IndexNode.from_text_node(base_node, base_node.node_id)
all_nodes.append(original_node)
# define a VectorStoreIndex with all of the nodes
vector_index_chunk = VectorStoreIndex(
    all_nodes, service_context=service_context
)
vector_retriever_chunk = vector_index_chunk.as_retriever(similarity_top_k=2)
# build RecursiveRetriever
all_nodes_dict = {n.node_id: n for n in all_nodes}
retriever_chunk = RecursiveRetriever(
    "vector",
    retriever_dict={"vector": vector_retriever_chunk},
    node_dict=all_nodes_dict,
    verbose=True,
)
# build RetrieverQueryEngine using recursive_retriever
query_engine_chunk = RetrieverQueryEngine.from_args(
    retriever_chunk, service_context=service_context
)
# perform inference with advanced RAG (i.e. query engine)
response = query_engine_chunk.query(
    "Can you tell me about the key concepts for safety finetuning"
)
```
#### Advanced Techniques for Generation
1. **Information Compression**: Reducing noise in retrieved documents to prevent response degradation due to irrelevant information.
##### LlamaIndex Information Compression Recipe
```python
from llama_index import SimpleDirectoryReader, VectorStoreIndex
from llama_index.query_engine import RetrieverQueryEngine
from llama_index.postprocessor import LongLLMLinguaPostprocessor
# Recipe
# Define a Postprocessor object, here LongLLMLinguaPostprocessor
# Build QueryEngine that uses this Postprocessor on retrieved docs
# Define Postprocessor
node_postprocessor = LongLLMLinguaPostprocessor(
    instruction_str="Given the context, please answer the final question",
    target_token=300,
    rank_method="longllmlingua",
    additional_compress_kwargs={
        "condition_compare": True,
        "condition_in_question": "after",
        "context_budget": "+100",
        "reorder_context": "sort",  # enable document reorder
    },
)
# Define VectorStoreIndex
documents = SimpleDirectoryReader(input_dir="...").load_data()
index = VectorStoreIndex.from_documents(documents)
# Define QueryEngine
retriever = index.as_retriever(similarity_top_k=2)
retriever_query_engine = RetrieverQueryEngine.from_args(
    retriever, node_postprocessors=[node_postprocessor]
)
# Used your advanced RAG
response = retriever_query_engine.query("A user query")
```
2. **Result Re-Rank**: Re-ranking retrieved documents to address the "Lost in the Middle" phenomenon where LLMs focus on the extreme ends of prompts.
##### LlamaIndex Re-Ranking For Better Generation Recipe
```python
import os
from llama_index import SimpleDirectoryReader, VectorStoreIndex
from llama_index.postprocessor.cohere_rerank import CohereRerank
from llama_index.postprocessor import LongLLMLinguaPostprocessor
# Recipe
# Define a Postprocessor object, here CohereRerank
# Build QueryEngine that uses this Postprocessor on retrieved docs
# Build CohereRerank post retrieval processor
api_key = os.environ["COHERE_API_KEY"]
cohere_rerank = CohereRerank(api_key=api_key, top_n=2)
# Build QueryEngine (RAG) using the post processor
documents = SimpleDirectoryReader("./data/paul_graham/").load_data()
index = VectorStoreIndex.from_documents(documents=documents)
query_engine = index.as_query_engine(
    similarity_top_k=10,
    node_postprocessors=[cohere_rerank],
)
# Use your advanced RAG
response = query_engine.query(
    "What did Sam Altman do in this essay?"
)
```
#### Advanced Techniques for Simultaneously Addressing Retrieval and Generation
1. **Generator-Enhanced Retrieval**: Refining the user query with the LLM's reasoning abilities before retrieval.
##### LlamaIndex Generator-Enhanced Retrieval Recipe
```python
from llama_index.llms import OpenAI
from llama_index.query_engine import FLAREInstructQueryEngine
from llama_index import (
    VectorStoreIndex,
    SimpleDirectoryReader,
    ServiceContext,
)
# Recipe
# Build a FLAREInstructQueryEngine which has the generator LLM play
# a more active role in retrieval by prompting it to elicit retrieval
# instructions on what it needs to answer the user query.
# Build FLAREInstructQueryEngine
documents = SimpleDirectoryReader("./data/paul_graham").load_data()
index = VectorStoreIndex.from_documents(documents)
index_query_engine = index.as_query_engine(similarity_top_k=2)
service_context = ServiceContext.from_defaults(llm=OpenAI(model="gpt-4"))
flare_query_engine = FLAREInstructQueryEngine(
    query_engine=index_query_engine,
    service_context=service_context,
    max_iterations=7,
    verbose=True,
)
# Use your advanced RAG
response = flare_query_engine.query(
    "Can you tell me about the author's trajectory in the startup world?"
)
```
2. **Iterative Retrieval-Generator RAG**: Multi-step reasoning to provide relevant answers to complex queries.
##### LlamaIndex Iterative Retrieval-Generator Recipe
```python
from llama_index.query_engine import RetryQueryEngine
from llama_index.evaluation import RelevancyEvaluator
# Recipe
# Build a RetryQueryEngine which performs retrieval-generation cycles
# until it either achieves a passing evaluation or a max number of
# cycles has been reached
# Build RetryQueryEngine
documents = SimpleDirectoryReader("./data/paul_graham").load_data()
index = VectorStoreIndex.from_documents(documents)
base_query_engine = index.as_query_engine()
query_response_evaluator = RelevancyEvaluator() # evaluator to critique
# retrieval-generation cycles
retry_query_engine = RetryQueryEngine(
    base_query_engine, query_response_evaluator
)
# Use your advanced rag
retry_response = retry_query_engine.query("A user query")
```
### Measurement Aspects of RAG
The article references seven measurement aspects for evaluating RAG systems, as indicated in the survey paper by Gao, Yunfan, et al. The llama-index library provides evaluation abstractions and integrations to assist builders in understanding how well their RAG systems meet the success requirements.
### Conclusion
The article equips readers with the knowledge and techniques necessary to build advanced RAG systems. It emphasizes the importance of sophisticated retrieval and generation methods to create RAG systems that can handle complex user queries and data structures effectively.
#### Links:
  - [blog.llamaindex.ai](https://blog.llamaindex.ai/?source=post_page-----803a9d94c41b--------------------------------)
  - [LlamaIndex Blog](https://blog.llamaindex.ai/?source=post_page-----803a9d94c41b--------------------------------)
  - [high-resolution version](https://d3ddy8balm3goa.cloudfront.net/llamaindex/rag-cheat-sheet-final.svg)
  - [“Retrieval-Augmented Generation for Large Language Models: A Survey” Gao, Yunfan, et al. 2023](https://arxiv.org/pdf/2312.10997.pdf)
  - [notebook guide](https://github.com/run-llama/llama_index/blob/main/docs/examples/param_optimizer/param_optimizer.ipynb)
  - [notebook guide](https://docs.llamaindex.ai/en/stable/examples/retrievers/recursive_retriever_nodes.html)
  - [Building External Knowledge using Knowledge Graphs](https://docs.llamaindex.ai/en/stable/examples/query_engine/knowledge_graph_rag_query_engine.html)
  - [Performing Mixed Retrieval with Auto Retrievers](https://docs.llamaindex.ai/en/stable/examples/vector_stores/elasticsearch_auto_retriever.html)
  - [Building Fusion Retrievers](https://docs.llamaindex.ai/en/stable/examples/retrievers/simple_fusion.html)
  - [Fine-tuning Embedding Models used in Retrieval](https://docs.llamaindex.ai/en/stable/examples/finetuning/embeddings/finetune_embedding.html)
  - [Transforming Query Embeddings (HyDE)](https://docs.llamaindex.ai/en/stable/examples/query_transformations/HyDEQueryTransformDemo.html)
  - [notebook guide](https://docs.llamaindex.ai/en/stable/examples/node_postprocessor/LongLLMLingua.html)
  - [notebook guide](https://docs.llamaindex.ai/en/stable/examples/node_postprocessor/CohereRerank.html)
  - [notebook guide](https://docs.llamaindex.ai/en/stable/examples/query_engine/flare_query_engine.html)
  - [notebook guide](https://docs.llamaindex.ai/en/stable/examples/evaluation/RetryQuery.html#retry-query-engine)
  - [Answer Relevancy and Context Relevancy](https://docs.llamaindex.ai/en/latest/examples/evaluation/answer_and_context_relevancy.html)
  - [Faithfulness](https://www.notion.so/LlamaIndex-Platform-0754edd9af1c4159bde12649c184c8ef?pvs=21)
  - [Retrieval Evaluation](https://github.com/run-llama/llama_index/blob/main/docs/examples/evaluation/retrieval/retriever_eval.ipynb)
  - [Batch Evaluations with BatchEvalRunner](https://docs.llamaindex.ai/en/stable/examples/evaluation/batch_eval.html)
  - [blog.llamaindex.ai](https://blog.llamaindex.ai/?source=post_page-----803a9d94c41b--------------------------------)
  - [LlamaIndex Blog](https://blog.llamaindex.ai/?source=post_page-----803a9d94c41b--------------------------------)
  - [https://ca.linkedin.com/in/nerdai](https://ca.linkedin.com/in/nerdai)