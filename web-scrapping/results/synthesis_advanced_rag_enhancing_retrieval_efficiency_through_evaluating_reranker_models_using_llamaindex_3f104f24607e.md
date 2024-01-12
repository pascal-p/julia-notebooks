### Article Analysis: Advanced RAG with LlamaIndex and Re-ranking
#### Article Details
- **Title**: Advanced RAG: Enhancing Retrieval Efficiency through Rerankers using LlamaIndex🦙
- **Author**: Akash Mathur
- **Date**: Dec 28, 2023
- **Reading Time**: 11 min read
- **Link**: [Medium Article](https://akash-mathur.medium.com/advanced-rag-enhancing-retrieval-efficiency-through-evaluating-reranker-models-using-llamaindex-3f104f24607e)
#### Introduction
The article is the second part of the Advanced RAG learning series, focusing on optimizing the retrieval process in recommendation systems using LlamaIndex. It introduces the concept of dynamic retrieval, which is crucial for pruning irrelevant context and enhancing precision despite setting a large top-k value. The author emphasizes the importance of LLM-powered retrieval and reranking to improve document retrieval efficiency.
#### Retrieval and Re-ranking Process
The retrieval process is divided into two stages:
1. **Embedding-based retrieval**: This initial stage aims for a high recall over precision by quickly finding documents using embeddings.
2. **Re-ranking**: A more computationally intensive process that focuses on precision, using an LLM to assess the relevance of documents to the query.
The re-ranking step is essential for fine-tuning the initially retrieved results, ensuring the most relevant information is presented first.
#### Experiment Setup
The author outlines a step-by-step implementation using the following resources:
- **Open Source LLM**: `zephyr-7b-alpha`
- **Embedding**: `hkunlp/instructor-large`
##### Ingestion and Chunking
The process begins with loading documents using a `PDFReader` and creating nodes by splitting the text into chunks of size 512. Nodes represent atomic units of data in LlamaIndex, containing metadata and relationship information.
##### Embedding and Storing
The `VectorStoreIndex` is used to embed documents and split them into nodes, creating vector embeddings for each node. The embeddings are then ready for querying by an LLM.
##### Retrieval
The `VectorIndexRetriever` is configured to perform top-k semantic retrieval, fetching the most similar nodes based on the query's vector embedding.
##### Re-ranking
Three rerankers are compared for performance:
- `CohereRerank`
- `bge-reranker-base`
- `bge-reranker-large`
Helper functions are created to retrieve nodes, visualize results, and evaluate the quality of the retriever using metrics like hit-rate and MRR (Mean Reciprocal Rank).
#### Evaluation and Results
The evaluation is conducted using a `RetrieverEvaluator` to assess the quality of retrieved results against ground-truth context. The `generate_question_context_pairs` function is used to build a simple evaluation dataset over the existing text corpus.
The results highlight the significance of rerankers in optimizing the retrieval process, with `CohereRerank` showing notable performance improvements.
#### Conclusion
The article concludes by stressing the importance of selecting the right embedding for the initial search and the ongoing research to find the best combinations of embeddings and rerankers. The author provides links to the complete code on GitHub and other advanced RAG methods.
#### Code Snippets
The article includes several code snippets, which are provided below:
```python
PDFReader = download_loader("PDFReader")
loader = PDFReader()
docs = loader.load_data(file=Path("QLoRa.pdf"))
```
```python
node_parser = SimpleNodeParser.from_defaults(chunk_size=512)
nodes = node_parser.get_nodes_from_documents(docs)
```
```python
from google.colab import userdata
# huggingface and cohere api token
hf_token = userdata.get('hf_token')
quantization_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_compute_dtype=torch.float16,
    bnb_4bit_quant_type="nf4",
    bnb_4bit_use_double_quant=True,
)
def messages_to_prompt(messages):
    prompt = ""
    for message in messages:
        if message.role == 'system':
            prompt += f"<|system|>\n{message.content}</s>\n"
        elif message.role == 'user':
            prompt += f"<|user|>\n{message.content}</s>\n"
        elif message.role == 'assistant':
            prompt += f"<|assistant|>\n{message.content}</s>\n"
    # ensure we start with a system prompt, insert blank if needed
    if not prompt.startswith("<|system|>\n"):
        prompt = "<|system|>\n</s>\n" + prompt
    # add final assistant prompt
    prompt = prompt + "<|assistant|>\n"
    return prompt
# LLM
llm = HuggingFaceLLM(
    model_name="HuggingFaceH4/zephyr-7b-alpha",
    tokenizer_name="HuggingFaceH4/zephyr-7b-alpha",
    query_wrapper_prompt=PromptTemplate("<|system|>\n</s>\n<|user|>\n{query_str}</s>\n<|assistant|>\n"),
    context_window=3900,
    max_new_tokens=256,
    model_kwargs={"quantization_config": quantization_config},
    # tokenizer_kwargs={},
    generate_kwargs={"temperature": 0.7, "top_k": 50, "top_p": 0.95},
    messages_to_prompt=messages_to_prompt,
    device_map="auto",
)
# Embedding
embed_model = HuggingFaceInstructEmbeddings(
    model_name="hkunlp/instructor-large", model_kwargs={"device": DEVICE}
)
```
```python
# ServiceContext
service_context = ServiceContext.from_defaults(llm=llm,
                                               embed_model=embed_model
)
# index
vector_index = VectorStoreIndex(
    nodes, service_context=service_context
)
# configure retriever
retriever = VectorIndexRetriever(
    index=vector_index,
    similarity_top_k=10,
    service_context=service_context)
```
```python
# Define all embeddings and rerankers
RERANKERS = {
    "WithoutReranker": "None",
    "CohereRerank": CohereRerank(api_key=cohere_api_key, top_n=5),
    "bge-reranker-base": SentenceTransformerRerank(model="BAAI/bge-reranker-base", top_n=5),
    "bge-reranker-large": SentenceTransformerRerank(model="BAAI/bge-reranker-large", top_n=5)
}
```
```python
# helper functions
def get_retrieved_nodes(
    query_str, reranker
):
    query_bundle = QueryBundle(query_str)
    retrieved_nodes = retriever.retrieve(query_bundle)
    if reranker != "None":
        retrieved_nodes = reranker.postprocess_nodes(retrieved_nodes, query_bundle)
    else:
        retrieved_nodes
    return retrieved_nodes
def pretty_print(df):
    return display(HTML(df.to_html().replace("\\n", "<br>")))
def visualize_retrieved_nodes(nodes) -> None:
    result_dicts = []
    for node in nodes:
        node = deepcopy(node)
        node.node.metadata = None
        node_text = node.node.get_text()
        node_text = node_text.replace("\n", " ")
        result_dict = {"Score": node.score, "Text": node_text}
        result_dicts.append(result_dict)
    pretty_print(pd.DataFrame(result_dicts))
```
```python
query_str = "What are the top features of QLoRA?"
# Loop over rerankers
for rerank_name, reranker in RERANKERS.items():
    print(f"Running Evaluation for Reranker: {rerank_name}")
    query_bundle = QueryBundle(query_str)
    retrieved_nodes = retriever.retrieve(query_bundle)
    if reranker != "None":
        retrieved_nodes = reranker.postprocess_nodes(retrieved_nodes, query_bundle)
    else:
        retrieved_nodes
    print(f"Visualize Retrieved Nodes for Reranker: {rerank_name}")
    visualize_retrieved_nodes(retrieved_nodes)
```
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
# Evaluator
qa_dataset = generate_question_context_pairs(
    nodes, llm=llm, num_questions_per_chunk=2, qa_generate_prompt_tmpl=qa_generate_prompt_tmpl
)
```
```python
# helper function for displaying results
def display_results(reranker_name, eval_results):
    """Display results from evaluate."""
    metric_dicts = []
    for eval_result in eval_results:
        metric_dict = eval_result.metric_vals_dict
        metric_dicts.append(metric_dict)
    full_df = pd.DataFrame(metric_dicts)
    hit_rate = full_df["hit_rate"].mean()
    mrr = full_df["mrr"].mean()
    metric_df = pd.DataFrame({"Reranker": [reranker_name], "hit_rate": [hit_rate], "mrr": [mrr]})
    return metric_df
```
```python
query_str = "What are the top features of QLoRA?"
results_df = pd.DataFrame()
# Loop over rerankers
for rerank_name, reranker in RERANKERS.items():
    print(f"Running Evaluation for Reranker: {rerank_name}")
    query_bundle = QueryBundle(query_str)
    retrieved_nodes = retriever.retrieve(query_bundle)
    if reranker != "None":
        retrieved_nodes = reranker.postprocess_nodes(retrieved_nodes, query_bundle)
    else:
        retrieved_nodes
    retriever_evaluator = RetrieverEvaluator.from_metric_names(
        ["mrr", "hit_rate"], retriever=retriever
    )
    eval_results = await retriever_evaluator.aevaluate_dataset(qa_dataset)
    current_df = display_results(rerank_name, eval_results)
    results_df = pd.concat([results_df, current_df], ignore_index=True)
```
#### External Links and References
The article references several external links and resources, including:
- [MTEB leaderboard](https://huggingface.co/spaces/mteb/leaderboard)
- [CohereRerank](https://txt.cohere.com/rerank/)
- [SentenceTransformerRerank models](https://huggingface.co/BAAI/bge-reranker-base) and [here](https://huggingface.co/BAAI/bge-reranker-large)
- [Node Postprocessors documentation](https://docs.llamaindex.ai/en/stable/module_guides/querying/node_postprocessors/root.html)
- [Mean Reciprocal Rank (MRR) Wikipedia page](https://en.wikipedia.org/wiki/Mean_reciprocal_rank)
- [RetrieverEvaluator documentation](https://docs.llamaindex.ai/en/stable/module_guides/evaluating/usage_pattern_retrieval.html)
- [GitHub repository for reranker models evaluation](https://github.com/akashmathur-2212/LLMs-playground/tree/main/LlamaIndex-applications/Advanced-RAG/reranker_models_evaluation?source=post_page-----3f104f24607e--------------------------------)
- [GitHub repository for advanced RAG methods](https://github.com/akashmathur-2212/LLMs-playground/tree/main/LlamaIndex-applications/Advanced-RAG?source=post_page-----3f104f24607e--------------------------------)
- [Akash Mathur's LinkedIn profile](https://www.linkedin.com/in/akashmathur22/)
- [Akash Mathur's GitHub profile](https://github.com/akashmathur-2212)
The article also includes tags for further exploration on Medium:
- [Retrieval Augmented](https://medium.com/tag/retrieval-augmented?source=post_page-----3f104f24607e---------------retrieval_augmented-----------------)
- [Re-ranking](https://medium.com/tag/reranking?source=post_page-----3f104f24607e---------------reranking-----------------)
- [Cohere](https://medium.com/tag/cohere?source=post_page-----3f104f24607e---------------cohere-----------------)
- [Open Source LLM](https://medium.com/tag/open-source-llm?source=post_page-----3f104f24607e---------------open_source_llm-----------------)
- [Retrieval](https://medium.com/tag/retrieval?source=post_page-----3f104f24607e---------------retrieval-----------------)
#### Final Remarks
The author encourages readers to refer to the complete code on GitHub and other advanced RAG methods for further learning. The article aims to contribute to the reader's knowledge stack and invites engagement through Medium's platform.