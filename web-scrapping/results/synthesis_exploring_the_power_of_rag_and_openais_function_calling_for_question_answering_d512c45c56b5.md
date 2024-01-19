### Article Analysis: RAG and OpenAI’s Function-Calling for Question-Answering with Langchain
#### Article Details
- **Title:** RAG and OpenAI’s Function-Calling for Question-Answering with Langchain
- **Author:** Dipankar Medhi
- **Date of Publication:** July 16, 2023
- **Reading Time:** 7 minutes
- **Link to Article:** [Medium Article](https://dipankarmedh1.medium.com/exploring-the-power-of-rag-and-openais-function-calling-for-question-answering-d512c45c56b5)
#### Introduction
The article by Dipankar Medhi, published on July 16, 2023, is a comprehensive two-part discussion on the use of Retrieval Augmented Generation (RAG) for question-answering systems and the application of OpenAI's latest function-calling method. It aims to provide insights into streamlining the question-answering process by leveraging these advanced technologies.
#### Retrieval Augmented Generation for Question-answering
RAG is a novel approach that enhances question-answering models by combining extractive and generative methods. It involves a retriever that selects relevant documents from a knowledge base and a generator that formulates answers based on these documents and the original question. This technique allows for the inclusion of external data from various sources, such as document repositories, databases, or APIs, into the language model's context, improving the relevance and accuracy of the generated responses.
#### Q&A Application Using OpenAI
The article outlines a practical guide to building a Q&A application using RAG concepts. It describes the process of text extraction from PDF documents using packages like PyPDF2, pdf2image, and pytesseract. The extracted text is then split into smaller chunks to be processed by the language model. These chunks are converted into embeddings and stored in a vector database, such as Chroma or FAISS, creating a knowledge hub. A large language model (LLM) is then used to retrieve relevant answers from this knowledge hub using a RAG pipeline.
#### Code Snippets
The article includes several Python code snippets that illustrate the implementation of the discussed concepts:
1. Extracting data from scanned PDFs:
```python
def extract_data_from_scanned_pdf(file_path: str) -> str:
  data = ""
  config = r'--oem 2 --psm 6'
  images = convert_from_path(file_path)
  for i in range(len(images)):
    img = np.array(images[i])
    data += pytesseract.image_to_string(img, config=config)
  return data
```
2. Splitting text into smaller chunks:
```python
def get_data_chunks(data: str, chunk_size: int):
  text_splitter = CharacterTextSplitter(chunk_size=chunk_size, chunk_overlap=5, separator="\n", length_function=len)
  chunks = text_splitter.split_text(data)
  return chunks
```
3. Creating the knowledge hub or database:
```python
def create_knowledge_hub(chunks: list):
  embeddings = OpenAIEmbeddings()
  knowledge_hub = FAISS.from_texts(chunks, embeddings)
  return knowledge_hub
```
4. Using Q&A chain for information retrieval:
```python
def get_answer_LLM(
  question: str,
  data: str,
  chunk_size: int = 1000,
  chain_type: str = 'stuff',
) -> str:
  if data == "":
    return ""
  chunks = get_data_chunks(data, chunk_size=chunk_size)  # create text chunks
  knowledge_hub = create_knowledge_hub(chunks)  # create knowledge hub
  retriever = knowledge_hub.as_retriever(
    search_type="similarity", search_kwargs={"k": 2}
  )
  chain = RetrievalQA.from_chain_type(
    llm=OpenAI(temperature=0.3, model_name="text-davinci-003"),
    chain_type=chain_type,
    retriever=retriever,
    return_source_documents=True,
  )
  result = chain({"query": question})
  return result['result']
```
5. Generating messages and retrieving arguments using OpenAI's function-calling:
```python
def message_generate(data:str) -> List[Dict[str, str]]:
  prompt = f"Please extract information from this given data: {data}." # create the prompt
  messages = [{"role": "user", "content": prompt}]
  return messages
def function_call(
  data: str,
  functions:List[Dict[str, any]],
  model:str ="gpt-3.5-turbo-0613",
  function_call:str="auto"
) -> Dict:
  arguments = {}
  message = message_generate(data) # create the message
  response = openai.ChatCompletion.create(
    model="gpt-3.5-turbo-16k",
    messages=message,
    functions=functions,
    function_call="auto"
  )
  arguments = eval(response.choices[0]["message"]["function_call"]["arguments"]) # convert to dic
  return arguments
```
6. Defining functions for information retrieval:
```python
functions = [
  {
    "name": "get_answers",
    "description": "Get the answers of the questions asked",
    "parameters": {
      "type": "object",
      "properties": {
        "What is the date of the lease?": {
          "type": "string",
          "description": "Date of the lease document",
        },
        "What is the length of the tenancy?": {
          "type": "string",
          "description": "The length of the tenancy"
        },
        "What is the address of the property being leased?": {
          "type": "string",
          "description": "The address of the property that is being leased"
        },
      },
      "required": [
        "What is the date of the lease?",
        "What is the length of the tenancy?",
        "What is the address of the property being leased?",
      ],
    }
  }
]
```
#### Conclusion
The article concludes by emphasizing the transformative impact of RAG and OpenAI's function-calling on data extraction, information retrieval, and answer generation. These methods significantly enhance the efficiency and accuracy of analyzing large data sets in question-answering systems. The author anticipates further advancements in these technologies, which will continue to innovate the field of data analysis and information retrieval.
#### Additional Resources
The author, Dipankar Medhi, encourages readers to follow him for more content on LLM and machine learning and provides links to his other blogs on related topics.
#### Links:
  - [Open in app](https://rsci.app.link/?%24canonical_url=https%3A%2F%2Fmedium.com%2Fp%2Fd512c45c56b5&%7Efeature=LoOpenInAppButton&%7Echannel=ShowPostUnderUser&source=---two_column_layout_nav----------------------------------)
  - [Retrieval-Augmented Generation for Knowledge-Inten](https://arxiv.org/pdf/2005.11401.pdf)
  - [Dipankar Medhi](https://medium.com/u/f27c01446dd8?source=post_page-----d512c45c56b5--------------------------------)
  - [OpenAI](https://medium.com/tag/openai?source=post_page-----d512c45c56b5---------------openai-----------------)
  - [ChatGPT](https://medium.com/tag/chatgpt?source=post_page-----d512c45c56b5---------------chatgpt-----------------)
  - [Machine Learning](https://medium.com/tag/machine-learning?source=post_page-----d512c45c56b5---------------machine_learning-----------------)
  - [AI](https://medium.com/tag/ai?source=post_page-----d512c45c56b5---------------ai-----------------)
  - [Programming](https://medium.com/tag/programming?source=post_page-----d512c45c56b5---------------programming-----------------)
  - [https://www.linkedin.com/in/dipankarmedhi/](https://www.linkedin.com/in/dipankarmedhi/)
  - [Status](https://medium.statuspage.io/?source=post_page-----d512c45c56b5--------------------------------)
  - [Text to speech](https://speechify.com/medium?source=post_page-----d512c45c56b5--------------------------------)
  - [Teams](https://medium.com/business?source=post_page-----d512c45c56b5--------------------------------)