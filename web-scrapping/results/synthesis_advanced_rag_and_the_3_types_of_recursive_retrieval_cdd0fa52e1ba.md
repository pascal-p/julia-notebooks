### Article Overview
#### Title: Advanced RAG and the 3 types of Recursive Retrieval
#### Author and Date: Chia Jeng Yang, Jan 31, 2024
#### Publication: Enterprise RAG
#### Reading Time: 7 min read
---
### Main Content
The article by Chia Jeng Yang, published in Enterprise RAG on January 31, 2024, explores the concept of Recursive or Iterative Retrieval in the development of self-learning Retrieval-Augmented Generation (RAG) systems. These systems are designed to learn over time and deeply explore unstructured data, either autonomously or directed by a knowledge graph.
Anthony Alcaraz, CAIO at Fribl, describes recursive retrieval as a process where a query is applied across smaller chunks of a corpus, with intermediate results being recursively fed into subsequent steps and aggregation combining the outputs. This involves a Language Model (LLM) agent that continuously scans for relevant sentences and paragraphs, retrieves them, and then combines them to examine the answer, including any references to other concepts or pages that may hint at the final answer.
The article highlights three significant implications of Recursive or Iterative Retrieval:
1. It provides consistent and exhaustive retrieval of a core idea, acting as a memory base for future reference.
2. It enables multi-hop retrieval across multiple documents.
3. It ties an increase in unstructured data input to a tangible increase in LLM accuracy.
In a multi-hop retrieval context, the seed node and the relationships it needs to track are generated automatically by the LLM in response to a query. This allows the LLM to use a knowledge graph to tackle multi-hop queries, creating knowledge graphs iteratively and 'just-in-time' for a specific question.
The article then delves into three different approaches to recursive retrieval:
1. **Page-Based Recursive Retrieval**: This approach involves tracking and diving deeper into subsequent pages referenced by the LLM as it retrieves information and constructs a knowledge graph. It is particularly useful for technical manuals in manufacturing industries, where the agent follows a deterministic pathway driven by page references. However, it has limitations if references are not present or consistent.
2. **Information-Centric Recursive Retrieval**: This approach focuses on a seed node or main concept, allowing the LLM to discover key relationships to track based on the desired understanding. The knowledge graph expands directionally smarter over time as more information is processed. This approach is useful for look-ups and can be employed across time and documents, acting as a contextually aware filter that constantly adds information to the relevant concept.
3. **Concept-Centric Recursive Retrieval**: This approach is for the retrieval of concepts, where the LLM decides on top-level nodes and n+2 nodes based on their potential relevance to the question. The difficulty lies in controlling the LLM to ensure relevance and understanding when the right answer is reached. This can be tackled with good prompting, multi-agent construction, expert qualitative feedback, and pre-processing work, such as creating a contextual dictionary.
The article concludes by inviting developers to engage with WhyHow.AI for assistance in incorporating knowledge graphs into their RAG pipelines.
---
### Related Articles and Links
- The article provides links to related articles on RAG optimization and crafting knowledgeable AI with retrieval augmentation.
- It also includes links to the author's profile, the publication Enterprise RAG, and other resources such as status updates and text-to-speech options for Medium articles.
---
### Author Information
Chia Jeng Yang is an editor for Enterprise RAG and the Co-Founder of WhyHow.AI. The author has a following of 2.5K and invites readers to engage in further discussions or inquiries via the provided contact email, team@whyhow.ai.
---
### Conclusion
The article presents a detailed examination of advanced RAG systems and the three types of Recursive Retrieval: Page-Based, Information-Centric, and Concept-Centric. Each approach offers unique benefits and challenges in the context of self-learning systems and knowledge graph utilization. The potential for these systems to improve the accuracy and efficiency of information retrieval is underscored, with an emphasis on the evolving nature of RAG systems and their applications.
#### Links:
  - [Open in app - rsci.app.link](https://rsci.app.link/?%24canonical_url=https%3A%2F%2Fmedium.com%2Fp%2Fcdd0fa52e1ba&%7Efeature=LoOpenInAppButton&%7Echannel=ShowPostUnderCollection&source=---two_column_layout_nav----------------------------------)
  - [medium.com](https://medium.com/enterprise-rag?source=post_page-----cdd0fa52e1ba--------------------------------)
  - [Status+medium.statuspage.io ?source=post_page-----](https://medium.statuspage.io/?source=post_page-----cdd0fa52e1ba--------------------------------)
  - [Text to speech - speechify.com](https://speechify.com/medium?source=post_page-----cdd0fa52e1ba--------------------------------)