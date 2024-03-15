### Title: LLM Auto-Prompt & Chaining
- **Author and date**: Using DSPy with GPT 3.5 on Azure
- **Link**: [Medium Article](https://paul-bruffett.medium.com/llm-auto-prompt-chaining-60924329833f)
#### Main Content
The article discusses various aspects of Large Language Models (LLMs) and their application through the DSPy framework, focusing on auto-prompting and chaining techniques.
##### Context on Prompting Libraries
Prompting libraries are categorized based on their functionality and level of abstraction:
1. **Thin Wrappers**: Libraries like MiniChain provide minimal abstraction for prompt templating and generation.
2. **High-Level Application Development**: Libraries such as LangChain and LlamaIndex offer pre-built modules for easy integration and application development.
3. **Control Over Completions**: Libraries like Guidance, LMQL, RELM, and Outlines allow for more control over the prompts, including enforcing schemas and constraining sampling.
4. **Optimized Prompt Development**: Libraries such as DSPy focus on defining inputs and targets, optimizing prompt stages.
##### DSPy on Kaggle Q&A
The article demonstrates the use of DSPy for a Q&A application, starting with setting up DSPy and configuring it to use GPT3.5-Turbo deployed on Azure and ColBERTv2 for accessing Wikipedia abstracts.
```python
turbo = dspy.OpenAI(api_key="", api_provider="azure", deployment_id="gpt35", api_version="2023-09-15-preview",
api_base="", model_type='chat')
colbertv2_wiki17_abstracts = dspy.ColBERTv2(url='http://20.102.90.50:2017/wiki17_abstracts')
dspy.settings.configure(lm=turbo, rm=colbertv2_wiki17_abstracts)
dspy.settings.configure(lm=turbo)
```
Data preprocessing involves loading, renaming fields, and concatenating datasets.
```python
df1 = pd.read_csv('data/S08_question_answer_pairs.txt', sep='\t')
df2 = pd.read_csv('data/S09_question_answer_pairs.txt', sep='\t')
test = pd.read_csv('data/S10_question_answer_pairs.txt', sep='\t', encoding = 'ISO-8859-1')
train = pd.concat([df1, df2], ignore_index=True)
train = train.rename(columns={"Question": "question", "Answer": "answer"})
test = test.rename(columns={"Question": "question", "Answer": "answer"})
```
##### Signatures and Predictors
The concept of Signatures in DSPy is introduced, defining the input and output structure for the LLM. BasicQA and GenerateAnswer classes are examples of such signatures.
```python
class BasicQA(dspy.Signature):
  """Answer questions with short factoid answers."""
  question = dspy.InputField()
  answer = dspy.OutputField(desc="often between 1 and 5 words")
```
Predictors are used to invoke these signatures on inputs, generating answers based on the defined structure.
```python
generate_answer = dspy.Predict(BasicQA)
example = train_ds.train[0]
pred = generate_answer(question=example.question)
print(f"Question: {example.question}")
print(f"Predicted Answer: {pred.answer}")
```
##### Chaining and Teleprompters
The article further explores chaining signatures for more complex prompt structures and introduces Teleprompters for creating and validating examples to instruct the model.
```python
from dspy.teleprompt import BootstrapFewShot
def validate_context_and_answer(example, pred, trace=None):
  answer_EM = dspy.evaluate.answer_exact_match(example, pred)
  answer_PM = dspy.evaluate.answer_passage_match(example, pred)
  return answer_EM and answer_PM
teleprompter = BootstrapFewShot(metric=validate_context_and_answer)
compiled_rag = teleprompter.compile(RAG(), trainset=trainset[100:150])
```
##### Evaluation and Advanced Signatures
The evaluation of the model's performance and the introduction of more complex signatures like GenerateSearchQuery and SimplifiedBaleen are discussed. These advanced techniques allow for generating queries and incorporating retrieved context into the prompts for more accurate answers.
```python
from dspy.evaluate.evaluate import Evaluate
evaluate_on_hotpotqa = Evaluate(devset=testset[:50], num_threads=1, display_progress=True, display_table=5)
metric = dspy.evaluate.answer_exact_match
evaluate_on_hotpotqa(compiled_rag, metric=metric)
```
##### Conclusion
The article highlights DSPy's potential in applying machine learning concepts to LLMs, facilitating the development and evaluation of prompts. It showcases how DSPy can make prompt development less brittle and more adaptable to changes.
#### Links
- [Open in app](https://rsci.app.link/?%24canonical_url=https%3A%2F%2Fmedium.com%2Fp%2F60924329833f&%7Efeature=LoOpenInAppButton&%7Echannel=ShowPostUnderUser&source=---two_column_layout_nav----------------------------------)
- [DSPy Framework on GitHub](https://github.com/stanfordnlp/dspy)
- [DSPy Intro Notebook](https://github.com/paulbruffett/DSPy/blob/main/DSPy%20Intro.ipynb)
- Additional references to Medium tags and pages related to LLM and business.
#### Links:
  - [Open in app - rsci.app.link](https://rsci.app.link/?%24canonical_url=https%3A%2F%2Fmedium.com%2Fp%2F60924329833f&%7Efeature=LoOpenInAppButton&%7Echannel=ShowPostUnderUser&source=---two_column_layout_nav----------------------------------)
  - [DSPy offers a framework - github.com](https://github.com/stanfordnlp/dspy)
  - [this notebook - github.com - DSPy%20Intro.ipynb](https://github.com/paulbruffett/DSPy/blob/main/DSPy%20Intro.ipynb)
  - [medium.com](https://medium.com/tag/llm?source=post_page-----60924329833f---------------llm-----------------)
  - [medium.com](https://medium.com/tag/llmops?source=post_page-----60924329833f---------------llmops-----------------)
  - [medium.statuspage.io](https://medium.statuspage.io/?source=post_page-----60924329833f--------------------------------)
  - [speechify.com](https://speechify.com/medium?source=post_page-----60924329833f--------------------------------)
  - [medium.com](https://medium.com/business?source=post_page-----60924329833f--------------------------------)