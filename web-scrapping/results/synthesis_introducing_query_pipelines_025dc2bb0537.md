# Article Synthesis: Introducing Query Pipelines
## Article Details
- **Title:** Introducing Query Pipelines
- **Author:** Jerry Liu
- **Publication Date:** 3 days ago from the knowledge cutoff date
- **Reading Time:** 6 min read
- **Publication Platform:** LlamaIndex Blog
- **Article Link:** [Introducing Query Pipelines](https://blog.llamaindex.ai/introducing-query-pipelines-025dc2bb0537)
## Introduction
The article announces the launch of a new feature within LlamaIndex called Query Pipelines. This feature is a declarative API designed to facilitate the orchestration of query workflows over data, catering to various use cases such as Retrieval-Augmented Generation (RAG), structured data extraction, and more. The QueryPipeline abstraction is central to this feature, allowing the integration of multiple LlamaIndex modules, including LLMs, prompts, query engines, retrievers, and even the QueryPipeline itself, to form computational graphs like sequential chains or Directed Acyclic Graphs (DAGs). It also offers callback support and compatibility with observability partners.
## Core Concepts and Developments
### Query Orchestration in RAG
The article discusses the evolution of query orchestration within the context of RAG, highlighting the complexity involved in building advanced RAG pipelines for performance optimization. These pipelines may involve query understanding and transformations, multi-stage retrieval algorithms, and various response synthesis methods. The article references a blog on advanced RAG components for further reading.
### Modularity in RAG
RAG has become more modular, allowing developers to select the most suitable modules for their specific use cases. This modularity is supported by the RAG Survey paper by Gao et al. and has led to the development of new patterns such as DSP, Rewrite-Retrieve-Read, and interleaving retrieval and generation multiple times. LlamaIndex has contributed to this trend with numerous RAG guides and Llama Pack recipes.
### LlamaIndex's Low-Level Modules
LlamaIndex has exposed low-level modules such as LLMs, prompts, embeddings, postprocessors, and has made core components like retrievers and query engines easily subclassable. This empowers users to define their own workflows.
## QueryPipeline: A Declarative Orchestration Abstraction
The QueryPipeline is introduced as a solution to the previously imperative approach to workflow orchestration. It simplifies the process by allowing users to compose workflows declaratively, resulting in more efficient code with fewer lines.
### Benefits and Usage
The QueryPipeline offers the ability to create DAG-based workflows using LlamaIndex modules. It supports both linear and complex pipelines, with the latter requiring the use of lower-level functions to build a DAG. The article provides code examples to illustrate the setup of a basic prompt chain and an advanced RAG pipeline, highlighting the use of `source_key` and `dest_key` parameters when necessary.
### Running the Pipeline
Depending on the structure of the pipeline, users can execute it using either the `run` method for single root and output nodes or the `run_multi` method for multiple root or output nodes. The article includes Python code snippets demonstrating the use of these methods.
### Subclassing and Supported Modules
Users can easily subclass `CustomQueryComponent` to integrate custom components into the QueryPipeline. The article lists the currently supported LlamaIndex modules and refers to the module usage guide for more information.
### Observability and Related Works
The QueryPipeline integrates with observability providers, with full callback support for each component. The article mentions related works such as Haystack, LangChain Expression Language, Langflow, and Flowise, which also offer declarative syntax for building LLM-powered pipelines.
### QueryPipeline vs. IngestionPipeline
The article clarifies the difference between QueryPipeline and IngestionPipeline, noting that the former operates during the query stage while the latter functions during data ingestion. There is a possibility of developing shared abstractions for both in the future.
## Conclusion and Resources
The article concludes by reiterating the goal of providing a convenient developer experience for defining common query workflows. It promises more resources and guides to come and directs readers to the current guides available.
## Python Code Snippets
```python
# try chaining basic prompts
prompt_str = "Please generate related movies to {movie_name}"
prompt_tmpl = PromptTemplate(prompt_str)
llm = OpenAI(model="gpt-3.5-turbo")
p = QueryPipeline(chain=[prompt_tmpl, llm], verbose=True)
from llama_index.postprocessor import CohereRerank
from llama_index.response_synthesizers import TreeSummarize
from llama_index import ServiceContext
# define modules
prompt_str = "Please generate a question about Paul Graham's life regarding the following topic {topic}"
prompt_tmpl = PromptTemplate(prompt_str)
llm = OpenAI(model="gpt-3.5-turbo")
retriever = index.as_retriever(similarity_top_k=3)
reranker = CohereRerank()
summarizer = TreeSummarize(
    service_context=ServiceContext.from_defaults(llm=llm)
)
# define query pipeline
p = QueryPipeline(verbose=True)
p.add_modules(
    {
        "llm": llm,
        "prompt_tmpl": prompt_tmpl,
        "retriever": retriever,
        "summarizer": summarizer,
        "reranker": reranker,
    }
)
# add edges
p.add_link("prompt_tmpl", "llm")
p.add_link("llm", "retriever")
p.add_link("retriever", "reranker", dest_key="nodes")
p.add_link("llm", "reranker", dest_key="query_str")
p.add_link("reranker", "summarizer", dest_key="nodes")
p.add_link("llm", "summarizer", dest_key="query_str")
output = p.run(topic="YC")
# output type is Response
type(output)
output_dict = p.run_multi({"llm": {"topic": "YC"}})
print(output_dict)
```
## External Links and References
The article contains numerous external links and references, some of which are to sign-in pages, the LlamaIndex blog, documentation, and academic papers. Notably, it references the RAG Survey paper by Gao et al., DSP GitHub repository, and other academic papers on related topics. It also links to the Arize Phoenix GitHub repository and various documentation pages within the LlamaIndex documentation. Links to sign-in or registration pages are repeated multiple times throughout the article.
- [RAG Survey paper by Gao et al.](https://arxiv.org/pdf/2312.10997.pdf)
- [DSP GitHub repository](https://github.com/stanfordnlp/dspy)
- [Rewrite-Retrieve-Read paper](https://arxiv.org/abs/2305.14283)
- [Interleaving retrieval+generation paper](https://arxiv.org/abs/2305.15294)
- [LlamaIndex Documentation](https://docs.llamaindex.ai/)
- [Arize Phoenix GitHub repository](https://github.com/Arize-ai/phoenix)
- [LangChain Expression Language documentation](https://python.langchain.com/docs/expression_language/)
- [Langflow GitHub repository](https://github.com/logspace-ai/langflow)
- [Medium Tags for LlamaIndex](https://medium.com/tag/llamaindex?source=post_page-----025dc2bb0537---------------llamaindex-----------------)
The article also includes links to various guides and documentation pages within the LlamaIndex documentation, which provide further details on the usage patterns, module usage, and the introduction to Query Pipelines.
- [Introduction to Query Pipelines guide](https://docs.llamaindex.ai/en/latest/examples/pipeline/query_pipeline.html)
- [Module usage guide](https://docs.llamaindex.ai/en/latest/module_guides/querying/pipeline/module_usage.html)
- [Usage pattern guide](https://docs.llamaindex.ai/en/latest/module_guides/querying/pipeline/usage_pattern.html)
## Note on Missing Information
The full details of some links or references, such as the sign-in or registration pages, are not available within the excerpt provided. These links are primarily for user authentication and subscription purposes on the Medium platform and are not directly related to the content of the article.