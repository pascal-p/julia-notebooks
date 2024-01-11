# Synthesis of "A Practical Guide to RAG Pipeline Evaluation (Part 1: Retrieval)"
## Article Overview
- **Title**: A Practical Guide to RAG Pipeline Evaluation (Part 1: Retrieval)
- **Author**: Yi Zhang
- **Publication Date**: December 11, 2023
- **Published In**: Relari Blog
- **Reading Time**: 11 minutes
- **Article Link**: [Medium Article](https://medium.com/relari/a-practical-guide-to-rag-pipeline-evaluation-part-1-27a472b09893)
## Introduction
The article, co-authored by Yi Zhang and Pasquale Antonante at Relari.ai, is the first in a series of blog posts aimed at sharing insights on evaluating and improving Language Model (LLM) and Retrieval-Augmented Generation (RAG) Pipelines. It discusses the evolution of RAG since its introduction by the FAIR paper in 2020 and emphasizes the challenges in creating a RAG pipeline that functions effectively in production environments. The authors highlight the importance of a robust evaluation pipeline to measure and track performance, which is essential for efficient resource allocation.
## Retrieval in RAG Systems
Retrieval is identified as a critical and complex subsystem within RAG pipelines. The quality of the LLM output is contingent on the quality of the information provided by the retrieval system. The article discusses two types of metrics for assessing retrieval results: rank-agnostic metrics and rank-aware metrics. A visual illustration for these metrics is provided in an external blog post, the link to which is not included in the excerpt.
## Evaluation Metrics and Ground Truth Data
The article underscores the necessity of ground truth data for calculating deterministic retrieval metrics. It also mentions the use of LLMs to calculate proxy metrics, with the open-source evaluation package `ragas` providing a framework for this purpose. However, proxy metrics have limitations, which are to be discussed in a subsequent section.
## Experimentation and Findings
An experiment using the HotpotQA dataset is described, where a mock retrieval system's performance is evaluated. The system's precision and recall are calculated, and the LLM-based metrics for context relevance, precision, average precision, and coverage are implemented using few-shot learning prompts. The authors provide a link to the prompt templates, which is not included in the excerpt.
The findings reveal that while GPT-4 can classify binary relevancy with 79% accuracy, it tends to be conservative in categorizing context as relevant, leading to high precision but low recall. The article presents an example of false negative classifications and discusses the limitations of using LLM-based metrics for precision and average precision evaluation.
## Context Coverage vs. Context Recall
The article differentiates between Context Coverage and Context Recall, explaining that while Context Coverage can predict Context Recall with high accuracy, precision, and recall, it should not be used as a proxy for Context Recall. This is because the LLM evaluator lacks information on what relevant contexts may have been missed.
## Use of LLM Proxy Metrics for Retrieval
The authors suggest that LLM proxy metrics can provide directional insight but are not reliable for a granular assessment of the retrieval pipeline. They emphasize the challenge of creating a high-quality ground truth retrieval dataset and mention that human-verified context datasets are the best approach, with LLM-assisted generation being the next best alternative.
## Actionable Insights for Retrieval Pipeline Improvement
The article outlines three actions to improve retrieval pipelines:
1. **Benchmarking Pipelines Using Precision and Recall**: The authors argue that recall should be the primary focus before precision, as providing the right information is crucial for quality output.
2. **Selecting the Number of Chunks to Retrieve ([metric]@K)**: The tradeoff between recall and precision is discussed, and the authors suggest setting a minimum number of chunks to retrieve based on the desired recall level.
3. **Post-Processing Retrieval with Rank-Aware Metrics**: The use of second-layer rerankers or filters is recommended if the desired Recall threshold requires impractically large K values. The authors mention the Cohere Reranker as an example of a model-based approach for reranking.
## External Links and References
The article references several external resources:
- FAIR paper on RAG: [FAIR Paper](https://arxiv.org/pdf/2005.11401.pdf)
- `ragas` GitHub repository: [ragas](https://github.com/explodinggradients/ragas)
- HotpotQA dataset: [HotpotQA](https://hotpotqa.github.io/)
- Continuous evaluation GitHub repository: [continuous-eval](https://github.com/relari-ai/continuous-eval)
- Lost-in-the-middle paper: [Lost-in-the-middle](https://www-cs.stanford.edu/~nfliu/papers/lost-in-the-middle.arxiv2023.pdf)
## Conclusion
The article concludes by providing a link to the `continuous-eval` GitHub repository, which contains the code for running deterministic or LLM-based metrics mentioned in the article. The authors also tease future articles on related topics, promising to share more insights and techniques for RAG pipeline evaluation.
## Example Data
The article includes an example data snippet demonstrating the retrieval process and the evaluation of retrieved contexts against ground truth contexts and answers. The example illustrates the roles performed by Gregory Nava and Marco Bellocchio, highlighting the challenges in retrieval accuracy.
```json
{
  "question": "What roles did Gregory Nava and Marco Bellocchio both perform?",
  "retrieved_contexts": [
    "Marco Bellocchio (] ; born 9 November 1939) is an Italian film director, screenwriter, and actor.",
    "El Norte is a 1983 British-American low-budget independent drama film, directed by Gregory Nava. The screenplay was written by Gregory Nava and Anna Thomas, based on Nava's story. The movie was first presented at the Telluride Film Festival in 1983, and its wide release was in January 1984.",
    "The Confessions of Amans is a 1977 American 16mm drama film directed by Gregory Nava and written by Nava and his then newly wed wife Anna Thomas."
  ],
  "ground_truth_contexts": [
    "Marco Bellocchio (] ; born 9 November 1939) is an Italian film director, screenwriter, and actor.",
    "Gregory James Nava (born April 10, 1949) is an American film director, producer and screenwriter."
  ],
  "ground_truth_answer": [
    "film director, screenwriter"
  ]
}
```
The synthesis has been structured to capture all the ideas, reasoning, and examples presented in the article excerpt, ensuring a comprehensive and detailed understanding of the content.