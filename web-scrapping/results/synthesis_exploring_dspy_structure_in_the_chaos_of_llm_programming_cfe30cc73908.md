### Title: Exploring DSPy — Structure in the Chaos of LLM Programming?
#### Author and date: Anukriti Ranjan, Mar 3, 2024
#### Main
**Exploring DSPy — Structure in the Chaos of LLM Programming?**
Imagine you’re trying to have a more meaningful conversation with a smart robot using only a set of pre-written cue cards. You might find that sometimes the robot doesn’t quite understand what you’re asking, or its answers aren’t as helpful as you’d like. DSPy was developed to make these conversations better. It’s like creating a smarter set of cue cards that adjust based on how well they work, aiming to improve how we talk to and get information from these robots.
**Conceptual Parallel between DSPy and PyTorch**
We can infer a conceptual parallel to the process of prompt optimization in the context of Large Language Models (LLMs) as managed by DSPy and PyTorch that is the go-to tool for neural net optimization. Here are the similarities.
1. **Initial Prompt Generation:**
   Similar to initializing weights in a neural network, the process begins with generating initial prompts based on a predefined or heuristic approach, leveraging the `and` and `class` structures to define the input-output relationship dynamically.
2. **Evaluation of Generated Responses:**
   Once a prompt is used to generate a response from an LLM, the quality of the response is evaluated. This is analogous to calculating the loss in a neural network, where the loss function quantifies the difference between the predicted output and the actual target. In the context of DSPy, the evaluation involves metrics like exact match or any other metric that may be specified.
3. **Prompt Adjustment:**
   Based on the evaluation, prompts are adjusted to improve future responses. This step is conceptually similar to adjusting weights in a neural network based on the loss gradient.
4. **Iterative Refinement:**
   The process of generating responses, evaluating them, and adjusting prompts is repeated iteratively, mirroring the training loop in neural network training. Each iteration aims to refine the prompts to enhance the quality of the generated responses according to the chosen metrics.
**Some Differences**
Unlike the explicit loss functions and gradient descent algorithms used in neural network optimization, prompt optimization in DSPy does not follow any loss function or back-propagation.
The “equation” for prompt adjustment in this context is more of an algorithmic procedure that incorporates feedback from the evaluation phase to tweak the prompts. The content of the components of the prompt does not change in this process. e.g The optimization process will not correct a spelling error in the prompt but by revealing that metric is not that high when using this prompt with incorrect spelling, it can direct your attention to the under-performing prompts.
DSPy differentiates from PyTorch by focusing on optimizing language model interactions through structured prompting and module composition, rather than training neural networks via backpropagation and loss functions. While PyTorch optimizes model weights based on numerical loss metrics to improve performance, DSPy evaluates and selects prompts by testing against an evaluation set, optimizing based on specific metrics. It can also enhance prompts by incorporating successful examples from the training set, transitioning from zero-shot to few-shot learning by systematically refining prompt effectiveness and adaptability.
**Example Implementation**
I tested DSPy for a case where I want the most relevant metric in response to a user query in natural language. For this, I first set up my vector database, Weaviate.
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
for i, d in metric_data.iterrows():  # Loop through your DataFrame
  print(f"Importing metric: {i + 1}")
  # Prepare the properties for the data object
  properties = {
    "metric_category_name": d["Categories"],
    "metric_category_desc": d["Categories_descriptions"],
    "version": 1
  }
  # Generate the custom vector
  vector = model_e5.encode(d["Categories_descriptions"], normalize_embeddings=True, convert_to_numpy=True)
  # Ensure the vector is in the correct format (list)
  if isinstance(vector, np.ndarray):
    vector_list = vector.tolist()
  else:
    print(f"Error: The vector for record {i + 1} is not a numpy ndarray.")
    continue
  # Create the data object with the custom vector
  try:
    weaviate_client.data_object.create(
      properties,
      class_name="Metric_categories",
      vector=vector_list
    )
  except Exception as e:
    print(f"Error adding object {i + 1}: {e}")
```
Since I have not specified the vectoriser in my weaviate client, I needed to write a custom retriever for my use case.
```python
import weaviate
from typing import List, Union, Optional
import dspy
from dsp.utils.utils import dotdict
class CustomWeaviateRM(dspy.Retrieve):
  """
  A retrieval module that uses Weaviate for vector-based search to return the top results from the specified key.
  """
  def __init__(self,
               weaviate_collection_name: str,
               weaviate_client: weaviate.Client,
               model_encoder,
               retrieve_key: str,  # Key to retrieve from the search results
               k: int = 3
               ):
    self._weaviate_collection_name = weaviate_collection_name
    self._weaviate_client = weaviate_client
    self._model_encoder = model_encoder
    self._retrieve_key = retrieve_key
    super().__init__(k=k)
  def forward(self, query_or_queries: Union[str, List[str]], k: Optional[int] = None) -> dspy.Prediction:
    """Search with Weaviate using vector similarity for self.k top results and retrieves a different key.
    Args:
      query_or_queries (Union[str, List[str]]): The query or queries to search for.
      k (Optional[int]): The number of top results to retrieve. Defaults to self.k.
    Returns:
      dspy.Prediction: An object containing the retrieved results based on vector search from a different key.
    """
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
After this, I configure DSPy to use the openai module to work on the mistral-7B I have deployed locally on docker via vLLM.
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
Further, I specify the signature and RAG modules.
```python
class GenerateAnswer(dspy.Signature):
  """Answer the query with the most relevant metric only from among the provided context, with no explanation"""
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
I used the dataloader class to create the train and test set for optimization.
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
I then used the teleprompter to optimize the prompt.
```python
from dspy.teleprompt import BootstrapFewShot
def validate_context_and_answer(example, pred, trace=None):
  answer_EM = dspy.evaluate.answer_exact_match(example, pred)
  return answer_EM
# Set up a basic teleprompter, which will compile our RAG program.
teleprompter = BootstrapFewShot(metric=validate_context_and_answer)
# Compile
compiled_rag = teleprompter.compile(RAG(), trainset=train_dataset)
```
**My Observations**
- The DSPy framework introduces a systematic approach to LLM programming by allowing the structuring of language model pipelines using declarative modules. This structure facilitates easy creation of custom functions and parameterization, enhancing the ability to fine-tune inputs, outputs, and even the instructional prompts based on specific training set demonstrations. Such a methodical approach aids in experimenting with different configurations systematically to achieve desired outcomes, thereby introducing a level of predictability and control into the otherwise exploratory process of LLM programming.
- DSPy emphasizes the importance of a uniform prompting methodology to evaluate various models accurately. Traditional model assessments often suffer from inconsistencies due to varied prompting techniques, which can significantly affect the performance and comparability of LLMs. By standardizing the prompting approach, DSPy enables a more reliable and informative evaluation process that can better reflect the true capabilities of different models under consistent conditions.
- The DSPy compiler is designed for rapid optimization and training of LLM pipelines. This efficiency is crucial for iterating over different configurations and promptly evaluating their impact on performance metrics. Such speed in optimization allows for a more dynamic and responsive development process, facilitating quicker experimentation and refinement of LLM applications.
- While DSPy offers significant advancements, the implementation of the signature module, particularly the output field specification and its validation against a apart from theoretical accuracy, presents challenges. These complexities highlight areas for improvement in ensuring that model outputs align more closely with specific structural and logical expectations. I tried the above modification in the output field but it did not work.
- DSPy’s approach to optimizing prompts within a predefined space set by the user indicates a limitation in automatically discovering new, potentially more effective prompts. This constraint suggests an area for further exploration, where the system could potentially benefit from mechanisms that allow for the autonomous generation of innovative prompting strategies beyond the user-defined scope. (like take a deep breath etc. )
- The flexibility to adapt prompts based on evaluations is a double-edged sword. While it allows for tailored LLM responses that can potentially enhance performance, there is an inherent risk of overfitting to specific inputs or user preferences. This adaptability, though beneficial in creating more responsive and dynamic models, necessitates careful management to ensure that modifications do not compromise the model’s generalizability or its ability to perform accurately across diverse and unforeseen inputs. When the system is in production, it is going to be exposed to a vast diversity of user input which will greatly influence the outputs beyond the things that we have optimized in the prompt (like demonstrations, descriptions etc.). There is also a very valid chance that certain users may prefer a model that is considered sub-optimal in evals (check out this)
- With LLMs, a major thing to look out for is token optimization. While repeated calls to the LLM API will help you improve the output accuracy, the cost consideration cannot be overlooked.
**DSPY: COMPILING DECLARATIVE LANGUAGE MODEL CALLS INTO SELF-IMPROVING PIPELINES**
The following two are currently my favorite resources on DSPy on the internet.
#### Links:
  - [Open in app - rsci.app.link](https://rsci.app.link/?%24canonical_url=https%3A%2F%2Fmedium.com%2Fp%2Fcfe30cc73908&%7Efeature=LoOpenInAppButton&%7Echannel=ShowPostUnderUser&source=---two_column_layout_nav----------------------------------)
  - [https://arxiv.org/pdf/2310.03714.pdf+arxiv.org pdf](https://arxiv.org/pdf/2310.03714.pdf)
  - [medium.com](https://medium.com/tag/dspy?source=post_page-----cfe30cc73908---------------dspy-----------------)
  - [medium.com](https://medium.com/tag/llm?source=post_page-----cfe30cc73908---------------llm-----------------)
  - [medium.com](https://medium.com/tag/generative-ai-tools?source=post_page-----cfe30cc73908---------------generative_ai_tools-----------------)
  - [medium.com](https://medium.com/tag/llmops?source=post_page-----cfe30cc73908---------------llmops-----------------)
  - [www.linkedin.com/in/anukriti-ranjan+www.linkedin.c](http://www.linkedin.com/in/anukriti-ranjan)
  - [medium.statuspage.io](https://medium.statuspage.io/?source=post_page-----cfe30cc73908--------------------------------)
  - [speechify.com](https://speechify.com/medium?source=post_page-----cfe30cc73908--------------------------------)
  - [medium.com](https://medium.com/business?source=post_page-----cfe30cc73908--------------------------------)