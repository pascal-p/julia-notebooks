### Article Analysis: "Beyond English: Implementing a multilingual RAG solution"
#### Article Details
- **Title**: Beyond English: Implementing a multilingual RAG solution
- **Author**: Jesper Alkestrup
- **Publication Date**: December 20, 2023
- **Published In**: Towards Data Science
- **Reading Time**: 18 min read
- **Link**: [Article URL](https://towardsdatascience.com/beyond-english-implementing-a-multilingual-rag-solution-12ccba0428b6)
#### Introduction
The article by Jesper Alkestrup, published in Towards Data Science, provides a comprehensive guide on implementing a non-English Retrieval Augmented Generation (RAG) system. It addresses the challenges and considerations unique to multilingual contexts and offers practical advice for each step of the process. The article is structured as a 6-step guide, focusing on the indexing phase of RAG systems, and assumes the reader has a basic understanding of embeddings, vectors, and tokens.
#### Key Points and Considerations for Multilingual RAG Systems
- **Data Loading**: It is crucial to maintain the syntactic structure during data loading for meaningful text segmentation. The article suggests using simple delimiters and rule-based text splitters for efficiency in multilingual contexts.
- **Embedding Model Selection**: When choosing an embedding model, consider multilingual capabilities and asymmetric retrieval performance. Fine-tuning with a Large Language Model (LLM) may be necessary for accuracy.
- **LLM-based Retrieval Evaluation**: Implementing an LLM-based retrieval evaluation benchmark is recommended for fine-tuning hyperparameters effectively.
#### Detailed Steps for Implementing a Multilingual RAG System
1. **Data Loader**: The article emphasizes the importance of preserving syntactic integrity during data loading, highlighting the limitations of machine learning-based segmentation tools for non-English languages. It provides examples of HTML and PDF data loaders, illustrating the potential loss of structural information with the latter.
   - **HTML Data Loader Example**:
     ```python
     import requests
     from bs4 import BeautifulSoup
     url = "https://medium.com/llamaindex-blog/boosting-rag-picking-the-best-embedding-reranker-models-42d079022e83"
     soup = BeautifulSoup(requests.get(url).text, 'html.parser')
     filtered_tags = soup.find_all(['h1', 'h2', 'h3', 'h4', 'p'])
     filtered_tags[:14]
     ```
2. **Data Formatting**: The article discusses the importance of formatting data to prepare it for text splitting, suggesting the use of basic delimiters to guide the text splitter. It provides a Python function example for formatting HTML content into a dictionary with title and text.
   - **Data Formatting Function Example**:
     ```python
     def format_html(tags):
       formatted_text = ""
       title = ""
     
       for tag in tags:
         if 'pw-post-title' in tag.get('class', []):
           title = tag.get_text()
         elif tag.name == 'p' and 'pw-post-body-paragraph' in tag.get('class', []):
           formatted_text += "\n"+ tag.get_text()
         elif tag.name in ['h1', 'h2', 'h3', 'h4']:
           formatted_text += "\n\n" + tag.get_text()
     
       return {title: formatted_text}
     formatted_document = format_html(filtered_tags)
     ```
3. **Text Splitting**: The article highlights the importance of splitting text into appropriately sized chunks, considering model constraints and retrieval effectiveness. It recommends starting with a simple rule-based splitter and provides an example using LangChain's recursive character text splitter.
   - **Text Splitting Example**:
     ```python
     from langchain.text_splitter import RecursiveCharacterTextSplitter
     from transformers import AutoTokenizer
     tokenizer = AutoTokenizer.from_pretrained("intfloat/e5-base-v2")
     def token_length_function(text_input):
       return len(tokenizer.encode(text_input, add_special_tokens=False))
     text_splitter = RecursiveCharacterTextSplitter(
       chunk_size = 128,
       chunk_overlap  = 0,
       length_function = token_length_function,
       separators = ["\n\n", "\n", ". ", "? ", "! "]
     )
     split_texts = text_splitter(formatted_document['Boosting RAG: Picking the Best Embedding & Reranker models'])
     ```
4. **Embedding Models**: The selection of the right embedding model is critical, with a focus on multilingual or language-specific models that excel in asymmetric retrieval. The article suggests using the top-performing multilingual model in the MTEB Retrieval benchmark and provides an example of embedding text using the Sentence Transformer library.
   - **Embedding Example**:
     ```python
     from sentence_transformers import SentenceTransformer
     model = SentenceTransformer('intfloat/e5-large')
     prepended_split_texts = ["passage: " + text for text in split_texts]
     embeddings = model.encode(prepended_split_texts, normalize_embeddings=True)
     print(f'We now have {len(embeddings)} embeddings, each of size {len(embeddings[0])}')
     ```
5. **Vector Databases**: The article discusses the storage of vector embeddings for retrieval, noting that the choice of vector storage is generally unaffected by language. It recommends exploring resources for a comprehensive understanding of storage and search options.
6. **The Generative Phase**: The generative phase is not covered in detail in this article, as the considerations are less language-dependent. The article suggests that guides for English retrieval optimization are generally applicable to other languages.
#### Conclusion
The article concludes by stressing the importance of creating a custom benchmark for evaluating different configurations of a RAG system, especially for multilingual datasets. It promises a follow-up post on creating a well-performing retrieval benchmark.
#### References
The article lists several references for further reading on topics such as chunk size evaluation, embedding fine-tuning, and improving retrieval performance in RAG systems.
#### Code Snippets
The article includes several Python code snippets demonstrating the use of libraries such as BeautifulSoup, PyPDF2, LangChain, and Sentence Transformers for various steps in the RAG system implementation process.
#### Acknowledgements
The author, Jesper Alkestrup, encourages readers to provide feedback and acknowledges the reader's time spent on the article.
### Code Snippets Delivered Verbatim
#### HTML Data Loader Example
```python
import requests
from bs4 import BeautifulSoup
url = "https://medium.com/llamaindex-blog/boosting-rag-picking-the-best-embedding-reranker-models-42d079022e83"
soup = BeautifulSoup(requests.get(url).text, 'html.parser')
filtered_tags = soup.find_all(['h1', 'h2', 'h3', 'h4', 'p'])
filtered_tags[:14]
```
#### Data Formatting Function Example
```python
def format_html(tags):
  formatted_text = ""
  title = ""
  for tag in tags:
    if 'pw-post-title' in tag.get('class', []):
      title = tag.get_text()
    elif tag.name == 'p' and 'pw-post-body-paragraph' in tag.get('class', []):
      formatted_text += "\n"+ tag.get_text()
    elif tag.name in ['h1', 'h2', 'h3', 'h4']:
      formatted_text += "\n\n" + tag.get_text()
  return {title: formatted_text}
formatted_document = format_html(filtered_tags)
```
#### Text Splitting Example
```python
from langchain.text_splitter import RecursiveCharacterTextSplitter
from transformers import AutoTokenizer
tokenizer = AutoTokenizer.from_pretrained("intfloat/e5-base-v2")
def token_length_function(text_input):
  return len(tokenizer.encode(text_input, add_special_tokens=False))
text_splitter = RecursiveCharacterTextSplitter(
  chunk_size = 128,
  chunk_overlap  = 0,
  length_function = token_length_function,
  separators = ["\n\n", "\n", ". ", "? ", "! "]
)
split_texts = text_splitter(formatted_document['Boosting RAG: Picking the Best Embedding & Reranker models'])
```
#### Embedding Example
```python
from sentence_transformers import SentenceTransformer
model = SentenceTransformer('intfloat/e5-large')
prepended_split_texts = ["passage: " + text for text in split_texts]
embeddings = model.encode(prepended_split_texts, normalize_embeddings=True)
print(f'We now have {len(embeddings)} embeddings, each of size {len(embeddings[0])}')
```
The synthesis captures the essence of the article, providing a structured and detailed overview of the considerations and steps involved in implementing a multilingual RAG system. It preserves the logical flow and technical details presented by the author, ensuring a comprehensive understanding of the subject matter.
#### Links:
  - [Open in app](https://rsci.app.link/?%24canonical_url=https%3A%2F%2Fmedium.com%2Fp%2F12ccba0428b6&%7Efeature=LoOpenInAppButton&%7Echannel=ShowPostUnderCollection&source=---two_column_layout_nav----------------------------------)
  - [medium.com](https://medium.com/?source=---two_column_layout_nav----------------------------------)
  - [medium.com](https://medium.com/search?source=---two_column_layout_nav----------------------------------)
  - [medium.com](https://medium.com/@jalkestrup?source=post_page-----12ccba0428b6--------------------------------)
  - [Whisper v3](https://github.com/openai/whisper)
  - [Fleurs](https://huggingface.co/datasets/google/fleurs)
  - [medium article](https://blog.llamaindex.ai/boosting-rag-picking-the-best-embedding-reranker-models-42d079022e83)
  - [LangChain](https://python.langchain.com/docs/modules/data_connection/document_loaders/html)
  - [Multi QA base from SBERT](https://huggingface.co/sentence-transformers/multi-qa-mpnet-base-dot-v1)
  - [Evaluating the Ideal Chunk Size for RAG System using Llamaindex](https://blog.llamaindex.ai/evaluating-the-ideal-chunk-size-for-a-rag-system-using-llamaindex-6207e5d3fec5)
  - [Building RAG-based LLM Applications for Production](https://www.anyscale.com/blog/a-comprehensive-guide-for-building-rag-based-llm-applications-part-1?utm_source=gradientflow&utm_medium=newsletter#chunk-data)
  - [LangChain](https://python.langchain.com/docs/modules/data_connection/document_transformers/text_splitters/recursive_text_splitter)
  - [Massive Text Embedding Benchmark (MTEB)](https://huggingface.co/spaces/mteb/leaderboard)
  - [LlamaIndex provides a guide here](https://blog.llamaindex.ai/fine-tuning-embeddings-for-rag-with-synthetic-data-e534409a3971)
  - [Tools like LlamaIndex provide built-in functions for this purpose](https://docs.llamaindex.ai/en/stable/examples/evaluation/retrieval/retriever_eval.html)
  - [Artificial Intelligence](https://medium.com/tag/artificial-intelligence?source=post_page-----12ccba0428b6---------------artificial_intelligence-----------------)
  - [Data Science](https://medium.com/tag/data-science?source=post_page-----12ccba0428b6---------------data_science-----------------)
  - [Large Language Models](https://medium.com/tag/large-language-models?source=post_page-----12ccba0428b6---------------large_language_models-----------------)
  - [Programming](https://medium.com/tag/programming?source=post_page-----12ccba0428b6---------------programming-----------------)
  - [Machine Learning](https://medium.com/tag/machine-learning?source=post_page-----12ccba0428b6---------------machine_learning-----------------)
  - [Status](https://medium.statuspage.io/?source=post_page-----12ccba0428b6--------------------------------)
  - [Blog](https://blog.medium.com/?source=post_page-----12ccba0428b6--------------------------------)
  - [Text to speech](https://speechify.com/medium?source=post_page-----12ccba0428b6--------------------------------)
  - [Teams](https://medium.com/business?source=post_page-----12ccba0428b6--------------------------------)