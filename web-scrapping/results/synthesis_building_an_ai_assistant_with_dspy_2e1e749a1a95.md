### Building an AI Assistant with DSPy
#### Introduction
The article titled "Building an AI Assistant with DSPy," published on March 7, 2024, delves into the challenges of prompt engineering with Large Language Models (LLMs) and introduces DSPy, a high-level programming framework designed to simplify the development of LLM-based applications. The author expresses frustration with the brittle nature of prompts and the tedious process of prompt tuning, advocating for a more programmable approach to leveraging LLMs.
#### Main Content
##### Disdain for Prompt Engineering
The author begins by highlighting the inherent issues with prompt engineering, such as its susceptibility to minor changes leading to significant output variations. This section underscores the author's preference for a more deterministic approach to programming, as opposed to the ambiguous and often unreliable process of crafting prompts for LLMs.
##### Introduction to DSPy
DSPy is presented as a solution to the challenges of prompt engineering. It allows developers to build and tune LLM agent pipelines programmatically, without directly dealing with the intricacies of prompt crafting. This framework aims to streamline the development of AI assistants by abstracting away the complexity of interacting with LLMs.
##### Building an AI Assistant
The author illustrates the use of DSPy through the development of an AI assistant for the card game bridge. This example serves to demonstrate how DSPy can facilitate the creation of AI assistants that assist humans in various tasks, such as information retrieval, document analysis, and error identification. The choice of bridge as a use case highlights the framework's applicability to domains with specialized jargon and complex decision-making processes.
##### Agent Framework
DSPy enables the construction of an agent framework where backend services are invoked via agents built using language models. This architecture promotes decoupling and specialization, allowing the AI assistant to focus on intent handling and routing without needing to understand the underlying processes.
##### Zero Shot Prompting with DSPy
A practical example of using DSPy for zero-shot prompting is provided, showcasing how to define a subclass of `dspy.Module` for answering questions related to bridge. This example emphasizes DSPy's LLM-agnostic nature and its ability to abstract prompt engineering.
```python
class ZeroShot(dspy.Module):
  """
  Provide answer to question
  """
  def __init__(self):
    super().__init__()
    self.prog = dspy.Predict("question -> answer")
  def forward(self, question):
    return self.prog(question="In the game of bridge, " + question)
```
The process of configuring DSPy with an LLM and invoking the module is also illustrated, further highlighting the framework's ease of use.
##### Text Extraction
The article continues with an exploration of DSPy's capabilities in entity extraction, using the task of identifying bridge jargon as an example. This section demonstrates how DSPy can simplify the integration of LLMs for specific text analysis tasks.
```python
class Terms(dspy.Signature):
  """
  List of extracted entities
  """
  prompt = dspy.InputField()
  terms = dspy.OutputField(format=list)
class FindTerms(dspy.Module):
  """
  Extract bridge terms from a question
  """
  def __init__(self):
    super().__init__()
    self.entity_extractor = dspy.Predict(Terms)
  def forward(self, question):
    max_num_terms = max(1, len(question.split())//4)
    instruction = f"Identify up to {max_num_terms} terms in the following question that are jargon in the card game bridge."
    prediction = self.entity_extractor(
      prompt=f"{instruction}\n{question}"
    )
    return prediction.terms
```
##### Retrieval-Augmented Generation (RAG)
The article briefly mentions DSPy's support for various retrieval mechanisms, including ChromaDB, showcasing the framework's versatility in incorporating external data sources into the AI assistant's workflow.
##### Orchestration
The orchestration of different agent modules within DSPy is discussed, with a focus on building an orchestrator LLM that manages the invocation of agents based on user commands or triggers.
```python
class AdvisorSignature(dspy.Signature):
  definitions = dspy.InputField(format=str)  # function to call on input to make it a string
  bidding_system = dspy.InputField(format=str) # function to call on input to make it a string
  question = dspy.InputField()
  answer = dspy.OutputField()
class BridgeBiddingAdvisor(dspy.Module):
  """
  Functions as the orchestrator. All questions are sent to this module.
  """
  def __init__(self):
    super().__init__()
    self.find_terms = FindTerms()
    self.definitions = Definitions()
    self.prog = dspy.ChainOfThought(AdvisorSignature, n=3)
  def forward(self, question):
    terms = self.find_terms(question)
    definitions = [self.definitions(term) for term in terms]
    bidding_system = bidding_rag(question)
    prediction = self.prog(definitions=definitions,
                           bidding_system=bidding_system,
                           question="In the game of bridge, " + question,
                           max_tokens=-1024)
    return prediction.answer
```
##### Optimizer
The article concludes with a discussion on DSPy's Optimizer feature, which automatically tunes prompts based on example data. This capability is showcased through the improvement of responses in a bridge bidding use case, demonstrating DSPy's potential to enhance the performance of AI assistants through data-driven optimization.
#### Conclusion
The article presents DSPy as a powerful framework for developing AI assistants, offering a programmable approach to leveraging LLMs without the need for manual prompt engineering. Through practical examples, the author demonstrates DSPy's capabilities in building, tuning, and optimizing AI agent pipelines, highlighting its potential to streamline the development of sophisticated AI applications.
#### Links:
  - [DSPy+github.com stanfordnlp dspy](https://github.com/stanfordnlp/dspy)
  - [entire code is on GitHub - github.com](https://github.com/lakshmanok/lakblogs/tree/main/bridge_bidding_advisor)
  - [bidding_advisor.py+github.com lakshmanok lakblogs ](https://github.com/lakshmanok/lakblogs/blob/main/bridge_bidding_advisor/bidding_advisor.py)
  - [machine_learning+medium.com tag machine-learning?s](https://medium.com/tag/machine-learning?source=post_page-----2e1e749a1a95---------------machine_learning-----------------)
  - [prompt_engineering+medium.com tag prompt-engineeri](https://medium.com/tag/prompt-engineering?source=post_page-----2e1e749a1a95---------------prompt_engineering-----------------)
  - [large_language_models+medium.com tag large-languag](https://medium.com/tag/large-language-models?source=post_page-----2e1e749a1a95---------------large_language_models-----------------)
  - [bridge+medium.com tag bridge?source=post_page-----](https://medium.com/tag/bridge?source=post_page-----2e1e749a1a95---------------bridge-----------------)
  - [programming+medium.com tag programming?source=post](https://medium.com/tag/programming?source=post_page-----2e1e749a1a95---------------programming-----------------)