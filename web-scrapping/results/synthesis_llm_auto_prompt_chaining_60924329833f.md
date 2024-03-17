### Title: LLM Auto-Prompt & Chaining
### Main
#### LLM Auto-Prompt & Chaining
Using DSPy with GPT 3.5 on Azure
- 13 min read
- Oct 24, 2023
#### Context on Prompting Libraries
There are several LLM library archetypes:
- Thin wrappers for prompt templating and generation with minimal abstraction. Example: MiniChain.
- High-level application development with pre-built modules for easy integration. Example: LangChain, LlamaIndex.
- Control over individual completions, allowing for specific schemas and constraints. Example: Guidance, LMQL, RELM, Outlines.
- Definition of inputs, targets, and high-level operators for optimized prompt generation. Example: DSPy.
Prompt development and chaining require trial and error for higher-level task optimization and evaluation.
#### DSPy on Kaggle Q&A
Demonstration of DSPy concepts using Kaggle Q&A for question answering. Initial setup includes using GPT3.5-Turbo on Azure and configuring DSPy with a source for Wikipedia abstracts.
##### Setup DSPy
```python
turbo = dspy.OpenAI(api_key="", api_provider="azure", deployment_id="gpt35", api_version="2023-09-15-preview",
                    api_base="", model_type='chat')
colbertv2_wiki17_abstracts = dspy.ColBERTv2(url='http://20.102.90.50:2017/wiki17_abstracts')
dspy.settings.configure(lm=turbo, rm=colbertv2_wiki17_abstracts)
dspy.settings.configure(lm=turbo)
```
Configuration for GPT3.5-Turbo on Azure.
##### Data Pre-processing
```python
df1 = pd.read_csv('data/S08_question_answer_pairs.txt', sep='\t')
df2 = pd.read_csv('data/S09_question_answer_pairs.txt', sep='\t')
test = pd.read_csv('data/S10_question_answer_pairs.txt', sep='\t', encoding = 'ISO-8859-1')
train = pd.concat([df1, df2], ignore_index=True)
train = train.rename(columns={"Question": "question", "Answer": "answer"})
test = test.rename(columns={"Question": "question", "Answer": "answer"})
```
Loading and preprocessing data, focusing on questions and answers.
##### Signatures
Introduction to the concept of Signatures in DSPy, defining input and output fields for LLMs.
###### BasicQA Signature
```python
class BasicQA(dspy.Signature):
  """Answer questions with short factoid answers."""
  question = dspy.InputField()
  answer = dspy.OutputField(desc="often between 1 and 5 words")
```
Defines a simple prompt structure for question answering.
###### Using BasicQA
```python
# Define the predictor.
generate_answer = dspy.Predict(BasicQA)
example = train_ds.train[0]
# Call the predictor on a particular input.
pred = generate_answer(question=example.question)
# Print the input and the prediction.
print(f"Question: {example.question}")
print(f"Predicted Answer: {pred.answer}")
```
Demonstrates invoking the LLM with a BasicQA Signature.
###### Wrapping Signatures
```python
# Define the predictor. Notice we're just changing the class. The signature BasicQA is unchanged.
generate_answer_with_chain_of_thought = dspy.ChainOfThought(BasicQA)
# Call the predictor on the same input.
pred = generate_answer_with_chain_of_thought(question=example.question)
# Print the input, the chain of thought, and the prediction.
print(f"Question: {example.question}")
print(f"Thought: {pred.rationale.split('.', 1)[1].strip()}")
print(f"Predicted Answer: {pred.answer}")
```
Introduces a reasoning step in the prompt structure.
##### More Sophisticated Prompt Structure
```python
class GenerateAnswer(dspy.Signature):
  """Answer questions with short factoid answers."""
  context = dspy.InputField(desc="may contain relevant facts")
  question = dspy.InputField()
  answer = dspy.OutputField(desc="often between 1 and 5 words")
class RAG(dspy.Module):
  def __init__(self, num_passages=3):
    super().__init__()
    self.retrieve = dspy.Retrieve(k=num_passages)
    self.generate_answer = dspy.ChainOfThought(GenerateAnswer)
  def forward(self, question):
    context = self.retrieve(question).passages
    prediction = self.generate_answer(context=context, question=question)
    return dspy.Prediction(context=context, answer=prediction.answer)
```
Defines a more complex prompt structure with retrieved context.
#### Teleprompters
Introduction to Teleprompters for creating and validating examples for model instruction.
##### Using Teleprompters
```python
from dspy.teleprompt import BootstrapFewShot
# Validation logic: check that the predicted answer is correct.
# Also check that the retrieved context does actually contain that answer.
def validate_context_and_answer(example, pred, trace=None):
  answer_EM = dspy.evaluate.answer_exact_match(example, pred)
  answer_PM = dspy.evaluate.answer_passage_match(example, pred)
  return answer_EM and answer_PM
# Set up a basic teleprompter, which will compile our RAG program.
teleprompter = BootstrapFewShot(metric=validate_context_and_answer)
# Compile!
compiled_rag = teleprompter.compile(RAG(), trainset=trainset[100:150])
```
Demonstrates compiling a program with Teleprompters for prompt validation.
#### Evaluation
```python
from dspy.evaluate.evaluate import Evaluate
# Set up the `evaluate_on_hotpotqa` function. We'll use this many times below.
evaluate_on_hotpotqa = Evaluate(devset=testset[:50], num_threads=1, display_progress=True, display_table=5)
# Evaluate the `compiled_rag` program with the `answer_exact_match` metric.
metric = dspy.evaluate.answer_exact_match
evaluate_on_hotpotqa(compiled_rag, metric=metric)
```
Evaluates the compiled program, showing initial poor accuracy but highlighting potential for improvement.
##### Complex Signatures
Introduces a Signature for generating search queries to assist in answering complex questions.
###### GenerateSearchQuery Signature
```python
class GenerateSearchQuery(dspy.Signature):
  """Write a simple search query that will help answer a complex question."""
  context = dspy.InputField(desc="may contain relevant facts")
  question = dspy.InputField()
  query = dspy.OutputField()
```
Defines a Signature for generating search queries.
###### SimplifiedBaleen Module
```python
from dsp.utils import deduplicate
class SimplifiedBaleen(dspy.Module):
  def __init__(self, passages_per_hop=3, max_hops=2):
    super().__init__()
    self.generate_query = [dspy.ChainOfThought(GenerateSearchQuery) for _ in range(max_hops)]
    self.retrieve = dspy.Retrieve(k=passages_per_hop)
    self.generate_answer = dspy.ChainOfThought(GenerateAnswer)
    self.max_hops = max_hops
  def forward(self, question):
    context = []
    for hop in range(self.max_hops):
      query = self.generate_query[hop](context=context, question=question).query
      passages = self.retrieve(query).passages
      context = deduplicate(context + passages)
      pred = self.generate_answer(context=context, question=question)
      return dspy.Prediction(context=context, answer=pred.answer)
```
Defines a module for generating queries and answers based on chained tasks.
DSPy offers a framework for applying machine learning concepts to large language models, facilitating prompt development and evaluation.
#### Links:
  - [DSPy offers a framework - github.com](https://github.com/stanfordnlp/dspy)
  - [llmops+medium.com tag llmops?source=post_page-----](https://medium.com/tag/llmops?source=post_page-----60924329833f---------------llmops-----------------)
  - [this notebook - github.com - DSPy%20Intro.ipynb](https://github.com/paulbruffett/DSPy/blob/main/DSPy%20Intro.ipynb)
  - [llm+medium.com tag llm?source=post_page-----609243](https://medium.com/tag/llm?source=post_page-----60924329833f---------------llm-----------------)