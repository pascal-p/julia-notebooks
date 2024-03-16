### LLM Auto-Prompt & Chaining
#### Using DSPy with GPT 3.5 on Azure
- **Publication Date:** Oct 24, 2023
#### Main Content
The article discusses the concept of LLM (Large Language Models) auto-prompt and chaining, focusing on the use of DSPy with GPT 3.5 on Azure. It begins by providing context on prompting libraries, categorizing them into several archetypes based on their functionality and level of abstraction. These include libraries for prompt templating and generation, high-level application development, control over individual completions, and those that define inputs and targets for optimization or generation of prompts.
#### Prompt Development and Chaining
Prompt development and LLM chaining are highlighted as processes that often require extensive trial and error. The article introduces DSPy, a library that facilitates the development of higher-level tasks that self-optimize and evaluate tasks. The author demonstrates the core concepts of DSPy using a Kaggle Q&A dataset for question and answering, including setting up DSPy, loading and preprocessing data, and defining signatures for input and output of the LLM.
#### Code Examples
The article includes several code snippets demonstrating the setup and use of DSPy with GPT 3.5 on Azure. These snippets cover the configuration of DSPy with API keys and URLs, data preprocessing, and the definition and invocation of signatures for question answering. The examples progress from simple question answering to more sophisticated prompt structures that incorporate reasoning steps and retrieved context.
```python
turbo = dspy.OpenAI(api_key="",api_provider="azure",deployment_id="gpt35", api_version="2023-09-15-preview",
api_base="",model_type='chat')
colbertv2_wiki17_abstracts = dspy.ColBERTv2(url='http://20.102.90.50:2017/wiki17_abstracts')
dspy.settings.configure(lm=turbo, rm=colbertv2_wiki17_abstracts)
dspy.settings.configure(lm=turbo)
```
```python
df1 = pd.read_csv('data/S08_question_answer_pairs.txt', sep='\t')
df2 = pd.read_csv('data/S09_question_answer_pairs.txt', sep='\t')
test = pd.read_csv('data/S10_question_answer_pairs.txt', sep='\t', encoding = 'ISO-8859-1')
train = pd.concat([df1, df2], ignore_index=True)
train = train.rename(columns={"Question": "question", "Answer": "answer"})
test = test.rename(columns={"Question": "question", "Answer": "answer"})
```
```python
class BasicQA(dspy.Signature):
"""Answer questions with short factoid answers."""
question = dspy.InputField()
answer = dspy.OutputField(desc="often between 1 and 5 words")
```
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
#### Teleprompters and Evaluation
The article introduces the concept of teleprompters, which create and validate examples for inclusion in the prompt. A specific example using a few-shot solution for validation is provided, along with a demonstration of compiling a program with selected training data. The evaluation of the compiled program against a test set is discussed, noting the initial poor accuracy but acknowledging the potential for improvement through further refinement.
#### Conclusion
The article presents DSPy as a promising framework for applying machine learning concepts to the development and evaluation of prompts for large language models. Through detailed examples and explanations, it demonstrates how DSPy can facilitate the creation of sophisticated prompt structures and improve the robustness of LLM applications.
#### Links:
  - [Open in app - rsci.app.link](https://rsci.app.link/?%24canonical_url=https%3A%2F%2Fmedium.com%2Fp%2F60924329833f&%7Efeature=LoOpenInAppButton&%7Echannel=ShowPostUnderUser&source=---two_column_layout_nav----------------------------------)
  - [DSPy offers a framework - github.com](https://github.com/stanfordnlp/dspy)
  - [this notebook - github.com - DSPy%20Intro.ipynb](https://github.com/paulbruffett/DSPy/blob/main/DSPy%20Intro.ipynb)
  - [medium.com](https://medium.com/tag/llm?source=post_page-----60924329833f---------------llm-----------------)
  - [medium.com](https://medium.com/tag/llmops?source=post_page-----60924329833f---------------llmops-----------------)
  - [medium.statuspage.io](https://medium.statuspage.io/?source=post_page-----60924329833f--------------------------------)
  - [speechify.com](https://speechify.com/medium?source=post_page-----60924329833f--------------------------------)
  - [medium.com](https://medium.com/business?source=post_page-----60924329833f--------------------------------)