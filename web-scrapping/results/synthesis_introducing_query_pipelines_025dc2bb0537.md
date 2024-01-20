### Article Overview
#### Title:
Introducing Query Pipelines
#### Author and Date:
Jerry Liu, Published on January 8
#### Source:
LlamaIndex Blog
#### Link:
[Article Link](https://blog.llamaindex.ai/introducing-query-pipelines-025dc2bb0537)
### Main Content
#### Introduction to Query Pipelines
LlamaIndex has introduced a new declarative API called Query Pipelines, designed to orchestrate query workflows over data for various use cases such as Retrieval-Augmented Generation (RAG), structured data extraction, and more. The QueryPipeline abstraction is central to this, capable of integrating multiple LlamaIndex modules like LLMs, prompts, query engines, and retrievers, and forming a computational graph that can be a sequential chain or a Directed Acyclic Graph (DAG). It also supports callbacks and integrates with observability partners.
#### Context and Evolution of RAG
AI engineers have developed complex orchestration flows with LLMs to address different use cases, leading to common patterns and paradigms for querying data. RAG, for querying unstructured data, and text-to-SQL, for querying structured data, are examples of such paradigms. RAG has evolved to become more modular, allowing developers to select the best modules for their needs, as supported by the RAG Survey paper by Gao et al.
#### Previous State of LlamaIndex
LlamaIndex provided numerous RAG guides and Llama Pack recipes for setting up various RAG pipelines and allowed users to define their workflows using low-level modules. However, there was no explicit orchestration abstraction, and users had to manage workflows imperatively.
#### Query Pipeline Features
The QueryPipeline offers a declarative approach to composing workflows, either as sequential chains or full DAGs. It simplifies the process, reduces boilerplate code, enhances readability, and provides end-to-end observability. Future features include easy serializability and caching.
#### Usage of QueryPipeline
The QueryPipeline can be used to create DAG-based query workflows with LlamaIndex modules. It can be used for simple linear pipelines or more complex DAGs. The usage pattern guide provides more details.
#### Sequential Chain Example
Here is an example of a basic sequential chain using a prompt with an LLM:
```python
prompt_str = "Please generate related movies to {movie_name}"
prompt_tmpl = PromptTemplate(prompt_str)
llm = OpenAI(model="gpt-3.5-turbo")
p = QueryPipeline(chain=[prompt_tmpl, llm], verbose=True)
```
#### Setting up a DAG for an Advanced RAG Workflow
To set up a more complex workflow, such as an advanced RAG, you would define modules and their relationships as follows:
```python
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
```
#### Running the Pipeline
To run the pipeline, you can use the `run` method for a single root and output node, or `run_multi` for multiple roots or outputs:
```python
output = p.run(topic="YC")
# output type is Response
type(output)
```
```python
output_dict = p.run_multi({"llm": {"topic": "YC"}})
print(output_dict)
```
#### Defining Custom Query Components
Creating a subclass of `CustomQueryComponent` allows for easy integration into the QueryPipeline.
#### Supported Modules
The QueryPipeline supports various LlamaIndex modules, and users can define their own. Supported modules include LLMs, Prompts, Query Engines, Query Transforms, Retrievers, Output Parsers, Postprocessors/Rerankers, Response Synthesizers, and other QueryPipeline objects.
#### Walkthrough Example
The Introduction to Query Pipelines guide provides a detailed walkthrough with examples, including logging traces through Arize Phoenix for observability.
#### Related Work
The concept of a declarative syntax for LLM-powered pipelines is not new and has been explored in other works like Haystack, LangChain Expression Language, and no-code/low-code setups like Langflow and Flowise.
#### FAQ
The article addresses the difference between a QueryPipeline and an IngestionPipeline, noting that the former operates during the query stage while the latter operates during data ingestion.
#### Conclusion and Resources
The article concludes by promising more resources and guides in the future. Current resources include guides on Query Pipelines, a walkthrough, usage patterns, and module usage.
### Author Information
Jerry Liu is the author of the article, with 5.5K followers and is an editor for the LlamaIndex Blog and creator of LlamaIndex.
#### Links:
  - [Open in app - rsci.app.link](https://rsci.app.link/?%24canonical_url=https%3A%2F%2Fmedium.com%2Fp%2F025dc2bb0537&%7Efeature=LoOpenInAppButton&%7Echannel=ShowPostUnderCollection&source=---two_column_layout_nav----------------------------------)
  - [blog.llamaindex.ai](https://blog.llamaindex.ai/?source=post_page-----025dc2bb0537--------------------------------)
  - [observability partners - docs.llamaindex.ai - obse](https://docs.llamaindex.ai/en/latest/module_guides/observability/observability.html)
  - [introduction guide - docs.llamaindex.ai - query_pi](https://docs.llamaindex.ai/en/latest/examples/pipeline/query_pipeline.html)
  - [docs page - docs.llamaindex.ai - root](https://docs.llamaindex.ai/en/latest/module_guides/querying/pipeline/root.html)
  - [RAG Survey paper by Gao et al. - arxiv.org](https://arxiv.org/pdf/2312.10997.pdf)
  - [DSP+github.com stanfordnlp dspy](https://github.com/stanfordnlp/dspy)
  - [Rewrite-Retrieve-Read+arxiv.org abs 2305.14283](https://arxiv.org/abs/2305.14283)
  - [interleaving retrieval+generation multiple times -](https://arxiv.org/abs/2305.15294)
  - [LLMs+docs.llamaindex.ai en latest module_guides mo](https://docs.llamaindex.ai/en/latest/module_guides/models/llms.html)
  - [prompts+docs.llamaindex.ai en stable module_guides](https://docs.llamaindex.ai/en/stable/module_guides/models/prompts.html#prompts)
  - [embeddings+docs.llamaindex.ai en stable module_gui](https://docs.llamaindex.ai/en/stable/module_guides/models/embeddings.html)
  - [postprocessors+docs.llamaindex.ai en stable module](https://docs.llamaindex.ai/en/stable/module_guides/querying/node_postprocessors/root.html)
  - [retrievers+docs.llamaindex.ai en stable examples q](https://docs.llamaindex.ai/en/stable/examples/query_engine/CustomRetrievers.html)
  - [query engines - docs.llamaindex.ai - custom_query_](https://docs.llamaindex.ai/en/stable/examples/query_engine/custom_query_engine.html)
  - [usage pattern guide - docs.llamaindex.ai - usage_p](https://docs.llamaindex.ai/en/latest/module_guides/querying/pipeline/usage_pattern.html)
  - [our walkthrough - docs.llamaindex.ai](https://docs.llamaindex.ai/en/latest/module_guides/querying/pipeline/usage_pattern.html#defining-a-custom-query-component)
  - [module usage guide - docs.llamaindex.ai - module_u](https://docs.llamaindex.ai/en/latest/module_guides/querying/pipeline/module_usage.html)
  - [Arize Phoenix - github.com](https://github.com/Arize-ai/phoenix)
  - [LangChain Expression Language - python.langchain.c](https://python.langchain.com/docs/expression_language/)
  - [Langflow+github.com logspace-ai langflow](https://github.com/logspace-ai/langflow)
  - [IngestionPipeline+docs.llamaindex.ai en stable mod](https://docs.llamaindex.ai/en/stable/module_guides/loading/ingestion_pipeline/root.html)
  - [Llamaindex+medium.com tag llamaindex?source=post_p](https://medium.com/tag/llamaindex?source=post_page-----025dc2bb0537---------------llamaindex-----------------)
  - [Retrieval Augmented - medium.com](https://medium.com/tag/retrieval-augmented?source=post_page-----025dc2bb0537---------------retrieval_augmented-----------------)
  - [Llm+medium.com tag llm?source=post_page-----025dc2](https://medium.com/tag/llm?source=post_page-----025dc2bb0537---------------llm-----------------)
  - [AI+medium.com tag ai?source=post_page-----025dc2bb](https://medium.com/tag/ai?source=post_page-----025dc2bb0537---------------ai-----------------)
  - [Status+medium.statuspage.io ?source=post_page-----](https://medium.statuspage.io/?source=post_page-----025dc2bb0537--------------------------------)
  - [Text to speech - speechify.com](https://speechify.com/medium?source=post_page-----025dc2bb0537--------------------------------)
  - [Teams+medium.com business?source=post_page-----025](https://medium.com/business?source=post_page-----025dc2bb0537--------------------------------)