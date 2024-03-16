### Title: Exploring DSPy — Structure in the Chaos of LLM Programming?
- **Author and date:** Anukriti Ranjan, Mar 3, 2024
### Main Content
#### Introduction to DSPy
The article begins with an analogy comparing the interaction with a smart robot using pre-written cue cards to the process of communicating with Large Language Models (LLMs) using DSPy. DSPy is introduced as a tool designed to enhance the interaction with LLMs by optimizing the prompts used in these interactions, akin to creating a smarter set of cue cards that adjust based on their effectiveness.
#### Conceptual Parallel between DSPy and PyTorch
A significant portion of the article draws a parallel between DSPy's approach to prompt optimization and the process of neural network optimization in PyTorch. The similarities outlined include:
1. **Initial Prompt Generation:** This step is compared to initializing weights in a neural network, where initial prompts are generated based on predefined or heuristic approaches.
2. **Evaluation of Generated Responses:** Analogous to calculating the loss in neural networks, the quality of responses generated from prompts is evaluated using specific metrics.
3. **Prompt Adjustment:** Similar to adjusting weights based on the loss gradient, prompts are adjusted to improve future responses.
4. **Iterative Refinement:** The process of generating responses, evaluating them, and adjusting prompts is repeated iteratively, mirroring the training loop in neural network training.
The article also highlights some differences between DSPy and PyTorch, notably that DSPy does not use explicit loss functions or back-propagation for prompt optimization. Instead, it uses an algorithmic procedure that incorporates feedback from the evaluation phase.
#### Example Implementation
The author provides a detailed example implementation of DSPy for retrieving the most relevant metric in response to a user query. The implementation involves setting up a vector database with Weaviate, writing a custom retriever, configuring DSPy to use an OpenAI module, specifying the signature and RAG modules, creating the train and test set for optimization, and finally using the teleprompter to optimize the prompt.
- **Setting up the vector database with Weaviate:**
  ```python
  import weaviate
  from sentence_transformers import SentenceTransformer, util
  
  weaviate_client = weaviate.Client("http://localhost:8080")
  class_name = "Metric_categories"
  class_obj = {
    "class": class_name,
    "vectorizer": "none",
    'vectorIndexType': "flat",
  }
  weaviate_client.schema.create_class(class_obj)
  model_e5 = SentenceTransformer("intfloat/e5-large-v2")
  
  for i, d in metric_data.iterrows():
    print(f"Importing metric: {i + 1}")
    properties = {
      "metric_category_name": d["Categories"],
      "metric_category_desc": d["Categories_descriptions"],
      "version": 1
    }
    vector = model_e5.encode(d["Categories_descriptions"], normalize_embeddings=True, convert_to_numpy=True)
    if isinstance(vector, np.ndarray):
      vector_list = vector.tolist()
    else:
      print(f"Error: The vector for record {i + 1} is not a numpy ndarray.")
      continue
    try:
      weaviate_client.data_object.create(
        properties,
        class_name="Metric_categories",
        vector=vector_list
      )
    except Exception as e:
      print(f"Error adding object {i + 1}: {e}")
  ```
- **Writing a custom retriever:**
  ```python
  import weaviate
  from typing import List, Union, Optional
  import dspy
  from dsp.utils.utils import dotdict
  
  class CustomWeaviateRM(dspy.Retrieve):
    def __init__(self, weaviate_collection_name: str, weaviate_client: weaviate.Client, model_encoder, retrieve_key: str, k: int = 3):
      self._weaviate_collection_name = weaviate_collection_name
      self._weaviate_client = weaviate_client
      self._model_encoder = model_encoder
      self._retrieve_key = retrieve_key
      super().__init__(k=k)
    
    def forward(self, query_or_queries: Union[str, List[str]], k: Optional[int] = None) -> dspy.Prediction:
      k = k if k is not None else self.k
      queries = [query_or_queries] if isinstance(query_or_queries, str) else query_or_queries
      queries = [q for q in queries if q]
      results_list = []
      
      for query in queries:
        encoded_query_vector = self._model_encoder.encode(query, normalize_embeddings=True, convert_to_numpy=True).tolist()
        nearVector = {"vector": encoded_query_vector}
        results = self._weaviate_client.query \
          .get(self._weaviate_collection_name, [self._retrieve_key]) \
          .with_additional("distance") \
          .with_near_vector(nearVector) \
          .with_limit(k) \
          .do()
        
        results = results["data"]["Get"][self._weaviate_collection_name]
        parsed_results = [result[self._retrieve_key] for result in results]
        results_list.extend(dotdict({"long_text": d}) for d in parsed_results)
      return results_list
  ```
- **Configuring DSPy to use the OpenAI module:**
  ```python
  import dspy
  from dspy.retrieve.weaviate_rm import WeaviateRM
  
  mistral_7b = dspy.OpenAI(model='mistralai/Mistral-7B-Instruct-v0.2',
  api_base="http://localhost:8001/v1/",
  api_key="empty_key",
  api_provider = "other")
  
  weaviate_retriever = CustomWeaviateRM( weaviate_collection_name = "Metric_categories",
  weaviate_client = weaviate_client,
  model_encoder = model_e5,
  retrieve_key = "metric_category_name")
  
  dspy.settings.configure(lm=mistral_7b, rm=weaviate_retriever)
  ```
- **Specifying the signature and RAG modules:**
  ```python
  class GenerateAnswer(dspy.Signature):
    context = dspy.InputField(desc="top metrics matching query")
    question = dspy.InputField(desc="query from the user")
    answer = dspy.OutputField(desc="the most relevant metric")
  
  class RAG(dspy.Module):
    def __init__(self, num_passages=3):
      super().__init__()
      self.retrieve = dspy.Retrieve(k=num_passages)
      self.generate_answer = dspy.Predict(GenerateAnswer)
    
    def forward(self, question):
      context = self.retrieve(question).passages
      prediction = self.generate_answer(context=context, question=question)
      return dspy.Prediction(context=context, answer=prediction.answer)
  
  uncompiled_rag = RAG()
  print(uncompiled_rag("successful rrc connections").answer)
  ```
- **Creating the train and test set for optimization:**
  ```python
  from dspy.datasets import DataLoader
  
  dl = DataLoader()
  metric_dataset = dl.from_csv(
    "data/metric_train_test_dataset.csv",
    fields=["question", "answer"],
    input_keys=("question")
  )
  splits = dl.train_test_split(dataset=metric_dataset, train_size=0.75)
  train_dataset = splits['train']
  test_dataset = splits['test']
  
  ## Evaluate on the uncompiled module
  from dspy.evaluate.evaluate import Evaluate
  
  evaluate = Evaluate(devset=train_dataset, num_threads=1, display_progress=True, display_table=5)
  evaluate(RAG(), metric=dspy.evaluate.answer_exact_match)
  ```
- **Using the teleprompter to optimize the prompt:**
  ```python
  from dspy.teleprompt import BootstrapFewShot
  
  def validate_context_and_answer(example, pred, trace=None):
    answer_EM = dspy.evaluate.answer_exact_match(example, pred)
  
    return answer_EM
  
  teleprompter = BootstrapFewShot(metric=validate_context_and_answer)
  
  compiled_rag = teleprompter.compile(RAG(), trainset=train_dataset)
  ```
#### Observations and Insights
The author shares observations on the DSPy framework, emphasizing its systematic approach to LLM programming, the importance of a uniform prompting methodology, the efficiency of the DSPy compiler, and the challenges and limitations encountered during implementation. The observations highlight the potential of DSPy to introduce predictability and control into LLM programming, improve the evaluation process of various models, and facilitate rapid optimization and training of LLM pipelines. However, the author also points out areas for improvement and the inherent risks of overfitting and the limitation in automatically discovering new prompting strategies.
### Conclusion
The article concludes by affirming DSPy's role in compiling declarative language model calls into self-improving pipelines, offering a structured approach to LLM programming that enhances the interaction with and optimization of LLMs.
#### Links:
  - [https://arxiv.org/pdf/2310.03714.pdf+arxiv.org pdf](https://arxiv.org/pdf/2310.03714.pdf)
  - [dspy+medium.com tag dspy?source=post_page-----cfe3](https://medium.com/tag/dspy?source=post_page-----cfe30cc73908---------------dspy-----------------)
  - [llm+medium.com tag llm?source=post_page-----cfe30c](https://medium.com/tag/llm?source=post_page-----cfe30cc73908---------------llm-----------------)
  - [generative_ai_tools+medium.com tag generative-ai-t](https://medium.com/tag/generative-ai-tools?source=post_page-----cfe30cc73908---------------generative_ai_tools-----------------)
  - [llmops+medium.com tag llmops?source=post_page-----](https://medium.com/tag/llmops?source=post_page-----cfe30cc73908---------------llmops-----------------)
  - [www.linkedin.com/in/anukriti-ranjan+www.linkedin.c](http://www.linkedin.com/in/anukriti-ranjan)