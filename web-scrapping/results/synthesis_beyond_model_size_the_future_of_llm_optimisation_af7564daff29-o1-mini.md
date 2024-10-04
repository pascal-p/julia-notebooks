### Beyond Model Size: The Future of LLM Optimisation

- **Publication Date:** August 18, 2024
- **Author:** Haberlah
- **Link:** [Beyond Model Size: The Future of LLM Optimisation](https://medium.com/@haberlah/beyond-model-size-the-future-of-llm-optimisation-af7564daff29)

---

### Introduction

Two notable research papers published this month reveal how optimizing test-time computation can significantly enhance Large Language Model (LLM) performance without additional training. The papers, **“Scaling LLM Test-Time Compute Optimally can be More Effective than Scaling Model Parameters”** by Snell et al. from UC Berkeley and Google DeepMind, and **“Let Me Speak Freely? A Study on the Impact of Format Restrictions on Performance of Large Language Models”** by Tam et al. from Appier AI Research and National Taiwan University, challenge the conventional approach that higher-quality responses necessarily require scaling up LLM parameters and waiting for larger, more powerful foundation models.

### Understanding Test-Time Compute

**Test-time compute**, also known as **inference compute**, refers to the computational resources used when an LLM generates responses to prompts. Unlike **training compute**, which is used to create and refine the model itself, test-time compute is applied each time the model is used. The research demonstrates that by strategically allocating these computational resources during inference, organizations can extract more value from their existing language models without incurring the substantial costs associated with larger-scale training.

### Benefits for Businesses

This approach offers several potential benefits for businesses:
- **Improved Model Performance:** Enhancing model performance without the need for expensive retraining or larger models.
- **Task-Specific Optimization:** Enabling models to perform better on specific tasks or domains without altering the base model.
- **Versatility:** Allowing for performance improvements that can be implemented across various applications and use cases.

### Relevance to RAG Pipelines and Prompt Engineering

The findings are particularly relevant for businesses designing their **Retrieval-Augmented Generation (RAG) pipelines** and individuals refining their **prompt engineering strategies**. By optimizing test-time compute, it’s possible to significantly boost the effectiveness of existing LLMs across various applications, such as content localization and transcreation in a business setting.

### Strategies for Optimising LLM Performance at Inference Time

In the following sections, eight innovative strategies leveraging test-time compute are explored to significantly improve LLM responses. Each strategy includes a concise explanation, a mathematical representation where applicable, a relatable analogy, and practical applications in prompt engineering and RAG pipelines.

---

#### 1. Best-of-N Sampling

**Best-of-N Sampling** is a technique where an LLM generates multiple independent responses (N) to a given prompt. A verifier (e.g., a **Process Reward Model (PRM)**) then selects the best response from these candidates. This method leverages parallel computation to explore a wider range of potential answers, increasing the likelihood of finding a high-quality response.

$$P(best) = 1 - (1 - p)^N$$

- **p:** Probability of generating a correct response in a single attempt
- **N:** Number of independent responses generated

**Analogy:** Imagine asking 10 different people to solve a math problem independently. A math teacher then checks all the different approaches and answers and picks the best one based on clarity, correctness, and other relevant criteria.

**Implementation in RAG Pipeline:**
```python
def best_of_n_rag(query, n=5):
  documents = retrieve_top_n_documents(query, n)
  responses = []
  for doc in documents:
    prompt = f"Given the context: {doc}\nAnswer the query: {query}"
    responses.append(generate_response(prompt))
  return select_best_response(responses)
```

---

#### 2. Sequential Revisions

**Sequential Revisions** is a method where an LLM generates an initial response and then iteratively revises it. Each revision is conditioned on previous attempts, allowing the model to learn from and improve upon its past outputs.

$$Q(t) = Q_{max} - (Q_{max} - Q_0) \times e^{(-λt)}$$

- **Q(t):** Quality at revision ‘t’
- **Q_max:** Maximum achievable quality
- **Q_0:** Initial quality
- **λ:** Rate of improvement

**Analogy:** Picture a student writing an essay draft, then reviewing and improving it multiple times based on their previous versions by incorporating feedback and making specific improvements.

**Implementation in RAG Pipeline:**
```python
def enhanced_sequential_revisions(query, max_revisions=3):
  response = generate_initial_response(query)
  for _ in range(max_revisions):
    response = revise_response(response)  # Revise the response iteratively
    if structured_output_required():
      return convert_to_structured_format(response)
  return response

def revise_response(response):
  # Implement revision logic
  pass

def convert_to_structured_format(response):
  # Convert response to structured format if needed
  pass
```

---

#### 3. Beam Search

**Beam Search** is a heuristic search algorithm that explores multiple promising paths simultaneously at each step of the generation process. It maintains a set of “beams” (partial solutions) and expands them in parallel, keeping only the top-scoring candidates based on a verifier (e.g., a PRM). This approach balances exploration (considering diverse possibilities) and exploitation (focusing on the most likely paths).

$$B(t) = top_k(expand(B(t-1)))$$

- **B(t):** Set of beams at step ‘t’
- **top_k:** Selects the ‘k’ highest-scoring candidates
- **expand:** Generates all possible next steps from the current beams

**Analogy:** Imagine cooking a complex meal, starting with a broad idea and refining it by iterating and branching out from the most promising partial solutions at each step, guided by quality scores.

**Implementation in RAG Pipeline:**
```python
def beam_search_prompting(initial_prompt, beam_width=3, max_depth=3):
  prompts = [initial_prompt]
  for depth in range(max_depth):
    candidates = []
    for prompt in prompts:
      variations = generate_prompt_variations(prompt, beam_width)
      responses = [generate_response(var) for var in variations]
      candidates.extend(zip(variations, responses))
    prompts = select_top_k_prompts(candidates, k=beam_width)
  return select_best_prompt(prompts)

def generate_prompt_variations(prompt, n):
  # Generate n variations of the given prompt
  pass

def select_top_k_prompts(candidates, k):
  # Select the k best prompts based on response quality
  pass

def select_best_prompt(prompts):
  # Select the overall best prompt
  pass
```

---

#### 4. Lookahead Search

**Lookahead Search** extends the Beam Search approach by simulating future steps before making decisions about which paths to pursue. At each step, it evaluates potential future states to obtain a better estimate of the overall solution quality.


$$V(s) = max(R(s), \gamma \times max(V(s')))$$

- **V(s):** Value of state ‘s’
- **R(s):** Immediate reward of state ‘s’
- **γ:** Discount factor (controls the importance of future rewards)
- **s’:** Possible future states reachable from ‘s’

**Analogy:** In a chess game, a player thinks several moves ahead, imagining possible scenarios before deciding on their current move.

**Implementation in RAG Pipeline:**
```python
def lookahead_prompting(initial_prompt, lookahead_depth=2, num_variations=3):
  variations = generate_prompt_variations(initial_prompt, num_variations)
  best_prompt = None
  best_score = float('-inf')

  for prompt in variations:
    score = simulate_prompt_chain(prompt, depth=lookahead_depth)
    if score > best_score:
      best_prompt = prompt
      best_score = score

  return best_prompt

def simulate_prompt_chain(prompt, depth):
  # Simulate a chain of prompts and responses, return a score
  pass
```

---

#### 5. Hybrid Approaches

**Hybrid Approaches** combine multiple test-time compute strategies to leverage their complementary strengths and mitigate their individual weaknesses. This allows for more robust and adaptable systems that can handle a wider range of tasks and queries.

$$E[H] = max(E[S_1], E[S_2], ..., E[S_n])$$

- **E[H]:** Expected performance of the hybrid approach
- **E[Si]:** Expected performance of the i-th strategy

**Analogy:** Imagine a writing contest where multiple authors each write and revise their own stories over several rounds. A judge then selects the best final story from all the authors, combining the strengths of individual writing and revision processes.

**Implementation in Prompt Engineering:**
```python
def hybrid_prompting(initial_query, n_initial=5, beam_width=3, max_revisions=2):
  # Step 1: Best-of-N for initial prompts
  initial_prompts = generate_diverse_prompts(initial_query, n=n_initial)
  initial_responses = [generate_response(prompt) for prompt in initial_prompts]
  best_initial = select_best_response(initial_responses)

  # Step 2: Beam Search for prompt refinement
  refined_prompts = beam_search_prompts(best_initial, width=beam_width)

  # Step 3: Sequential Revisions for final improvements
  final_prompt = sequential_revise_prompt(refined_prompts[0], max_revisions=max_revisions)
  return final_prompt

def generate_diverse_prompts(query, n):
  # Generate n diverse prompts based on the query
  pass

def beam_search_prompts(prompt, width):
  # Perform beam search to refine the prompt
  pass

def sequential_revise_prompt(prompt, max_revisions):
  # Sequentially revise the prompt
  pass
```

**Implementation in RAG Pipeline:**
```python
def hybrid_rag(query, n_initial=5, beam_width=3, max_revisions=2):
  # Step 1: Best-of-N for initial document retrieval
  initial_docs = retrieve_diverse_documents(query, n=n_initial)
  initial_responses = [generate_response(query, doc) for doc in initial_docs]
  best_initial = select_best_response(initial_responses)

  # Step 2: Beam Search for context refinement
  refined_contexts = beam_search_contexts(query, best_initial, width=beam_width)

  # Step 3: Sequential Revisions for final response generation
  final_response = sequential_revise_response(query, refined_contexts[0], max_revisions=max_revisions)
  return final_response

def retrieve_diverse_documents(query, n):
  # Retrieve n diverse documents relevant to the query
  pass

def beam_search_contexts(query, initial_context, width):
  # Perform beam search to refine the context
  pass

def sequential_revise_response(query, context, max_revisions):
  # Sequentially revise the response
  pass
```
**Benefits and Considerations:**
- **Flexibility:** Adaptable to diverse queries and tasks.
- **Robustness:** Mitigates individual strategy weaknesses.
- **Quality:** Achieves higher quality outputs through synergistic combination.
- **Complexity:** More complex to implement and maintain.
- **Resource Allocation:** May require more computational resources and careful tuning.

---

#### 6. Compute-Optimal Scaling

**Compute-Optimal Scaling** involves adaptively choosing the best test-time compute strategy based on the estimated difficulty or complexity of the task at hand. This approach aims to optimize the use of available compute resources by allocating more resources to challenging tasks and less to simpler ones.

$$S^{*} = argmax_S\left(\frac{P(correct|S, d)}{C(S)}\right)$$

- **S\*:** Optimal strategy
- **P(correct|S, d):** Probability of getting a correct answer given strategy S and difficulty d
- **C(S):** Computational cost of strategy S

**Analogy:** Think of a student who uses flashcards for easy topics, group study sessions for moderately difficult subjects, and one-on-one tutoring for the most challenging concepts. The student adapts their learning strategy based on the perceived difficulty of the material.

**Implementation in Prompt Engineering:**
```python
def compute_optimal_prompting(query):
  complexity = assess_query_complexity(query)
  if complexity == 'low':
    return simple_prompt_strategy(query)

  if complexity == 'medium':
    return beam_search_prompting(query, beam_width=3, max_depth=2)

  # high complexity
  return hybrid_prompting(query, n_initial=5, beam_width=3, max_revisions=2)

def assess_query_complexity(query):
  # Implement logic to assess query complexity
  # This could be based on query length, presence of specific keywords, etc.
  pass

def simple_prompt_strategy(query):
  # Implement a simple prompting strategy for low-complexity queries
  pass
```

**Implementation in RAG Pipeline:**
```python
def compute_optimal_rag(query):
  difficulty = estimate_query_difficulty(query)
  if difficulty == 'easy':
    return simple_rag(query)

  if difficulty == 'moderate':
    return beam_search_rag(query, beam_width=3, max_depth=2)

  # difficult
    return hybrid_rag(query, n_initial=5, beam_width=3, max_revisions=2)

def estimate_query_difficulty(query):
  # Implement logic to estimate query difficulty
  # This could be based on query complexity, domain specificity, etc.
  pass

def simple_rag(query):
  # Implement a simple RAG strategy for easy queries
  pass
```

**Additional Considerations:**
- **Format Adaptation:** For simpler tasks, generate responses in the desired structured format. For complex tasks, leverage LLM’s natural language capabilities and apply structured formatting as a final post-processing step if necessary.

---

#### 7. Process Reward Model (PRM) Guided Search

**Process Reward Model (PRM) Guided Search** uses a learned reward model to provide feedback and guidance during the generation process. The PRM evaluates intermediate steps or partial solutions, steering the LLM towards more promising directions and improving the overall quality of the final output.

$$R(s, a, s') = f(\varphi(s, a, s'))$$

- **R:** Reward
- **s:** Current state
- **a:** Action taken
- **s':** Next state
- **φ:** Feature function that extracts relevant information from the states and action
- **f:** Learned reward function that maps the features to a reward value

**Analogy:** Imagine a cooking show where a professional chef tastes and scores each step of a contestant’s dish preparation, guiding them towards better choices throughout the cooking process.

**Implementation in Prompt Engineering:**
```python
def prm_guided_prompting(query, n_candidates=10, n_iterations=3):
  candidates = generate_initial_prompts(query, n_candidates)
  for _ in range(n_iterations):
    responses = [generate_response(prompt) for prompt in candidates]
    scores = reward_model.evaluate(responses)
    best_candidates = select_top_k(candidates, scores, k=n_candidates//2)
    candidates = best_candidates + generate_variations(best_candidates, n_candidates//2)

  return select_best(candidates, reward_model)

def generate_initial_prompts(query, n):
  # Generate n initial prompt candidates
  pass

def generate_variations(prompts, n):
  # Generate n variations of the given prompts
  pass

class RewardModel:
  def evaluate(self, responses):
    # Evaluate the quality of the responses
    pass

reward_model = RewardModel()
```

**Implementation in RAG Pipeline:**
```python
def prm_guided_rag(query, n_docs=10, n_iterations=3):
  documents = retrieve_initial_documents(query, n_docs)
  for _ in range(n_iterations):
    contexts = [create_context(doc) for doc in documents]
    responses = [generate_response(query, context) for context in contexts]
    scores = reward_model.evaluate(responses, query)
    best_docs = select_top_k(documents, scores, k=n_docs//2)
    documents = best_docs + retrieve_similar_documents(best_docs, n_docs//2)
  #
  best_context = create_context(select_best(documents, reward_model))
  return generate_response(query, best_context)

def retrieve_initial_documents(query, n):
  # Retrieve n initial relevant documents
  pass

def create_context(document):
  # Create a context from the document for response generation
  pass

def retrieve_similar_documents(documents, n):
  # Retrieve n documents similar to the given documents
  pass

class RewardModel:
  def evaluate(self, responses, query):
    # Evaluate the quality and relevance of the responses
    pass

reward_model = RewardModel()
```

---

#### 8. Majority Voting

**Majority Voting** is a straightforward yet effective approach that involves generating multiple responses to a given query or prompt and then selecting the most common or frequent answer as the final output. This method relies on the assumption that the “wisdom of the crowd” often leads to a more accurate or reliable result.

$$P(correct) = \sum_{k=⌊\frac{N}{2}⌋+1}^{N} C^{N}_{k} \times p^k \times (1-p)^{N-k}$$

- **N:** Number of votes
- **p:** Probability of each vote being correct
- **C(N, k):** Binomial coefficient (number of ways to choose k items from a set of N)
- **⌊N/2⌋+1:** Minimum number of votes needed for a majority

**Analogy:** Think of a game show where the contestant can “ask the audience” for help. The most popular answer from the audience is often the correct one.

**Implementation in Prompt Engineering:**
```python
def majority_voting_prompting(query, n_prompts=5, n_responses_per_prompt=3):
  prompts = generate_diverse_prompts(query, n_prompts)
  all_responses = [
    resp for prompt in prompts for resp in [generate_response(prompt) for _ in range(n_responses_per_prompt)]
  ]
  return aggregate_responses(all_responses)

def generate_diverse_prompts(query, n):
  # Generate n diverse prompts based on the query
  pass

def aggregate_responses(responses):
  # Implement logic to identify common elements and construct a final response
  # This could involve techniques like text summarization or extractive methods
  pass
```

**Implementation in RAG Pipeline:**
```python
def majority_voting_rag(query, n_retrievals=5, n_docs_per_retrieval=3):
  all_responses = []
  for _ in range(n_retrievals):
    documents = retrieve_documents(query, n_docs_per_retrieval)
    context = create_context(documents)
    response = generate_response(query, context)
    all_responses.append(response)
  #
  return aggregate_responses(all_responses)

def retrieve_documents(query, n):
  # Retrieve n relevant documents for the query
  pass

def create_context(documents):
  # Create a context from the documents for response generation
  pass

def aggregate_responses(responses):
  # Implement logic to identify common information and construct a final response
  # This could involve techniques like text summarization or answer fusion
  pass
```

---

### Applications in Search GPT

The discussed test-time compute strategies are already informing cutting-edge real-world AI applications such as **Perplexity.ai**, an innovative search engine that leverages sophisticated LLM techniques to provide more accurate and contextually relevant results. Below are practical applications of the strategies:

#### Sliding Window Approach: Enhancing Context for Predictions

Perplexity.ai’s use of a **sliding window technique** for evaluating fixed-length language models demonstrates a practical application of principles similar to **Beam Search** and **Lookahead Search**. This approach explores multiple “beams” of context simultaneously, allowing the model to make predictions based on different contextual information, akin to how beam search explores multiple partial solutions.

**Benefits:**
- Provides a more nuanced exploration of the input space.
- Implements a form of lookahead by considering additional past context for better predictions.

---

#### Efficient Sampling: Optimizing Data Selection

Perplexity.ai applies **efficient sampling techniques**, particularly **importance sampling**, as an advanced application of the **Best-of-N Sampling** strategy. Instead of generating N complete responses and selecting the best one, it carefully chooses a subset of the test data and weights samples based on their relevance, achieving a more efficient and targeted evaluation.

**Benefits:**
- More efficient data selection and response generation.
- Implicit use of a verifier through the weighting mechanism.

---

#### Hierarchical Computation: Adaptive Evaluation Strategies

Perplexity.ai employs **hierarchical or multi-level complexity computation**, sharing core principles with **Compute-Optimal Scaling**. By computing complexity at different levels of language structure, the system adapts its computational strategy based on the scale and complexity of the language being evaluated.

**Benefits:**
- Dynamic allocation of computational resources based on task complexity.
- Enhanced adaptability for varying language structures.

---

#### Optimized Hardware Utilization: Enabling Efficient Hybrid Approaches

Optimized hardware utilization in Perplexity.ai enables the efficient implementation of all strategies, particularly **Hybrid Approaches**. By distributing computations across different hardware types (CPUs, GPUs, specialized AI chips) running different LLMs, Perplexity.ai effectively implements a form of hybrid approach at both hardware and model levels.

**Benefits:**
- Optimal execution of various test-time compute strategies.
- Flexibility to run different strategies in parallel or switch based on task needs.

---

#### Synergies Between Approaches

The implementation of these inference compute strategies in Perplexity.ai highlights several key synergies:
- **Sliding Window with Efficient Sampling:** Balances broad context consideration with focused, relevant data selection.
- **Hierarchical Computation with Hardware Optimization:** Enables dynamic resource allocation based on task complexity.
- **Importance Sampling with Sliding Window Techniques:** Combines diverse context exploration with relevant information exploitation.
- **Efficient Sampling with Hardware Utilization:** Handles large-scale tasks while maintaining computational efficiency.

**Benefits:**
- More powerful and flexible systems.
- Superior performance across a wide range of tasks and query types.

---

### The Future of LLM Optimisation

The research by Snell et al. and Tam et al. presents a compelling case for rethinking LLM progress beyond the current mantra of “bigger is better.”

- **Snell et al.’s Work:** Highlights substantial performance gains for existing and smaller LLMs by focusing on test-time compute approaches, offering businesses a path to improved LLM capabilities without costly model (re)training.
  - **Example:** A customer service chatbot utilizing Best-of-N Sampling to generate diverse responses and select the most appropriate one, enhancing user satisfaction without requiring a larger model.
- **Tam et al.’s Findings:** Emphasize the trade-offs associated with structured output, underscoring the importance of preserving the LLM’s ability to perform nuanced reasoning on complex linguistic queries.
  - **Solution:** A two-stage approach where the model first reasons in natural language and then converts the output to a structured format as a post-processing step.

**Role of Data Scientists and AI Practitioners:**
- **Strategy Selection:** Careful selection and combination of test-time compute strategies tailored to specific task requirements and resource constraints.
- **Evaluation Metrics:** Development of robust metrics to capture the trade-off between performance and efficiency.
- **Integration:** Seamless integration of test-time compute optimization strategies into existing LLM pipelines, ensuring scalability and cost-effectiveness.

**Balancing Computational Cost and Performance Gains:**
- Important to balance the computational cost of these strategies at inference time with the performance improvements they offer.
- Consider the cost of training larger models against the inference costs of employing sophisticated test-time compute strategies.
- **Example:** Anthropic’s new feature, **Prompt Caching**, improves efficiency by up to 90% and reduces latency by up to 85% for long and complex prompts.

**Future Directions:**
- **Sophisticated Hybrid Strategies:** Potentially guided by machine learning meta-optimizers, dynamically adapting compute strategies in real-time.
- **Hardware-Optimized Approaches:** Emergence of integrated development environments that streamline the implementation of these strategies, particularly on edge devices.
- **Innovation in Test-Time Compute Optimization:** Promises a future where powerful models are more capable, efficient, accessible, and responsibly deployed.

---

### References

- **Snell, C., Lee, J., Xu, K., & Kumar, A.** (2024). Scaling LLM test-time compute optimally can be more effective than scaling model parameters. arXiv.
- **Tam, Z. R., Wu, C.-K., Tsai, Y.-L., Lin, C.-Y., Lee, H.-Y., & Chen, Y.-N.** (2024). Let me speak freely? A study on the impact of format restrictions on performance of large language models. arXiv.

#### Links:

  - [Scaling LLM Test-Time Compute Optimally can be Mor](https://arxiv.org/pdf/2408.03314)
  - [Let Me Speak Freely? A Study on the Impact of Form](https://arxiv.org/pdf/2408.02442)
