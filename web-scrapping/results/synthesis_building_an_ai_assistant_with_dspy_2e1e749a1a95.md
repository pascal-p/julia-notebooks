### Title: Building an AI Assistant with DSPy
#### Main
**Introduction to DSPy and the Problem with Prompt Engineering**
The article begins by expressing the author's frustration with prompt engineering in the context of working with Large Language Models (LLMs). The author criticizes the brittleness of prompts and the shift from precise programming languages to ambiguous natural language instructions. This sets the stage for introducing DSPy, a high-level programming framework designed to alleviate these issues by allowing developers to build agent pipelines programmatically without directly dealing with prompts, and to tune these pipelines in a data-driven and LLM-agnostic manner.
**Building an AI Assistant with DSPy**
The author proposes building an AI assistant as a way to demonstrate the capabilities of DSPy. An AI assistant is defined as a computer program that assists humans in tasks, ideally working on behalf of the user. The author outlines the typical functionalities of an AI assistant, including information retrieval, document analysis, form filling, parameter collection, function calling, and error identification. The use case chosen for illustration is an AI assistant for bridge bidding, chosen for its complexity and relevance to potential real-world applications.
**Agent Framework**
The article describes the agent framework used by the AI assistant, which relies on backend services invoked via agents built using language models. This framework allows for decoupling and specialization, with agents capable of reasoning, searching, and performing non-textual work. The AI assistant acts as a fluent and coherent LLM that routes intents and is supported by a policy or guardrails LLM for filtering.
**Zero Shot Prompting with DSPy**
The author introduces the concept of Zero Shot prompting with DSPy, providing a Python code snippet to illustrate how DSPy facilitates interaction with an LLM to answer questions. The code demonstrates how to subclass `dspy.Module`, set up a language model module, and write a `forward()` method that processes inputs and returns outputs. The process is shown to be LLM-agnostic, emphasizing the ease of use and flexibility of DSPy.
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
The article then shows how to initialize DSPy with an LLM and invoke the module to get a response, highlighting the simplicity of changing LLMs within DSPy.
```python
gemini = dspy.Google("models/gemini-1.0-pro",
api_key=api_key,
temperature=temperature)
dspy.settings.configure(lm=gemini, max_tokens=1024)
module = ZeroShot()
response = module("What is Stayman?")
print(response)
```
**Text Extraction and RAG**
Further elaborating on DSPy's capabilities, the author discusses text extraction using LLMs for entity extraction, providing another Python code snippet as an example. The article also mentions DSPy's built-in support for various retrievers, including ChromaDB, and how these can be integrated into the AI assistant's workflow.
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
**Orchestration and Optimizer**
The article concludes with a discussion on orchestrating the various agent modules using another Python code snippet and introduces the concept of optimizing the entire pipeline using DSPy's teleprompter (soon to be renamed Optimizer). This optimization process is data-driven, based on example data, and aims to fine-tune the prompts for improved performance.
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
The article presents a compelling case for the use of DSPy in building AI assistants, emphasizing its ability to abstract away the complexities of prompt engineering and LLM interaction, thereby allowing developers to focus on the logic and functionality of their applications.
#### Links:
  - [Open in app - rsci.app.link](https://rsci.app.link/?%24canonical_url=https%3A%2F%2Fmedium.com%2Fp%2F2e1e749a1a95&%7Efeature=LoOpenInAppButton&%7Echannel=ShowPostUnderCollection&source=---two_column_layout_nav----------------------------------)
  - [DSPy+github.com stanfordnlp dspy](https://github.com/stanfordnlp/dspy)
  - [entire code is on GitHub - github.com](https://github.com/lakshmanok/lakblogs/tree/main/bridge_bidding_advisor)
  - [bidding_advisor.py+github.com lakshmanok lakblogs ](https://github.com/lakshmanok/lakblogs/blob/main/bridge_bidding_advisor/bidding_advisor.py)
  - [medium.com](https://medium.com/tag/machine-learning?source=post_page-----2e1e749a1a95---------------machine_learning-----------------)
  - [medium.com](https://medium.com/tag/prompt-engineering?source=post_page-----2e1e749a1a95---------------prompt_engineering-----------------)
  - [medium.com](https://medium.com/tag/large-language-models?source=post_page-----2e1e749a1a95---------------large_language_models-----------------)
  - [medium.com](https://medium.com/tag/bridge?source=post_page-----2e1e749a1a95---------------bridge-----------------)
  - [medium.com](https://medium.com/tag/programming?source=post_page-----2e1e749a1a95---------------programming-----------------)
  - [medium.statuspage.io](https://medium.statuspage.io/?source=post_page-----2e1e749a1a95--------------------------------)
  - [speechify.com](https://speechify.com/medium?source=post_page-----2e1e749a1a95--------------------------------)
  - [medium.com](https://medium.com/business?source=post_page-----2e1e749a1a95--------------------------------)