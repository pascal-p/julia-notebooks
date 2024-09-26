# Beyond Model Size: The Future of LLM Optimisation
## Introduction
The article "Beyond Model Size: The Future of LLM Optimisation" discusses recent advancements in optimising test-time computation for Large Language Models (LLMs). Two notable research papers, "Scaling LLM Test-Time Compute Optimally can be More Effective than Scaling Model Parameters" by Snell et al. from UC Berkeley and Google DeepMind, and "Let Me Speak Freely? A Study on the Impact of Format Restrictions on Performance of Large Language Models" by Tam et al. from Appier AI Research and National Taiwan University, challenge the conventional approach of scaling up LLM parameters for better performance. Instead, they propose optimising test-time compute, also known as inference compute, which refers to the computational resources used when an LLM generates responses to prompts.
## Test-Time Compute Optimisation
Test-time compute is distinct from training compute, which is used to create and refine the model. By strategically allocating computational resources during inference, organisations can enhance the performance of existing language models without the substantial costs associated with larger-scale training. This approach is particularly beneficial for businesses designing Retrieval-Augmented Generation (RAG) pipelines and refining prompt engineering strategies. The article explores eight strategies for optimising LLM performance at inference time.
## Strategies for Optimising LLM Performance at Inference Time
### 1. Best-of-N Sampling
Best-of-N sampling involves generating multiple independent responses (N) to a given prompt and selecting the best response using a verifier, such as a Process Reward Model (PRM). This method increases the likelihood of finding a high-quality response by exploring a wider range of potential answers.
```code
P(best) = 1 - (1 - p)^N
```
- `p`: Probability of generating a correct response in a single attempt
- `N`: Number of independent responses generated
Example implementation in a RAG pipeline:
```python
def best_of_n_rag(query, n=5):
  documents = retrieve_top_n_documents(query, n)
  responses = []
  for doc in documents:
    prompt = f"Given the context: {doc}\nAnswer the query: {query}"
    responses.append(generate_response(prompt))
  return select_best_response(responses)
```
### 2. Sequential Revisions
Sequential Revisions involve generating an initial response and iteratively revising it, allowing the model to learn from and improve upon its past outputs.
```code
Q(t) = Q_max - (Q_max - Q_0) * e^(-λt)
```
- `Q(t)`: Quality at revision `t`
- `Q_max`: Maximum achievable quality
- `Q_0`: Initial quality
- `λ`: Rate of improvement
Example implementation:
```python
def enhanced_sequential_revisions(query, max_revisions=3):
  response = generate_initial_response(query)
  for _ in range(max_revisions):
    response = revise_response(response)  # Revise the response iteratively
    if structured_output_required():
      return convert_to_structured_format(response)
  return response
```
### 3. Beam Search
Beam Search is a heuristic search algorithm that explores multiple promising paths simultaneously, maintaining a set of "beams" and expanding them in parallel.
```code
B(t) = top_k(expand(B(t-1)))
```
- `B(t)`: Set of beams at step `t`
- `top_k`: Selects the `k` highest-scoring candidates
- `expand`: Generates all possible next steps from the current beams
Example implementation:
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
```
### 4. Lookahead Search
Lookahead Search extends Beam Search by simulating future steps before deciding which paths to pursue, providing a better estimate of the overall solution quality.
```code
V(s) = max(R(s), γ * max(V(s')))
```
- `V(s)`: Value of state `s`
- `R(s)`: Immediate reward of state `s`
- `γ`: Discount factor
- `s'`: Possible future states reachable from `s`
Example implementation:
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
```
### 5. Hybrid Approaches
Hybrid Approaches combine multiple test-time compute strategies to leverage their complementary strengths and mitigate individual weaknesses.
```code
E[H] = max(E[S1], E[S2], ..., E[Sn])
```
- `E[H]`: Expected performance of the hybrid approach
- `E[Si]`: Expected performance of the i-th strategy
Example implementation:
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
```
### 6. Compute-Optimal Scaling
Compute-Optimal Scaling involves adaptively choosing the best test-time compute strategy based on the estimated difficulty or complexity of the task.
```code
S* = argmax_S (P(correct|S, d) / C(S))
```
- `S*`: Optimal strategy
- `P(correct|S, d)`: Probability of getting a correct answer given strategy `S` and difficulty `d`
- `C(S)`: Computational cost of strategy `S`
Example implementation:
```python
def compute_optimal_prompting(query):
  complexity = assess_query_complexity(query)
  if complexity == 'low':
    return simple_prompt_strategy(query)
  elif complexity == 'medium':
    return beam_search_prompting(query, beam_width=3, max_depth=2)
  else:  # high complexity
    return hybrid_prompting(query, n_initial=5, beam_width=3, max_revisions=2)
```
### 7. Process Reward Model (PRM) Guided Search
PRM Guided Search uses a learned reward model to provide feedback and guidance during the generation process, steering the LLM towards more promising directions.
```code
R(s, a, s') = f(φ(s, a, s'))
```
- `R`: Reward
- `s`: Current state
- `a`: Action taken
- `s'`: Next state
- `φ`: Feature function
- `f`: Learned reward function
Example implementation:
```python
def prm_guided_prompting(query, n_candidates=10, n_iterations=3):
  candidates = generate_initial_prompts(query, n_candidates)
  for _ in range(n_iterations):
    responses = [generate_response(prompt) for prompt in candidates]
    scores = reward_model.evaluate(responses)
    best_candidates = select_top_k(candidates, scores, k=n_candidates//2)
    candidates = best_candidates + generate_variations(best_candidates, n_candidates//2)
  return select_best(candidates, reward_model)
```
### 8. Majority Voting
Majority Voting involves generating multiple answers to a query and selecting the most common or frequent answer as the final output.
```code
P(correct) = Σ (k=⌊N/2⌋+1 to N) C(N,k) * p^k * (1-p)^(N-k)
```
- `N`: Number of votes
- `p`: Probability of each vote being correct
- `C(N, k)`: Binomial coefficient
Example implementation:
```python
def majority_voting_prompting(query, n_prompts=5, n_responses_per_prompt=3):
  prompts = generate_diverse_prompts(query, n_prompts)
  all_responses = []
  for prompt in prompts:
    responses = [generate_response(prompt) for _ in range(n_responses_per_prompt)]
    all_responses.extend(responses)
  return aggregate_responses(all_responses)
```
## Applications in Search GPT
The article discusses how these test-time compute strategies are applied in real-world AI applications like Perplexity.ai, an innovative search engine leveraging sophisticated LLM techniques. The sliding window approach, efficient sampling, hierarchical computation, and optimised hardware utilisation are highlighted as practical implementations of these strategies.
## Conclusion
The research by Snell et al. and Tam et al. presents a compelling case for rethinking LLM progress beyond the mantra of 'bigger is better'. By focusing on test-time compute approaches, substantial performance gains can be achieved for existing and smaller LLMs without costly model retraining. The article anticipates future advancements in hybrid strategies, hardware-optimised approaches, and integrated development environments, promising a future where LLMs are more capable, efficient, accessible, and ethically deployed.
#### Links:
  - [Scaling LLM Test-Time Compute Optimally can be Mor](https://arxiv.org/pdf/2408.03314)
  - [Let Me Speak Freely? A Study on the Impact of Form](https://arxiv.org/pdf/2408.02442)