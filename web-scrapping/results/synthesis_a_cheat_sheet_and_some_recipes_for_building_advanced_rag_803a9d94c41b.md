### Article Overview
#### Title and Metadata
- **Title**: A Cheat Sheet and Some Recipes For Building Advanced RAG
- **Author**: Andrei
- **Publication Date**: January 5
- **Published In**: LlamaIndex Blog
- **Reading Time**: 7 min read
- **Article Link**: [LlamaIndex Blog Post](https://blog.llamaindex.ai/a-cheat-sheet-and-some-recipes-for-building-advanced-rag-803a9d94c41b)
#### Introduction
The blog post by Andrei on LlamaIndex Blog serves as a guide for individuals looking to either enter the Retrieval-Augmented Generation (RAG) scene or enhance their existing RAG systems. The post is intended to provide direction and a mental model for decision-making in the construction of advanced RAG systems. The inspiration for the RAG cheat sheet provided in the article comes from a recent survey paper titled "Retrieval-Augmented Generation for Large Language Models: A Survey" by Gao, Yunfan, et al., 2023.
#### Main Content
The article defines mainstream RAG as a process involving the retrieval of documents from an external knowledge database, which are then passed along with the user's query to a Large Language Model (LLM) for response generation. The success of a RAG system is predicated on two high-level requirements: the relevance of the retrieved documents and the usefulness of the generated responses.
To achieve these requirements, the article outlines several sophisticated techniques and strategies that can be applied to the Retrieval or Generation components of a RAG system. These techniques are categorized based on whether they address one or both of the high-level success requirements.
#### Advanced Techniques and Recipes
The blog post provides a series of "recipes" for implementing advanced RAG techniques using the LlamaIndex library. Each recipe is accompanied by a link to a notebook guide for further details. The techniques include:
1. **Chunk Size Optimization**: Adjusting the chunk size for document retrieval to ensure relevance.
2. **Structured External Knowledge**: Building an external knowledge base with more structure to allow for recursive retrievals or routed retrieval.
3. **Recursive Retrieval**: Implementing a recursive retriever that retrieves using small chunks but passes associated larger chunks to the generation stage.
4. **Information Compression**: Compressing the retrieved information before passing it to the generation component.
5. **Result Re-Rank**: Re-ranking retrieved documents to counteract the "Lost in the Middle" phenomenon in LLMs.
6. **Generator-Enhanced Retrieval**: Using the generator LLM to play a more active role in retrieval by prompting it to elicit retrieval instructions.
7. **Iterative Retrieval-Generator RAG**: Employing multi-step reasoning to provide relevant answers to complex user queries.
#### Evaluation of RAG Systems
The article emphasizes the importance of evaluating RAG systems and references the seven measurement aspects indicated in the survey paper by Gao, Yunfan, et al. The LlamaIndex library offers several evaluation abstractions and integrations to assist builders in understanding how well their RAG system meets the success requirements.
#### Conclusion
The post concludes with the hope that readers will feel more equipped and confident in applying these sophisticated techniques to build advanced RAG systems.
### Code Snippets
#### Basic RAG System Example
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
#### Chunk Size Optimization Recipe
```python
from llama_index import ServiceContext
from llama_index.param_tuner.base import ParamTuner, RunResult
from llama_index.evaluation import SemanticSimilarityEvaluator, BatchEvalRunner
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
    pred_response_objs = get_responses(eval_qs, query_engine, show_progress=True)
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
#### Recursive Retrieval Recipe
```python
from llama_index import SimpleDirectoryReader, VectorStoreIndex
from llama_index.node_parser import SentenceSplitter
from llama_index.schema import IndexNode
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
#### Information Compression Recipe
```python
from llama_index import SimpleDirectoryReader, VectorStoreIndex
from llama_index.query_engine import RetrieverQueryEngine
from llama_index.postprocessor import LongLLMLinguaPostprocessor
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
#### Result Re-Rank Recipe
```python
import os
from llama_index import SimpleDirectoryReader, VectorStoreIndex
from llama_index.postprocessor.cohere_rerank import CohereRerank
from llama_index.postprocessor import LongLLMLinguaPostprocessor
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
#### Generator-Enhanced Retrieval Recipe
```python
from llama_index.llms import OpenAI
from llama_index.query_engine import FLAREInstructQueryEngine
from llama_index import (
    VectorStoreIndex,
    SimpleDirectoryReader,
    ServiceContext,
)
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
#### Iterative Retrieval-Generator RAG Recipe
```python
from llama_index.query_engine import RetryQueryEngine
from llama_index.evaluation import RelevancyEvaluator
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
### External Links and References
The article includes several external links and references, which are listed below:
- [LlamaIndex Blog Post](https://blog.llamaindex.ai/a-cheat-sheet-and-some-recipes-for-building-advanced-rag-803a9d94c41b)
- [RAG Cheat Sheet Image](https://d3ddy8balm3goa.cloudfront.net/llamaindex/rag-cheat-sheet-final.svg)
- [Survey Paper: "Retrieval-Augmented Generation for Large Language Models: A Survey"](https://arxiv.org/pdf/2312.10997.pdf)
- [LlamaIndex GitHub Repository](https://github.com/run-llama/llama_index)
- [LlamaIndex Documentation and Examples](https://docs.llamaindex.ai/en/stable/)
- [Notion: LlamaIndex Platform](https://www.notion.so/LlamaIndex-Platform-0754edd9af1c4159bde12649c184c8ef?pvs=21)
- [Andrei's LinkedIn Profile](https://ca.linkedin.com/in/nerdai)
The links to the notebook guides for the recipes mentioned in the article are not directly accessible within the provided excerpt. However, they are likely to be found within the LlamaIndex documentation or GitHub repository.
### Conclusion
The blog post by Andrei provides a comprehensive guide to building advanced RAG systems using LlamaIndex. It covers a range of sophisticated techniques and includes practical recipes with code snippets to help readers implement these strategies. The article also stresses the importance of evaluating RAG systems and provides resources for further exploration and learning.