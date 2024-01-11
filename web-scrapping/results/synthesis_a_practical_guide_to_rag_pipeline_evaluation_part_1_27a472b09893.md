# Synthesis of "A Practical Guide to RAG Pipeline Evaluation (Part 1: Retrieval)"
## Article Information
- **Title**: A Practical Guide to RAG Pipeline Evaluation (Part 1: Retrieval)
- **Author**: Yi Zhang
- **Date of Publication**: December 11, 2023
- **Published in**: Relari Blog
- **Reading Time**: 11 minutes
- **Article Link**: [Medium Article](https://medium.com/relari/a-practical-guide-to-rag-pipeline-evaluation-part-1-27a472b09893)
## Introduction
The article, authored by Yi Zhang and Pasquale Antonante from Relari.ai, is the first in a series of blog posts aimed at sharing insights on evaluating and improving Language Model (LLM) and Retrieval-Augmented Generation (RAG) Pipelines. The concept of RAG has evolved significantly since its introduction by the FAIR paper in 2020, becoming a prevalent method for equipping LLMs with relevant and up-to-date information. Despite the ease of setting up a basic RAG demo, creating a functional production pipeline is challenging. The article emphasizes the importance of a robust evaluation pipeline to measure and track performance, thereby guiding development efforts effectively.
## Retrieval in RAG Systems
Retrieval is a critical component of RAG systems, as the quality of the LLM's output is contingent on the information provided. The article discusses two types of metrics for assessing retrieval results: rank-agnostic and rank-aware metrics. A visual illustration of these metrics is provided in an external blog post, which is not directly linked in the excerpt. Ground truth data is essential for calculating these metrics deterministically, but LLMs can also be used to calculate proxy metrics. The open-source evaluation package `ragas` is mentioned as a framework for LLMs to assess retrieval quality.
## Experiments and Findings
An experiment using the HotpotQA dataset is described, where a mock retrieval system's performance is evaluated. The system's precision and recall are calculated, and LLM-based metrics are implemented using few-shot learning prompts. The article reports that GPT-4 can classify binary relevancy with 79% accuracy but tends to be conservative, leading to high precision but low recall. The concept of Context Coverage is introduced, which measures a different aspect of completeness compared to Context Recall. The article concludes that while LLM proxy metrics can provide directional insight, they are not a substitute for ground truth-based metrics for granular assessment.
## Actions for Improving Retrieval Pipelines
Three actions are recommended for improving retrieval pipelines:
1. **Benchmarking with Precision and Recall**: The article suggests focusing on recall before precision, as providing the right information is crucial for quality output.
2. **Using [metric]@K for Retrieval Quantity**: The trade-off between recall and precision is discussed, and the article advises determining the optimal number of chunks to retrieve based on these metrics.
3. **Post-Processing with Rank-Aware Metrics**: The use of second-layer rerankers or filters is recommended if the recall threshold is only met with an impractically large K value.
## External Links and References
The article references several external resources, including the FAIR paper, the `ragas` GitHub repository, the HotpotQA dataset, prompt templates, the Cohere Reranker, and the `lost-in-the-middle` paper. Additionally, the `continuous-eval` GitHub repository is provided for readers to run metrics on their data.
## Conclusion and Further Reading
The article concludes by emphasizing the importance of a human-verified context dataset for reliable evaluation and announces a forthcoming article detailing techniques and tools for creating a high-quality evaluation dataset for retrieval. Readers are encouraged to stay tuned for upcoming articles on related topics.
## External Links and References (Detailed)
- FAIR paper on RAG: [FAIR Paper](https://arxiv.org/pdf/2005.11401.pdf) (PDF)
- `ragas` GitHub repository: [ragas](https://github.com/explodinggradients/ragas)
- HotpotQA dataset: [HotpotQA](https://hotpotqa.github.io/)
- Prompt templates: Link not provided in the excerpt
- Cohere Reranker: Mentioned without a direct link
- `lost-in-the-middle` paper: [Lost in the Middle](https://www-cs.stanford.edu/~nfliu/papers/lost-in-the-middle.arxiv2023.pdf) (PDF)
- `continuous-eval` GitHub repository: [continuous-eval](https://github.com/relari-ai/continuous-eval)
The excerpt also contains several Medium-specific links related to signing in, subscribing, and accessing various Medium resources, which are not directly relevant to the content of the article and are therefore not detailed here.