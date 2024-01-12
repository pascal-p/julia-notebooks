# Article Synthesis: Exploring LangChain and LlamaIndex for Standardization and Interoperability in LLMs
## Article Details
- **Title**: Exploring LangChain and LlamaIndex to Achieve Standardization and Interoperability in Large Language Models
- **Author**: Majid
- **Publication**: Badal-io
- **Publication Date**: May 10, 2023
- **Reading Time**: 22 min read
- **Article Link**: [Exploring LangChain and LlamaIndex](https://medium.com/badal-io/exploring-langchain-and-llamaindex-to-achieve-standardization-and-interoperability-in-large-2b5f3fabc360)
## Introduction
The article discusses the rapid development of Large Language Models (LLMs) and introduces LangChain and LlamaIndex as tools that provide standardization and interoperability among these models. It emphasizes the complexity of LLMs and the challenges in their utilization, which these tools aim to address. The article also notes that the libraries are in their early stages and are frequently updated.
## Large Language Models (LLMs)
LLMs are machine learning models capable of generating human-like text and responding to natural language prompts. They are trained on extensive datasets and use statistical patterns to predict text sequences.
## LangChain Overview
LangChain is a response to the challenges posed by the complexity and frequent updates of LLMs. It aims to standardize interactions and enable interoperability among different LLM providers, such as Huggingface and Cohere.
### Building Blocks of LangChain
LangChain's components are categorized into several classes:
#### 1. System Messages and Human Messages
These are combined into prompts and sent to chat models, which return text responses wrapped in an `AIMessage`.
#### 2. Embedding Models
Embedding models create vector representations for texts, primarily used for semantic search. LangChain provides `embed_query` and `embed_document` methods to cater to different embedding methods used by LLM providers.
#### 3. Prompt Templates
LangChain utilizes carefully designed prompts for various tasks, such as querying a SQL database. It offers four categories of prompt templates, which can be found on [LangChainHub](https://github.com/hwchase17/langchain-hub).
#### 4. Example Selectors
LangChain allows for the selection of input examples for few-shot learning based on strategies like input length.
#### 5. Output Parsers
These parse the LLM output for downstream tasks, such as converting responses into CSV files.
### LangChain Classes
LangChain offers a variety of classes for different functionalities:
#### Document Loaders
These assist in loading documents from various sources and formats, using `Unstructured` under the hood.
#### Text Splitters
Text splitters chunk documents into coherent pieces to fit within LLM token size limitations.
#### VectorStores
These are databases for storing embedding vectors and provide semantic similarity search functionalities.
#### Retrievers
Retrievers are designed for document retrieval and can be used in chains requiring a retrieval component.
#### Memory Objects
LangChain provides memory objects for applications like chatbots to store interaction history.
#### Chains
Chains combine multiple components to create complex functionalities, such as combining prompts with LLM or chat models.
#### Agents
Agents decide which tools are relevant for each query and use them accordingly.
### LangChain Tools and Agents
LangChain tools have descriptions that agents use to determine their relevance to a query. An example is the `OpenWeatherMap-API` tool, which is described for the agent to decide its use.
## LlamaIndex Overview
LlamaIndex is a tool built on LangChain for searching and summarizing documents using a conversational interface with LLMs. It features graph indexes for efficient data organization.
### LlamaIndex Workflow
The workflow involves chunking a knowledge base into nodes to form a graph index, which is then queried to fetch relevant nodes and synthesize a response.
### Querying Index Graphs
Different index types, such as list and vector indexes, determine how nodes are retrieved for response synthesis.
### Response Synthesis Modes
LlamaIndex offers modes like `Create and refine`, `Tree summarize`, and `Compact` for generating responses based on the nodes retrieved.
### Composing Indexes
Indexes can be composed of other indexes, allowing for hierarchical organization of documents for better search results.
### Data Connectors and Loaders
LlamaIndex provides data connectors and loaders for various document sources, which can be customized for better accuracy.
### Query Transformations
Query transformations rephrase or decompose queries for more accurate answers.
### Node Post-Processors
These refine the set of selected nodes before response synthesis.
### Storage
LlamaIndex uses storage for vectors, nodes, and indexes, with options for in-memory and disk storage.
## Conclusion
LangChain and LlamaIndex are new libraries that offer standardization and interoperability for LLMs. LangChain provides granular control for a wide range of use cases, while LlamaIndex specializes in creating hierarchical indexes. Both libraries are under active development and may converge in the future.
## Code Examples
The article includes several Python code snippets demonstrating the use of LangChain and LlamaIndex components. These snippets are presented verbatim below:
### LangChain Code Examples
```python
from langchain.chat_models import ChatOpenAI
from langchain.schema import (
    AIMessage,
    HumanMessage,
    SystemMessage
)
chat = ChatOpenAI(temperature=0)
messages = [
    SystemMessage(content="You are a hilarious doctor."),
    HumanMessage(content="Describe chicken pox to me.")
]
chat(messages)
```
```python
from langchain import PromptTemplate
prompt = PromptTemplate(
    input_variables=["topic", "city"],
    template="Tell me a about {topic} in {city}."
)
prompt.format(topic="food", city="Rome")
# Tell me about food in Rome
```
```python
from langchain.document_loaders import TextLoader
loader = TextLoader('../state_of_the_union.txt')
documents = loader.load()
```
```python
from langchain.text_splitter import CharacterTextSplitter
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
texts = text_splitter.split_documents(documents)
```
```python
from langchain.embeddings import OpenAIEmbeddings
from langchain.vectorstores import Chroma
embedder = OpenAIEmbeddings()
db = Chroma.from_documents(texts, embedder)
output = db.similarity_search(query)
# This output would be a list of relevant documents
```
```python
from langchain.chains import RetrievalQA
from langchain.embeddings import OpenAIEmbeddings
from langchain.vectorstores import Chroma
from langchain.document_loaders import TextLoader
from langchain.text_splitter import CharacterTextSplitter
loader = TextLoader('../state_of_the_union.txt', encoding='utf8')
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
texts = text_splitter.split_documents(documents)
embedder = OpenAIEmbeddings()
db = Chroma.from_documents(texts, embeddings)
retriever = db.as_retriever()
qa = RetrievalQA.from_chain_type(llm=OpenAI(), chain_type="stuff", retriever=retriever)
query = "What did the president say about Ketanji Brown Jackson"
qa.run(query)
# This will return a chat like response for the query rather than only listing the relevant documents.
```
```python
from langchain.llm import LLM
from langchain.chat import ChatMessageHistory
# Create a new ChatMessageHistory object and add some messages
history = ChatMessageHistory()
history.add_user_message("Hello!")
history.add_ai_message("Hi there!")
history.add_user_message("How are you?")
# Create a new LLM object and train it on the chat history
llm = LLM()
llm(f"Given the history: {history.messages} tell me what the first human message was")
```
```python
from langchain.memory import ConversationBufferMemory
memory = ConversationBufferMemory()
memory.chat_memory.add_user_message("hi!")
memory.chat_memory.add_ai_message("whats up?")
print(memory.buffer)
# This will return: 'Human: hi!\nAI: whats up?'
# passing to a conversation chain to provide previous context:
from langchain.chains import ConversationChain
llm = OpenAI(temperature=0)
conversation = ConversationChain(
    llm=llm,
    verbose=True,
    memory=memory
)
conversation.predict(input="what was my first message to you?")
# This will predict:
# > Entering new ConversationChain chain...
# Prompt after formatting:
# The following is a friendly conversation between a human and an AI. The AI is talkative and provides lots of specific details from its context. If the AI does not know the answer to a question, it truthfully says it does not know.
# Current conversation:
# [HumanMessage(content='hi!', additional_kwargs={}), AIMessage(content='whats up?', additional_kwargs={})]
# Human: what was my first message to you?
# AI:
# > Finished chain.
# ' Your first message to me was "hi!"'
```
```python
from langchain.schema import messages_from_dict, messages_to_dict
dicts = messages_to_dict(history.messages)
# Output:
# [{'type': 'human', 'data': {'content': 'hi!', 'additional_kwargs': {}}},
#  {'type': 'ai', 'data': {'content': 'whats up?', 'additional_kwargs': {}}}]
loaded_history = messages_from_dict(dicts)
print(loaded_history)
# Output
# [HumanMessage(content='hi!', additional_kwargs={}),
#  AIMessage(content='whats up?', additional_kwargs={})]
```
```python
from langchain.prompts import PromptTemplate
from langchain.chains import LLMChain
from langchain.llms import OpenAI
llm = OpenAI(temperature=0.9)
prompt = PromptTemplate(
    input_variables=["continent"],
    template="Name one nice summer vacation spot in {continent}?"
)
chain = LLMChain(llm=llm, prompt=prompt)
print(chain.run("Europe"))
# This will output something like:
# French Riviera
```
```python
from langchain.chains import SimpleSequentialChain
overall_chain = SimpleSequentialChain(chains=[chain, chain2], verbose=True)
overall_chain.run("Europe")
# Output:
# > Entering new SimpleSequentialChain chain...
# The French Riviera.
# When in the French Riviera, you should definitely try some of the local specialties such as ratatouille, bouillabaisse, pissaladière, socca, and pan bagnat. You should also try some of the delicious seafood dishes like grilled sardines, anchovies, and sea bass. For dessert, try some of the local pastries like tarte tropézienne, calisson, and navettes. Bon appétit!
# > Finished chain.
# \n\nWhen in the French Riviera, you should definitely try some of the local specialties such as ratatouille, bouillabaisse, pissaladière, socca, and pan bagnat. You should also try some of the delicious seafood dishes like grilled sardines, anchovies, and sea bass. For dessert, try some of the local pastries like tarte tropézienne, calisson, and navettes. Bon appétit!
```
### LlamaIndex Code Examples
```python
from langchain.agents import load_tools
from langchain.agents import initialize_agent
from langchain.agents import AgentType
from langchain.llms import OpenAI
llm = OpenAI(temperature=0)
# load tools
tools = load_tools(['openweathermap-api', 'llm-math'], llm=llm)
# initialize agent
agent = initialize_agent(tools, llm, agent=AgentType.ZERO_SHOT_REACT_DESCRIPTION, verbose=True)
# call the agent with your query
agent.run("what is the temperature of today in Baja California in celcius to the power of two?")
```
```python
Storage_context = StorageContext.from_defaults(
    docstore = MongoDocumentStore.from_uri(uri="<mongodb+srv://...>")
    index_store = MongoIndexStore.from_uri(uri="<mongodb+srv://...>")
    Vector_store = PineconeVectorStore(config)
)
index = load_index_from_storage(storage_context, index_id="<index_id>")
```
## External Links and References
The article includes several external links and references:
- [LangChainHub](https://github.com/hwchase17/langchain-hub)
- [Official LangChain Documentation](https://python.langchain.com/en/latest/modules/indexes/getting_started.html)
- Various Medium sign-in and subscription links
- Medium-related links (help, status, jobs, blog, privacy policy, terms of service)
- [Speechify for Medium](https://speechify.com/medium)
## Conclusion
The article provides a comprehensive overview of LangChain and LlamaIndex, detailing their components, functionalities, and the potential for these tools to streamline the use of LLMs. The provided code snippets offer practical examples of how to implement these tools in Python. As these libraries continue to evolve, they may further integrate to offer a unified solution for LLM applications.