# Article Synthesis: Advanced Retrieval Techniques In RAG | Part 03 | Sentence Window Retrieval
## Article Details
- **Title**: Advance Retrieval Techniques In RAG | Part 03 | Sentence Window Retrieval
- **Author and Date**: Prince Krampah, Jan 2
- **Publication**: AI Advances
- **Read Time**: 19 min read
- **Link**: [Advance Retrieval Techniques In RAG | Part 03 | Sentence Window Retrieval](https://ai.gopubby.com/advance-retrieval-techniques-in-rag-part-03-sentence-window-retrieval-9f246cffa07b)
## Introduction
The article by Prince Krampah, published on January 2nd in AI Advances, is the third installment in a series about advanced retrieval techniques in Retrieval-Augmented Generation (RAG). This piece focuses on the Sentence Window Retrieval Technique, which the author regards as one of the most effective techniques in advanced RAG pipelines. The article provides a comprehensive guide on setting up this technique and using TruEval to measure its performance against other techniques discussed in previous articles.
## Sentence Window Retrieval
### Concept and Rationale
Sentence Window Retrieval involves retrieving document pieces and returning a number of sentences surrounding the relevant sentence. The synthesis for the Language Learning Model (LLM) is then generated from this relevant sentence and the window of sentences above and below it. The size of the window can be controlled, and this technique is based on the idea that embedding-based retrieval performs best with smaller-sized sentences. By using sentence-based retrieval, the chunk used for searching and the final document passed to the LLM for synthesis are decoupled.
### Implementation Steps
#### Loading the Document
The document used in the example is the state of the union address speech, which has been used in past articles. The document is loaded using the `SimpleDirectoryReader` from the `llama_index` package. The code snippet for loading the document is as follows:
```python
from llama_index import (
  SimpleDirectoryReader,
)
# load document
documents = SimpleDirectoryReader(
  input_dir="../dataFiles/"
).load_data(show_progress=True)
print(len(documents))
```
For multiple pages or documents, they can be merged into a single document for better accuracy when splitting into chunks or "Nodes" as referred to in LlamaIndex. The code for merging documents is:
```python
from llama_index import (
  SimpleDirectoryReader,
  Document
)
# load document
documents = SimpleDirectoryReader(
  input_dir="../dataFiles/"
).load_data(show_progress=True)
# merge pages into one
document = Document(text="\n\n".join([doc.text for doc in documents]))
print(document)
```
#### Setting Up the Sentence Window Retriever
A `SentenceWindowNodeParser` is set up to break down a document into individual sentences and augment them with surrounding sentences within the allowed window. The following code snippet demonstrates the setup and usage of the `SentenceWindowNodeParser`:
```python
from llama_index.node_parser import SentenceWindowNodeParser
# create the sentence window node parser
node_parser = SentenceWindowNodeParser.from_defaults(
  window_size=2,
  window_metadata_key="window",
  original_text_metadata_key="original_text",
)
# Toy example to play around with
text = "I love programming. Python is my most favorite language. I love LLMs. I love LlamaIndex."
# Get nodes
nodes = node_parser.get_nodes_from_documents([Document(text=text)])
# Print out individual nodes
print([x.text for x in nodes])
# Print out the window around the second node
print(nodes[1].metadata["window"])
```
#### Building Indexes
Building indexes requires an LLM and a service context specifying the embedding model, LLM, and the node parser. The `OpenAIEmbedding` model is used in the example. The code snippet for creating the service context is:
```python
# creating OpenAI gpt-3.5-turbo LLM and OpenAIEmbedding model
llm = OpenAI(model="gpt-3.5-turbo", temperature=0.1)
embed_model = OpenAIEmbedding()
# creating the service context
sentence_context = ServiceContext.from_defaults(
  llm=llm,
  embed_model=embed_model,
  node_parser=node_parser,
)
```
A vector store index is set up and made persistent to store the embeddings and avoid repetition. The code for creating or loading the vector store index is:
```python
import os
from llama_index import (
  SimpleDirectoryReader,
  Document,
  StorageContext,
  load_index_from_storage
)
from llama_index.node_parser import SentenceWindowNodeParser
from llama_index.llms import OpenAI
from llama_index.embeddings import OpenAIEmbedding
from llama_index import ServiceContext
from llama_index import VectorStoreIndex
from decouple import config
# set env variables
os.environ["OPENAI_API_KEY"] = config("OPENAI_API_KEY")
# load document
documents = SimpleDirectoryReader(
  input_dir="../dataFiles/"
).load_data(show_progress=True)
# merge pages into one
document = Document(text="\n\n".join([doc.text for doc in documents]))
node_parser = SentenceWindowNodeParser.from_defaults(
  window_size=3,
  window_metadata_key="window",
  original_text_metadata_key="original_text",
)
# creating OpenAI gpt-3.5-turbo LLM and OpenAIEmbedding model
llm = OpenAI(model="gpt-3.5-turbo", temperature=0.1)
embed_model = OpenAIEmbedding()
# creating the service context
sentence_context = ServiceContext.from_defaults(
  llm=llm,
  embed_model=embed_model,
  node_parser=node_parser,
)
if not os.path.exists("./storage"):
  # creating the vector store index
  index = VectorStoreIndex.from_documents(
    [document], service_context=sentence_context
  )
  # make vector store persistant
  index.storage_context.persist(persist_dir="./storage")
else:
  # load vector store indexed if they exist
  index = load_index_from_storage(
    StorageContext.from_defaults(persist_dir="./storage"),
    service_context=sentence_context
  )
```
#### Creating Meta Data Replacement Post Processor and Adding A Re-ranker
The `MetaDataReplacementPostProcessor` is used after retrieval to replace the metadata around the retrieved node with the actual surrounding text. A reranker, specifically `BAAI/bge-reranker-base` from Hugging Face, is used to rerank sentences based on their relevance. The code for adding the postprocessor and reranker is:
```python
import os
from llama_index import (
  SimpleDirectoryReader,
  Document,
  StorageContext,
  load_index_from_storage
)
from llama_index.node_parser import SentenceWindowNodeParser
from llama_index.llms import OpenAI
from llama_index.embeddings import OpenAIEmbedding
from llama_index import ServiceContext
from llama_index import VectorStoreIndex
from llama_index.indices.postprocessor import MetadataReplacementPostProcessor
from llama_index.indices.postprocessor import SentenceTransformerRerank
from decouple import config
# set env variables
os.environ["OPENAI_API_KEY"] = config("OPENAI_API_KEY")
# load document
documents = SimpleDirectoryReader(
  input_dir="../dataFiles/"
).load_data(show_progress=True)
# merge pages into one
document = Document(text="\n\n".join([doc.text for doc in documents]))
node_parser = SentenceWindowNodeParser.from_defaults(
  window_size=3,
  window_metadata_key="window",
  original_text_metadata_key="original_text",
)
# creating OpenAI gpt-3.5-turbo LLM and OpenAIEmbedding model
llm = OpenAI(model="gpt-3.5-turbo", temperature=0.1)
embed_model = OpenAIEmbedding()
# creating the service context
sentence_context = ServiceContext.from_defaults(
  llm=llm,
  embed_model=embed_model,
  node_parser=node_parser,
)
if not os.path.exists("./storage"):
  # creating the vector store index
  index = VectorStoreIndex.from_documents(
    [document], service_context=sentence_context
  )
  # make vector store persistant
  index.storage_context.persist(persist_dir="./storage")
else:
  # load vector store indexed if they exist
  index = load_index_from_storage(
    StorageContext.from_defaults(persist_dir="./storage"),
    service_context=sentence_context
  )
# add meta data replacement post processor
postproc = MetadataReplacementPostProcessor(
  target_metadata_key="window"
)
# link: https://huggingface.co/BAAI/bge-reranker-base
rerank = SentenceTransformerRerank(
  top_n=2, model="BAAI/bge-reranker-base"
)
```
The query engine is then tested with a query about covid-19, and the response is printed.
#### Evaluation
The evaluation phase seeks to answer several questions regarding the best sentence window size, the trade-off between window size and groundedness or responses (hallucination), relevance of response, context relevance, groundedness, and cost. The author suggests that as the sentence window increases, groundedness will increase up to a certain point, but too large a window may reduce groundedness due to information overload.
The relationship between sentence window size and relevance of response is also likely to increase up to a certain point, with too much context potentially leading to distraction and hallucination. Cost increases with sentence window size due to the use of more tokens.
The evaluation is conducted using a collection of questions and TruLens, with the code converted into functions for creating indexes and query engines. The code for setting up TruLens for evaluation is provided, with different window sizes being tested.
## Conclusion
The article concludes by encouraging readers to experiment with different context window sizes, embedding models, and LLMs to find the best configuration for their RAG pipeline. The author provides a GitHub Repository for further exploration and results from their experiments, showing the benefits of sentence window retrieval in terms of token usage, cost, answer relevance, context relevance, and groundedness.
## Contact Information
Prince Krampah can be reached out on various platforms including YouTube, Twitter, LinkedIn, and Discord.
## Tags
The article is tagged with Llamaindex, Llamaindex Rag, Rag, Llm, and Sentence Window Retrieval.
## Additional Information
The article also includes links to the author's status, blog, privacy terms, text to speech, and teams.
#### Links:
  - [Open in app - rsci.app.link](https://rsci.app.link/?%24canonical_url=https%3A%2F%2Fmedium.com%2Fp%2F9f246cffa07b&%7Efeature=LoOpenInAppButton&%7Echannel=ShowPostUnderCollection&source=---two_column_layout_nav----------------------------------)
  - [hugging face - huggingface.co](https://huggingface.co/BAAI/bge-reranker-base)
  - [GitHub Repository - github.com](https://github.com/Princekrampah/AdvancedRAGTechniques_LlamaIndex)
  - [LinkedIn+www.linkedin.com in prince-krampah-5a2b92](https://www.linkedin.com/in/prince-krampah-5a2b921bb/?originalSubdomain=tz)
  - [Llamaindex+medium.com tag llamaindex?source=post_p](https://medium.com/tag/llamaindex?source=post_page-----9f246cffa07b---------------llamaindex-----------------)
  - [Llamaindex Rag - medium.com](https://medium.com/tag/llamaindex-rag?source=post_page-----9f246cffa07b---------------llamaindex_rag-----------------)
  - [Rag+medium.com tag rag?source=post_page-----9f246c](https://medium.com/tag/rag?source=post_page-----9f246cffa07b---------------rag-----------------)
  - [Llm+medium.com tag llm?source=post_page-----9f246c](https://medium.com/tag/llm?source=post_page-----9f246cffa07b---------------llm-----------------)
  - [Sentence Window Retrieval - medium.com](https://medium.com/tag/sentence-window-retrieval?source=post_page-----9f246cffa07b---------------sentence_window_retrieval-----------------)
  - [Status+medium.statuspage.io ?source=post_page-----](https://medium.statuspage.io/?source=post_page-----9f246cffa07b--------------------------------)
  - [Text to speech - speechify.com](https://speechify.com/medium?source=post_page-----9f246cffa07b--------------------------------)
  - [Teams+medium.com business?source=post_page-----9f2](https://medium.com/business?source=post_page-----9f246cffa07b--------------------------------)