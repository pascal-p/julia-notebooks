### Article Analysis: "Beyond English: Implementing a multilingual RAG solution"
#### Article Details
- **Title**: Beyond English: Implementing a multilingual RAG solution
- **Author**: Jesper Alkestrup
- **Publication Date**: December 20, 2023
- **Published In**: Towards Data Science
- **Reading Time**: 18 min read
- **Link**: [Article URL](https://towardsdatascience.com/beyond-english-implementing-a-multilingual-rag-solution-12ccba0428b6)
#### Introduction
The article by Jesper Alkestrup, titled "Beyond English: Implementing a multilingual RAG solution," provides a comprehensive guide on the considerations and steps necessary for developing non-English Retrieval Augmented Generation (RAG) systems. It emphasizes the importance of maintaining syntactic structure during data loading, efficient text splitting, and the selection of an appropriate embedding model. The guide also suggests fine-tuning embedding models with a Large Language Model (LLM) and implementing an LLM-based retrieval evaluation benchmark.
#### RAG Systems: A Brief Recap
RAG systems consist of two core components: the indexing phase and the generative phase. The indexing phase involves data loading, formatting, splitting, vectorization through embedding techniques, and storage within a knowledge base. The generative phase uses a user's query to extract relevant information from the knowledge base and formulates a response using an LLM.
#### Step-by-Step Guide for Non-English RAG Systems
1. **Data Loader Considerations**
   - The data loader should handle diverse formats and extract relevant content.
   - For text-based inputs, preserving syntactic integrity is crucial for accurate information retrieval.
   - The article compares the use of an HTML dataloader and a PDF dataloader, highlighting the importance of retaining structural information.
2. **Data Formatting**
   - The goal is to prepare data for text splitting by transforming complex structures into plain text with basic delimiters.
   - The article provides a Python function to format HTML content into a dictionary with title and text.
3. **Text Splitting**
   - Splitting text into appropriately sized chunks is guided by model constraints and retrieval effectiveness.
   - The article recommends starting with a simple rule-based splitter and provides an example using LangChain's RecursiveCharacterTextSplitter.
4. **Embedding Models**
   - The choice of embedding model is critical and should be multilingual or tailored to the specific language.
   - The article discusses the importance of asymmetric retrieval and suggests using the E5-multilingual family or the cohere-embed-multilingual-v3.0 model.
5. **Vector Databases**
   - After embedding, the data is stored in vector databases for retrieval.
   - The choice of vector storage is generally language-independent.
6. **The Generative Phase**
   - The generative phase involves embedding a user's query, performing a vector similarity search, and generating a response.
   - The article does not cover this phase in detail, as the considerations are less language-dependent.
#### Conclusion and Evaluation
The article concludes by emphasizing the complexity of optimizing a RAG system for a specific problem and language. It suggests creating a custom benchmark to evaluate different configurations and mentions that a future post will cover the creation of a retrieval benchmark.
#### Code Snippets
The article includes several Python code snippets demonstrating different aspects of the RAG system implementation:
- HTML Dataloader using `requests` and `BeautifulSoup`:
  ```python
  import requests
  from bs4 import BeautifulSoup
  url = "https://medium.com/llamaindex-blog/boosting-rag-picking-the-best-embedding-reranker-models-42d079022e83"
  soup = BeautifulSoup(requests.get(url).text, 'html.parser')
  filtered_tags = soup.find_all(['h1', 'h2', 'h3', 'h4', 'p'])
  filtered_tags[:14]
  ```
- PDF data loader using `PyPDF2`:
  ```python
  from PyPDF2 import PdfFileReader
  pdf = PdfFileReader(open('data/Boosting_RAG_Picking_the_Best_Embedding_&_Reranker_models.pdf','rb'))
  pdf.getPage(0).extractText()
  ```
- Function to format HTML content:
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
- Recursive character text splitter from LangChain:
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
- Embedding text chunks using Sentence Transformers:
  ```python
  from sentence_transformers import SentenceTransformer
  model = SentenceTransformer('intfloat/e5-large')
  prepended_split_texts = ["passage: " + text for text in split_texts]
  embeddings = model.encode(prepended_split_texts, normalize_embeddings=True)
  print(f'We now have {len(embeddings)} embeddings, each of size {len(embeddings[0])}')
  ```
#### References
The article references several resources related to RAG systems, embedding models, and vector databases. These include the Massive Text Embedding Benchmark (MTEB), LlamaIndex guides, and articles on improving RAG system performance.
### Final Remarks
The article by Jesper Alkestrup is a valuable resource for anyone looking to implement a multilingual RAG system. It provides practical advice, code examples, and references to further resources, making it a comprehensive guide for this complex task.
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