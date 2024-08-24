# Automating Prompt Engineering with DSPy and Haystack
## Introduction
**Title:** Automating Prompt Engineering with DSPy and Haystack  
**Author and Date:** Published on June 7, 2024  
**Main Idea:** The article discusses the challenges of manual prompt optimization in generative AI applications and introduces DSPy and Haystack as tools to automate and optimize this process. It focuses on using DSPy to teach a Large Language Model (LLM) to generate concise answers from an academic medical dataset.
## Overview of DSPy
DSPy is an open-source library designed to parameterize prompts, transforming prompt engineering into an optimization problem. It addresses the brittleness and scalability issues associated with manual prompt tuning. DSPy provides two main abstractions: **Signatures** and **Modules**. A signature defines the input and output of a system interacting with LLMs, which DSPy translates into prompts.
### Example of a DSPy Signature
```python
class Emotion(dspy.Signature):
  """Classify emotions in a sentence."""
  
  sentence = dspy.InputField()
  sentiment = dspy.OutputField(desc="Possible choices: sadness, joy, love, anger, fear, surprise.")
```
This signature is converted into a prompt by DSPy:
```python
Classify emotions in a sentence.
---
Follow the following format.
Sentence: ${sentence}
Sentiment: Possible choices: sadness, joy, love, anger, fear, surprise.
---
Sentence:
```
## Optimization with DSPy
DSPy modules define predictors with parameters that can be optimized, such as selecting few-shot examples. The optimization process, or "compiling" a module, involves specifying the module, a training set, and evaluation metrics. The **BootstrapFewShot** optimizer is used to search the parameter space.
### Simplified Bootstrap Few-Shot Algorithm
```python
class SimplifiedBootstrapFewShot(Teleprompter):
  def __init__(self, metric=None):
    self.metric = metric
  def compile(self, student, trainset, teacher=None):
    teacher = teacher if teacher is not None else student
    compiled_program = student.deepcopy()
    # Step 1. Prepare mappings between student and teacher Predict modules.
    assert student_and_teacher_have_compatible_predict_modules(student, teacher)
    name2predictor, predictor2name = map_predictors_recursively(student, teacher)
    # Step 2. Bootstrap traces for each Predict module.
    for example in trainset:
      if we_found_enough_bootstrapped_demos(): break
      with dspy.setting.context(compiling=True):
        prediction = teacher(**example.inputs())
        predicted_traces = dspy.settings.trace
        if self.metric(example, prediction, predicted_traces):
          for predictor, inputs, outputs in predicted_traces:
            d = dspy.Example(automated=True, **inputs, **outputs)
            predictor_name = self.predictor2name[id(predictor)]
            compiled_program[predictor_name].demonstrations.append(d)
    return compiled_program
```
## Building a Custom Haystack Pipeline
The article demonstrates building a Retrieval-Augmented Generation (RAG) pipeline using Haystack, an open-source library for LLM applications. The pipeline uses an in-memory document store and integrates with DSPy to optimize prompts for concise answers.
### Haystack RAG Pipeline Example
```python
from haystack.components.retrievers.in_memory import InMemoryBM25Retriever
from haystack.components.generators import OpenAIGenerator
from haystack.components.builders import PromptBuilder
from haystack import Pipeline
retriever = InMemoryBM25Retriever(document_store, top_k=3)
generator = OpenAIGenerator(model="gpt-3.5-turbo")
template = """
Given the following information, answer the question.
Context:
{% for document in documents %}
{{ document.content }}
{% endfor %}
Question: {{question}}
Answer:
"""
prompt_builder = PromptBuilder(template=template)
rag_pipeline = Pipeline()
rag_pipeline.add_component("retriever", retriever)
rag_pipeline.add_component("prompt_builder", prompt_builder)
rag_pipeline.add_component("llm", generator)
rag_pipeline.connect("retriever", "prompt_builder.documents")
rag_pipeline.connect("prompt_builder", "llm")
```
### Testing the RAG Pipeline
```python
question = "What effects does ketamine have on rat neural stem cells?"
response = rag_pipeline.run({"retriever": {"query": question}, "prompt_builder": {"question": question}})
print(response["llm"]["replies"][0])
```
## Using DSPy for Concise Answers
The article illustrates creating a DSPy signature and module to generate concise answers. The module uses a Haystack retriever and a DSPy ChainOfThought to guide the LLM's reasoning process.
### DSPy Signature for Concise Answers
```python
class GenerateAnswer(dspy.Signature):
  """Answer questions with short factoid answers."""
  
  context = dspy.InputField(desc="may contain relevant facts")
  question = dspy.InputField()
  answer = dspy.OutputField(desc="short and precise answer")
```
### DSPy Module for RAG
```python
class RAG(dspy.Module):
  def __init__(self):
    super().__init__()
    self.generate_answer = dspy.ChainOfThought(GenerateAnswer)
  def retrieve(self, question):
    results = retriever.run(query=question)
    passages = [res.content for res in results['documents']]
    return Prediction(passages=passages)
  def forward(self, question):
    context = self.retrieve(question).passages
    prediction = self.generate_answer(context=context, question=question)
    return dspy.Prediction(context=context, answer=prediction.answer)
```
## Optimizing the RAG Pipeline
The article describes defining custom metrics for optimization, including a semantic similarity metric and a penalty for long answers. The optimized pipeline is compiled using DSPy.
### Custom Metric for Optimization
```python
from haystack.components.evaluators import SASEvaluator
sas_evaluator = SASEvaluator()
sas_evaluator.warm_up()
def mixed_metric(example, pred, trace=None):
  semantic_similarity = sas_evaluator.run(ground_truth_answers=[example.answer], predicted_answers=[pred.answer])["score"]
  n_words = len(pred.answer.split())
  long_answer_penalty = 0
  if 20 < n_words < 40:
    long_answer_penalty = 0.025 * (n_words - 20)
  elif n_words >= 40:
    long_answer_penalty = 0.5
  return semantic_similarity - long_answer_penalty
```
### Compiling the RAG Pipeline
```python
from dspy.teleprompt import BootstrapFewShot
optimizer = BootstrapFewShot(metric=mixed_metric)
compiled_rag = optimizer.compile(RAG(), trainset=trainset)
```
## Final Optimized Pipeline
The optimized prompt is integrated into the Haystack pipeline, using few-shot examples and bootstrapped demos selected by DSPy.
### Extracting Examples and Building the New Pipeline
```python
compiled_rag.predictors()[0].demos
```
#### Few-Shot Example
```python
Example({'question': 'Does increased Syk phosphorylation lead to overexpression of TRAF6 in peripheral B cells of patients with systemic lupus erythematosus?', 'answer': 'Our results suggest that the activated Syk-mediated TRAF6 pathway leads to aberrant activation of B cells in SLE, and also highlight Syk as a potential target for B-cell-mediated processes in SLE.'})
```
#### Bootstrapped Demo
```python
Example({'augmented': True, 'context': ['Chronic rhinosinusitis (CRS) …', 'Allergic airway …', 'The mechanisms and ….'], 'question': 'Are group 2 innate lymphoid cells ( ILC2s ) increased in chronic rhinosinusitis with nasal polyps or eosinophilia?', 'rationale': 'produce the answer. We need to consider the findings from the study mentioned in the context, which showed that ILC2 frequencies were associated with the presence of nasal polyps, high tissue eosinophilia, and eosinophil-dominant CRS.', 'answer': 'Yes, ILC2s are increased in chronic rhinosinusitis with nasal polyps or eosinophilia.'})
```
### Final Pipeline Configuration
```python
from haystack.components.retrievers.in_memory import InMemoryBM25Retriever
from haystack.components.generators import OpenAIGenerator
from haystack.components.builders import PromptBuilder, AnswerBuilder
from haystack import Pipeline
template = static_prompt + """
---
Context:
{% for document in documents %}
«{{ document.content }}»
{% endfor %}
Question: {{question}}
Reasoning: Let's think step by step in order to
"""
new_prompt_builder = PromptBuilder(template=template)
new_retriever = InMemoryBM25Retriever(document_store, top_k=3)
new_generator = OpenAIGenerator(model="gpt-3.5-turbo")
answer_builder = AnswerBuilder(pattern="Answer: (.*)")
optimized_rag_pipeline = Pipeline()
optimized_rag_pipeline.add_component("retriever", new_retriever)
optimized_rag_pipeline.add_component("prompt_builder", new_prompt_builder)
optimized_rag_pipeline.add_component("llm", new_generator)
optimized_rag_pipeline.add_component("answer_builder", answer_builder)
optimized_rag_pipeline.connect("retriever", "prompt_builder.documents")
optimized_rag_pipeline.connect("prompt_builder", "llm")
optimized_rag_pipeline.connect("llm.replies", "answer_builder.replies")
```
## Conclusion
The article demonstrates using DSPy to optimize prompts in a Haystack RAG pipeline, achieving a performance improvement of nearly 40% without manual prompt engineering. This approach leverages custom metrics to balance answer conciseness and similarity to correct answers.
#### Links:
  - [cookbook with associated colab - github.com - prom](https://github.com/deepset-ai/haystack-cookbook/blob/main/notebooks/prompt_optimization_with_dspy.ipynb)
  - [retrieval_augmented_gen+medium.com tag retrieval-a](https://medium.com/tag/retrieval-augmented-gen?source=post_page-----926a637a3f43---------------retrieval_augmented_gen-----------------)
  - [ai+medium.com tag ai?source=post_page-----926a637a](https://medium.com/tag/ai?source=post_page-----926a637a3f43---------------ai-----------------)
  - [publication+www.linkedin.com blog engineering gene](https://www.linkedin.com/blog/engineering/generative-ai/musings-on-building-a-generative-ai-product)
  - [PubMedQA dataset - github.com](https://github.com/pubmedqa/pubmedqa)
  - [haystack+medium.com tag haystack?source=post_page-](https://medium.com/tag/haystack?source=post_page-----926a637a3f43---------------haystack-----------------)
  - [article+medium.com towards-data-science prompt-lik](https://medium.com/towards-data-science/prompt-like-a-data-scientist-auto-prompt-optimization-and-testing-with-dspy-ff699f030cb7)
  - [dataset+huggingface.co datasets vblagoje PubMedQA_](https://huggingface.co/datasets/vblagoje/PubMedQA_instruction/viewer/default/train?row=0)
  - [Markus Winkler - unsplash.com](https://unsplash.com/@markuswinkler?utm_source=medium&utm_medium=referral)
  - [Unsplash+unsplash.com ?utm_source=medium&utm_mediu](https://unsplash.com/?utm_source=medium&utm_medium=referral)
  - [original paper - arxiv.org](https://arxiv.org/abs/2310.03714)
  - [Haystack+github.com deepset-ai haystack](https://github.com/deepset-ai/haystack)
  - [llm+medium.com tag llm?source=post_page-----926a63](https://medium.com/tag/llm?source=post_page-----926a637a3f43---------------llm-----------------)
  - [hands_on_tutorials+medium.com tag hands-on-tutoria](https://medium.com/tag/hands-on-tutorials?source=post_page-----926a637a3f43---------------hands_on_tutorials-----------------)