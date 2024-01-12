### Article Overview
**Title:** Exploring LangChain and LlamaIndex to Achieve Standardization and Interoperability in Large Language Models  
**Author and Date:** Majid, May 10, 2023  
**Publication:** Badal-io  
**Reading Time:** 22 min read  
**Link:** [Exploring LangChain and LlamaIndex](https://medium.com/badal-io/exploring-langchain-and-llamaindex-to-achieve-standardization-and-interoperability-in-large-2b5f3fabc360)
### Introduction
The article discusses the rapid development of Large Language Models (LLMs) and introduces two tools, LangChain and LlamaIndex, which aim to provide standardization and interoperability among these models. The author emphasizes that these tools are in their early stages and are updated frequently, which may affect the current applicability of the details provided.
### Large Language Models (LLMs)
LLMs are machine learning models capable of generating human-like text and responding to prompts in natural language. They are trained on extensive datasets and use statistical patterns to predict words or phrases that logically follow a given input.
### LangChain
LangChain is a response to the challenges posed by the complexity and frequent updates of LLMs. It aims to simplify the process of using these models by providing standardized interactions and interoperability, thus avoiding vendor lock-in and allowing users to switch between providers based on various factors.
#### Building Blocks of LangChain
LangChain's components are categorized into several classes and functionalities:
1. **System Messages and Human Messages:**
   - These messages are combined into a prompt and sent to the chat model, which returns a text response encapsulated in an `AIMessage`.
   - The documentation acknowledges that abstractions for chat models are still developing.
2. **Embedding Models:**
   - Embedding models create vector representations for texts, commonly used in semantic search.
   - LangChain provides methods `embed_query` and `embed_document` to cater to different embedding methods used by LLM providers.
3. **Prompt Templates:**
   - LangChain utilizes carefully designed prompts for various tasks, such as querying a SQL database in natural language.
   - There are four categories of prompt templates in LangChain, which can be explored on [LangChainHub](https://github.com/hwchase17/langchain-hub).
4. **Chat Prompt Templates:**
   - These templates are built upon `MessageTemplates` (`HumanMessages`, `AIMessages`, and `SystemMessages`), providing structure to conversational use cases.
5. **Example Selectors:**
   - LangChain allows users to select input examples for few-shot learning based on various strategies, such as input length.
6. **Output Parsers:**
   - These parsers format the output from LLMs for downstream tasks, such as parsing into a list of comma-separated values.
7. **Document Loaders:**
   - LangChain offers tools for loading documents from various sources and formats, utilizing `Unstructured` under the hood.
8. **Text Splitters:**
   - Due to token size limitations of LLMs, documents need to be split into coherent pieces, which LangChain facilitates through various splitters.
9. **VectorStores:**
   - These are databases for storing embedding vectors and exposing semantic similarity search functionalities.
10. **Retrievers:**
    - Related to VectorStore indexes, retrievers are designed specifically for document retrieval.
11. **Memory Objects:**
    - LangChain provides memory objects for applications like chatbots to maintain interaction history and context.
12. **Chains:**
    - Chains combine multiple components to create complex functionalities, such as combining prompts with LLMs or chat models.
13. **Agents:**
    - Agents decide which tools are relevant for each query and use them accordingly, provided they are given a list of tools.
14. **Tools:**
    - Tools can be off-the-shelf or custom-made, with descriptions that help agents decide their relevance to a query.
### LlamaIndex
LlamaIndex is a tool that leverages LangChain for searching and summarizing documents through a conversational interface. It uses graph indexes to organize data efficiently.
#### Workflow of LlamaIndex
1. **Knowledge Base:**
   - Documents are chunked and stored in node objects, forming a graph index.
2. **Graph Index:**
   - The index can be a list, tree, or keyword table, and can be composed of different indexes for hierarchical organization.
3. **Text Splitters:**
   - LlamaIndex uses LangChain's textSplitter classes to chunk documents.
4. **Querying Index Graph:**
   - Relevant nodes are fetched based on the query, and a `response_sythesis` module generates a coherent answer.
5. **Response Synthesis:**
   - Various modes are available, such as "Create and refine," "Tree summarize," and "Compact."
6. **Index Composition:**
   - Indexes can be composed from other indexes, allowing for hierarchical organization of data sources.
7. **Data Connectors and Loaders:**
   - LlamaIndex provides connectors and loaders for various data sources, which can be found on LlamaHub.
8. **Query Transformations:**
   - Queries can be transformed for more accurate answers using modules like HyDE, single-step, and multi-step query decomposition.
9. **Node Post-Processors:**
   - These refine the set of selected nodes after retrieval and before response synthesis.
10. **Storage:**
    - Storage for vectors, nodes, and the index itself is crucial, with options for in-memory and disk storage.
### Conclusion
LangChain and LlamaIndex are tools designed to enhance the usability and interoperability of LLMs. They offer a range of components and functionalities that cater to various use cases, from document retrieval to conversational interfaces. While LangChain provides granular control and covers a broader spectrum of applications, LlamaIndex specializes in creating hierarchical indexes for document management. Both libraries are under active development and may evolve to offer more consolidated solutions in the future.
### Python Code Snippets
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
from langchain import PromptTemplate
prompt = PromptTemplate(
    input_variables=["topic", "city"],
    template="Tell me a about {topic} in {city}."
)
prompt.format(topic="food", city="Rome")
# Tell me about food in Rome
systemTemplate = SystemMessagePromptTemplate.from_template("You are a helpful AI that talks about {topic} in {country}")
humanTemplate = HumanMessagePromptTemplate.from_template('{input}')
chatTemplate = ChatPromptTemplate.from_messages([systemTemplate, humanTemplate])
chatTemplate.format_prompt(topic="food", country="Italy", input="I like to learn a new recipe").to_messages()
# output would be: [AIMessage(content='You are a helpful AI that talks about food in Italy', additional_kwargs={}),
# HumanMessage(content='I like to learn a new recipe', additional_kwargs={})]
from langchain.document_loaders import TextLoader
loader = TextLoader('../state_of_the_union.txt')
documents = loader.load()
from langchain.text_splitter import CharacterTextSplitter
text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
texts = text_splitter.split_documents(documents)
from langchain.embeddings import OpenAIEmbeddings
from langchain.vectorstores import Chroma
embedder = OpenAIEmbeddings()
db = Chroma.from_documents(texts, embedder)
output = db.similarity_search(query)
# This output would be a list of relevant documents
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
prompt2 = PromptTemplate(
    input_variables=["destination"],
    template="What food should I try when in {destination}?"
)
chain2 = LLMChain(llm=llm, prompt=prompt2)
chain2.run("Ibiza")
# Output:
# Paella: This traditional Spanish dish is a must-try when in Ibiza. It is a rice dish cooked with seafood, vegetables, and spices.
from langchain.chains import SimpleSequentialChain
overall_chain = SimpleSequentialChain(chains=[chain, chain2], verbose=True)
overall_chain.run("Europe")
# Output:
# > Entering new SimpleSequentialChain chain...
# The French Riviera.
# When in the French Riviera, you should definitely try some of the local specialties such as ratatouille, bouillabaisse, pissaladière, socca, and pan bagnat. You should also try some of the delicious seafood dishes like grilled sardines, anchovies, and sea bass. For dessert, try some of the local pastries like tarte tropézienne, calisson, and navettes. Bon appétit!
# > Finished chain.
# \n\nWhen in the French Riviera, you should definitely try some of the local specialties such as ratatouille, bouillabaisse, pissaladière, socca, and pan bagnat. You should also try some of the delicious seafood dishes like grilled sardines, anchovies, and sea bass. For dessert, try some of the local pastries like tarte tropézienne, calisson, and navettes. Bon appétit!
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
### External Links and References
The article references several external links and resources:
- [LangChainHub](https://github.com/hwchase17/langchain-hub)
- [Official Documentation for LlamaIndex](https://python.langchain.com/en/latest/modules/indexes/getting_started.html)
- Various Medium sign-in and subscription links
- Medium-related resources such as help center, status page, jobs, blog, privacy policy, and terms of service
- A link to Speechify for Medium
### Conclusion
The article provides a comprehensive overview of LangChain and LlamaIndex, detailing their components and how they contribute to the standardization and interoperability of LLMs. It includes practical examples and Python code snippets to illustrate the usage of these tools. The synthesis captures the essence of the article, ensuring that the information is organized and presented in a coherent manner.