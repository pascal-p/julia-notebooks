# Synthesis of "A Practical Guide to RAG Pipeline Evaluation (Part 2: Generation)"
## Article Information
- **Title**: A Practical Guide to RAG Pipeline Evaluation (Part 2: Generation)
- **Author**: Yi Zhang
- **Date of Publication**: December 20, 2023
- **Published in**: Relari Blog
- **Reading Time**: 9 minutes
- **Article Link**: [Medium Article](https://medium.com/relari/a-practical-guide-to-rag-evaluation-part-2-generation-c79b1bde0f5d)
## Introduction
The article is the second installment in a series aimed at providing insights into the evaluation and improvement of Language Model (LLM) and Retrieval-Augmented Generation (RAG) Pipelines. Authored by Yi Zhang and Pasquale Antonante from Relari.ai, this piece focuses on the evaluation of the generation aspect of RAG pipelines, which involves assessing the answers generated by LLMs. The authors previously discussed retrieval evaluation in Part 1, emphasizing the use of both deterministic metrics and LLM-based metrics without ground truth labels.
## Generation Evaluation
Generation evaluation is distinct from retrieval evaluation, as it deals with the quality of answers produced by LLMs rather than the retrieval of information. The evaluation of generation is inherently more subjective and context-dependent, posing a challenge for evaluators. Two primary approaches to generation evaluation are identified:
1. Holistic evaluation of the generated answer (A) with respect to ground truth answers (A*).
2. Evaluation of specific aspects of the generated answer (A) in relation to the question (Q) and retrieved contexts (C), without ground truth answers (A*).
## Metrics for Generation Evaluation
The article categorizes the metrics used for generation evaluation into three groups:
1. **Deterministic Metrics**: These include ROUGE, Token Overlap, and BLEU, which compare tokens between the answer and reference and calculate the overlap. They are fast but lack semantic understanding.
2. **Semantic Metrics**: Utilizing models like DeBERTa-v3 NLI, these metrics assess the relationship between sentence pairs, determining contradiction, entailment, and neutrality.
3. **LLM-based Metrics**: These are versatile and can evaluate various aspects of an answer by providing appropriate prompts to a capable model.
## Correlation with Human Assessment
The authors analyze how well these metrics correlate with human judgment using a dataset from the paper "Evaluating Correctness and Faithfulness of Instruction-Following Models for Question Answering." They find that LLM-based metrics, particularly GPT-4, have the highest correlation with human labels for correctness. For faithfulness, deterministic metrics are not significantly outperformed by LLM-based metrics, which excel when using complex prompts.
## Ensemble Metrics for Cost-Effective Evaluation
Given that LLM-based metrics align closely with human judgment but are costly and slow, the authors propose creating Ensemble Metrics. These combine the strengths of individual metrics to predict human labels more accurately and cost-effectively. They test three ensemble models:
1. Deterministic Ensemble
2. Semantic Ensemble
3. Deterministic Semantic Ensemble (Det_Sem Ensemble)
The Det_Sem Ensemble shows notable improvement in balancing precision and recall and outperforms individual metrics in precision for correctness classification.
## Hybrid Evaluation Pipeline
To further enhance cost-effectiveness, the authors integrate GPT-4 into a Hybrid Pipeline, which matches GPT-4's performance while running it on only 7% of data points, reducing costs by 15 times. They employ Conformal Prediction to quantify the confidence level of predictions, using GPT-4 to judge correctness only for undecided data points.
## External Links and References
- DeBERTa-v3 NLI Model: [Hugging Face Model](https://huggingface.co/cross-encoder/nli-deberta-v3-large)
- Paper on Evaluating Correctness and Faithfulness: [arXiv Paper](https://arxiv.org/pdf/2307.16877.pdf)
- Paper on Uncertainty Quantification for Black-Box LLMs: [arXiv Paper](https://arxiv.org/pdf/2305.19187.pdf)
- GitHub Repository for Continuous Evaluation: [GitHub Repo](https://github.com/relari-ai/continuous-eval)
## Conclusion
The article concludes that while LLM-based metrics are most aligned with human judgment, simpler metrics can also be effective in evaluating the quality of generated answers. By combining different metrics into an ensemble and utilizing conformal prediction, it is possible to create a cost-effective evaluation pipeline that maintains high accuracy and reliability.
## Upcoming Articles
The authors tease future articles that will continue the discussion on RAG pipeline evaluation.
(Note: The synthesis includes all pertinent information from the provided excerpt. However, some links and references mentioned in the excerpt are not fully detailed due to the absence of complete URLs or descriptions within the excerpt itself.)