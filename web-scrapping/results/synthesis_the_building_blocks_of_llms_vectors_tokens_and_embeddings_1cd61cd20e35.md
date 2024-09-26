# The Building Blocks of LLMs: Vectors, Tokens and Embeddings
## Article Information
- **Title**: The Building Blocks of LLMs: Vectors, Tokens and Embeddings
- **Author and Date**: Not specified
- **Publication Date**: April 9, 2024
## Vectors: The Language of Machines
Vectors are fundamental to the operation of Large Language Models (LLMs) and generative AI. They are mathematical objects characterized by both magnitude and direction, often represented as directed line segments. In LLMs, vectors are used to numerically represent text or data, a representation known as an embedding. Embeddings are high-dimensional vectors that encapsulate the semantic meaning of words, sentences, or documents, enabling LLMs to perform tasks like text generation and sentiment analysis.
Since machines only comprehend numbers, data such as text and images are converted into vectors, the sole format understood by neural networks and transformer architectures. Operations on vectors, such as the dot product, are crucial for determining vector similarity, forming the basis for similarity searches in vector databases.
### Code Example: Basic Vector Operations
The following Python code snippet demonstrates basic vector operations using the `numpy` library:
```python
import numpy as np
# Creating a vector from a list
vector = np.array([1, 2, 3])
print("Vector:", vector)
# Vector addition
vector2 = np.array([4, 5, 6])
sum_vector = vector + vector2
print("Vector addition:", sum_vector)
# Scalar multiplication
scalar = 2
scaled_vector = vector * scalar
print("Scalar multiplication:", scaled_vector)
```
## Tokens: The Building Blocks of LLMs
Tokens are the fundamental units of data processed by LLMs. In text processing, a token can be a word, subword, or character, depending on the tokenization process. A tokenizer encodes text into tokens based on a specific scheme, which varies with different LLMs. The tokenizer's role is to convert text into tokens for input and decode tokens back into text for output. The context length of an LLM refers to its capacity to handle a specific number of tokens as input and output.
### Code Example: Tokenization
The following code snippets illustrate how text is tokenized using the `transformers` module from Hugging Face for Llama 2 and `tiktoken` from OpenAI for GPT-4.
#### Llama 2 Tokenization
```python
from transformers import AutoTokenizer
model = "meta-llama/Llama-2-7b-chat-hf"
tokenizer = AutoTokenizer.from_pretrained(model,token="HF_TOKEN")
text = "Apple is a fruit"
token = tokenizer.encode(text)
print(token)
decoded_text = tokenizer.decode(token)
print(decoded_text)
```
#### GPT-4 Tokenization
```python
import tiktoken
tokenizer=tiktoken.encoding_for_model("gpt-4")
text = "Apple is a fruit"
token=tokenizer.encode(text)
print(token)
decoded_text = tokenizer.decode(token)
print(decoded_text)
```
## Embeddings: The Semantic Space
Embeddings are tokens enriched with semantic context, representing the meaning and context of text. An embeddings model generates text embeddings in vector form, allowing LLMs to understand language nuances and perform tasks like sentiment analysis and text summarization. Embeddings are vectors trained to capture semantic relationships, serving as the entry point to LLMs and converting text into vectors while retaining semantic context.
### Code Example: Generating Embeddings
The following examples demonstrate generating embeddings using an open-source model, `sentence-transformers/all-MiniLM-L6-v2`, and OpenAI's `text-embedding-3-small`.
#### Sentence Transformers Embedding
```python
from sentence_transformers import SentenceTransformer
sentences = ["Apple is a fruit", "Car is a vehicle"]
model = SentenceTransformer('sentence-transformers/all-MiniLM-L6-v2')
embeddings = model.encode(sentences)
print(len(embeddings[0]))
print(embeddings)
```
#### OpenAI Embedding
```python
from openai import OpenAI
client = OpenAI(api_key="OPENAI_API_KEY")
model="text-embedding-3-small"
sentences = ["Apple is a fruit", "Car is a vehicle"]
embeddings=client.embeddings.create(input = sentences, model=model).data[0].embedding
print(len(embeddings))
print(embeddings)
```
## Comparison and Interaction
Tokens are linguistic units, while vectors are their mathematical representations. Each token is mapped to a vector in the LLM's processing pipeline. While all embeddings are vectors, not all vectors qualify as embeddings. Embeddings are vectors specifically trained to capture deep semantic relationships. The transition from tokens to embeddings signifies a shift from discrete language representation to a nuanced, continuous, and contextually aware semantic space.
#### Links:
