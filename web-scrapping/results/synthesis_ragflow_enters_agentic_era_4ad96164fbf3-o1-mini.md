## Article Information
- **Title:** RAGFlow Enters Agentic Era
- **Author:** InfiniFlow
- **Publication Date:** July 15, 2024
- **Link:** [RAGFlow Enters Agentic Era](https://medium.com/@infiniflowai/ragflow-enters-agentic-era-4ad96164fbf3)
## Introduction
As of version 0.8, RAGFlow officially enters the Agentic era, introducing a comprehensive graph-based task orchestration framework on the back end and a no-code workflow editor on the front end. This advancement raises questions about the significance of being "agentic" and how this feature differentiates RAGFlow from existing workflow orchestration systems.
## Relationship Between RAG and Agent
To understand the agentic shift, it is essential to explore the relationship between Retrieval-Augmented Generation (RAG) and agents. Without RAG, Large Language Models (LLMs) have limited access to private data through long contexts, making it challenging to use agents for enterprise scenarios. Applications such as customer service, marketing recommendations, compliance checks, and inventory optimization require more than what long-context LLMs and simple workflow assemblies can provide. A basic RAG system, exemplified by single-round dialogue, is crucial for supporting agent orchestration within workflows. RAG serves as an architectural pattern enabling LLMs to access private enterprise data. An advanced RAG system should handle multi-hop question-answering with cross-document reasoning and query decomposition for clear user intents and work alongside agents for ambiguous queries, employing dynamic agent orchestration to evaluate and rewrite queries and perform multi-hop reasoning. Essentially, agents and RAG are complementary, enhancing each other's capabilities in enterprise applications.
## RAGFlow’s Success and Popularity
Since its open-source release, RAGFlow has achieved significant success, garnering 10,000 GitHub stars in less than three months. This milestone prompts a reflection on RAGFlow’s achievements and an exploration of its future transformative potential.
## RAG 1.0: Current Workflow and Limitations
RAGFlow’s typical workflow follows a semantic similarity-based approach that has remained consistent over several years, divided into four stages: document chunking, indexing, retrieval, and generation. While straightforward to implement, this naive semantic similarity-based search system has several limitations:
- **Chunk-Level Operation:** The embedding process struggles to differentiate tokens that require increased weight, such as entities, relationships, or events, leading to low-density effective information in generated embeddings and poor recall.
- **Inadequate Embeddings:** Embeddings are insufficient for precise retrieval. For instance, a query about company portfolios in March 2024 might yield unrelated portfolios from different periods or other types of data.
- **Model Dependence:** Retrieval results heavily depend on the chosen embedding model, with general-purpose models potentially underperforming in specific domains.
- **Sensitive to Data Chunking:** The retrieval results are highly sensitive to data chunking methods. The LLMOps-based system’s simplistic document chunking leads to a loss of data semantics and structure.
- **Lack of User Intent Recognition:** Improving similarity search alone does not effectively enhance answers for ambiguous user queries.
- **Inability to Handle Complex Queries:** The system cannot manage multi-hop question-answering, which requires multi-step reasoning from heterogeneous information sources.
Therefore, the current LLMOps-centric system, viewed as RAG 1.0, features orchestration and ecosystem but falls short in effectiveness. Developers can quickly prototype with RAG 1.0 but often encounter challenges in real enterprise settings. Consequently, RAG must evolve with LLMs to facilitate specialized domain searches.
## Vision for RAG 2.0
Based on the limitations of RAG 1.0, RAG 2.0 is proposed as an end-to-end search system divided into the following stages: information extraction, document preprocessing, indexing, and retrieval. RAG 2.0 cannot be orchestrated using LLMOps tools designed for RAG 1.0 due to coupled stages, lack of unified APIs and data formats, and circular dependencies. For example, query rewriting essential for multi-hop question-answering and user intent recognition involves iterative retrieval and rewriting.
### Key Features and Components of RAG 2.0
- **Comprehensive Database:** Supports hybrid searches beyond vector search, including full-text search, sparse vector search, and Tensor search, which supports late interaction mechanisms like ColBERT.
- **Optimized RAG Pipeline:** Encompasses separate data extraction and cleansing modules for chunking user data, recognizing complex document structures, and adjusting chunking sizes based on retrieval results.
- **Preprocessing Procedures:** Involves knowledge graph construction, document clustering, and domain-specific embedding to ensure retrieval results contain necessary answers, addressing multi-hop questions, ambiguous intents, and domain-specific queries.
- **Refined Retrieval Stage:** Incorporates coarse and refined ranking, with refined ranking typically occurring outside the database using different reranking models. User queries undergo continuous rewriting based on AI-recognized intents until satisfactory answers are retrieved.
Each stage in RAG 2.0 is built around AI models that work in conjunction with the database to ensure effective final answers.
## RAGFlow’s Features Towards RAG 2.0
The current open-source version of RAGFlow primarily addresses the first stage of the pipeline by using deep document understanding models to ensure data quality. Additionally, it employs dual-retrieval during indexing, combining keyword full-text search with vector search. These features distinguish RAGFlow from other RAG products, indicating that it is progressing towards RAG 2.0.
## Agentic RAG Implementation in RAGFlow v0.8
RAGFlow v0.8 integrates agents to better support the subsequent stages in the RAG 2.0 pipeline. For example, to handle ambiguous queries in dialogue, RAGFlow introduces a Self-RAG-like mechanism for scoring retrieval results and rewriting user queries. This mechanism utilizes agents to implement a reflective Agentic RAG system, operating as a cyclic graph rather than a traditional Directed Acyclic Graph (DAG). This cyclic graph orchestration system incorporates a reflection mechanism for agents, enabling them to explore user intents, adapt dynamically to context, guide conversations, and deliver high-quality responses. The ability to reflect underpins agent intelligence.
## No-Code Workflow Orchestration
The introduction of Agentic RAG and workflow facilitates the integration of RAG 2.0 into enterprise retrieval scenarios. To support this integration, RAGFlow offers a no-code workflow editing approach applicable to both Agentic RAG and workflow business systems. The no-code workflow orchestration system includes several built-in templates, such as customer service and HR call-out assistant templates, with plans to expand the template list to cover more scenarios.
### Example Workflows
- **Self-RAG Workflow:** A ‘Relevant’ operator assesses the relevance of retrieved results to the user query. If deemed irrelevant, the query is rewritten, and the process repeats until satisfactory results are achieved.
- **HR Candidate Management System:** Exemplifies a multi-round dialogue scenario with a corresponding sample conversation following the no-code orchestration template.
## Workflow Operators
RAGFlow’s no-code orchestration system includes various workflow operators:
- **Functional Operators:** Closely related to RAG and dialogue, distinguishing RAGFlow from other RAG systems.
- **Tool Operators:** Include a couple of tools, with plans to add more as RAGFlow evolves. Existing workflow agent systems have incorporated many such tools, and RAGFlow is in its early stages of development.
## Differentiation from Similar RAG Projects
RAGFlow’s no-code orchestration differs from similar RAG projects in several key ways:
1. **RAG-Centric Approach:** Emphasizes how RAG supports domain-specific businesses in enterprise-level scenarios, rather than being LLM-centric.
2. **Core Requirements of RAG 2.0:** Addresses essential features such as query intent recognition, query rewriting, and data preprocessing to provide precise dialogues.
3. **Integration with Business Systems:** Accommodates workflow orchestration in business systems, enhancing precision and effectiveness in enterprise applications.
## Future Vision
The envisioned future for RAGFlow is to become an Agentic RAG 2.0 platform with the ultimate goal of enabling RAG to seamlessly "flow" in enterprise scenarios. The project invites those who share this vision to follow and star the project on GitHub.