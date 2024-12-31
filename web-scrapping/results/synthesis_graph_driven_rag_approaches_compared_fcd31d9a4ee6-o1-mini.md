## Article Information
- **Title**: Graph-driven RAG: Approaches Compared (Part 3)
- **Author**: Ryan Oattes
- **Publication Date**: August 4, 2024
- **Link**: https://ryanoattes.medium.com/graph-driven-rag-approaches-compared-fcd31d9a4ee6
## Microsoft-type Graph RAG
This approach incorporates several critical components, utilizing a Large Language Model (LLM) to extract individual “facts” from source data. These facts, referred to as “triples,” consist of Subject, Predicate, and Object. Advanced extraction techniques via LLMs also perform initial categorization. For instance, the sentence “Ryan likes graphs.” would generate the triple (“Ryan (a person)”, “likes”, “graphs (a data structure)”). Building on previously created text chunks for Basic RAG, a graph is constructed using a LangChain transformer.
## LangChain Transformer Implementation
```python
from langchain_experimental.graph_transformers import LLMGraphTransformer
llm_transformer = LLMGraphTransformer(llm=chat_model, node_properties=False, relationship_properties=False)
```
## Graph Document Conversion
Different methods exist for initially extracting graph data from text. The current approach simplifies this process, with plans to expand in future posts. Typically, each document chunk is fed to the transformer, resulting in a GraphDocument.
```python
graph_doc = llm_transformer.convert_to_graph_documents([doc])
```
## GraphDocuments Structure
GraphDocuments provide a list of “nodes” representing Subjects and Objects, and a list of “relationships” that form edges between nodes in the knowledge graph.
## Handling Misalignments
Despite careful prompting, inconsistencies can arise in how entities are identified by the LLM across extractions. These misalignments fall into two categories:
- **Syntactic Differences**: Variations like “R. Oattes” versus “Ryan Oattes” or “Microsoft” versus “Microsoft Inc.” These can often be resolved using non-AI techniques such as edit distance analysis.
  
- **Semantic Same-ness**: Concepts like “Sports Team” and “Athletic Club” share similarities but differ significantly in edit distance. Addressing this is more challenging but crucial for accurately connecting concepts in the knowledge graph.
The Microsoft research paper does not extensively address this, which may suffice for certain datasets and analysis levels. Alternative solutions online tackle the “master data” problem using methods like the Levenshtein algorithm. This implementation leverages functions from the Kobai SDK for entity type classification and contextual compression to enhance knowledge graph quality. The Kobai graph database on Databricks facilitates scalable N:N analysis of entity similarity.
## Community Detection
Community detection involves identifying clusters of nodes that are “related” within the graph, technically referred to as “optimized modularity.” This process divides nodes into groups where connections within the group are denser than connections outside the group.
The Microsoft authors utilize the Leiden algorithm for top-down recursive community identification, initially finding large communities and subsequently dividing them into sub-communities.
### Implementation Details
The current implementation differs by incorporating additional techniques to deduplicate nodes and eliminate overly similar community layers using the Kobai SDK. Only lower-level communities containing at least three times the number of higher-level communities are accepted, preventing excessive redundancy.
Ultimately, three tiers of communities were generated, each with respective counts.
## Summarizing Communities
To utilize these communities, an LLM generates summaries based on the nodes and relationships they encompass. The following prompt structure is used:
```python
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
class_template = """#Goal
Your task is to generate a concise but complete report on the provided graph data belonging to the same graph community. The content of this report includes an overview of the community's key entities and relationships.
#Report Structure
The report should include the following sections:
TITLE: Community's name that represents its key entities - title should be short but specific. When possible, include representative named entities in the title.
SUMMARY: Based on the provided nodes and relationships that belong to the same graph community, generate a natural language summary that explains the scope of this community, what topics of knowledge it covers, and what sort of questions it would be useful in answering.
DETAILS: Provide condensed information on facts contained within the graph data. Be sure to include all named entities.
{class_info}
Summary:"""
class_prompt = ChatPromptTemplate.from_messages([
    ("system", "Given an input triples, generate the information summary. No pre-amble."),
    ("human", class_template),
])
community_chain = class_prompt | chat_model | StrOutputParser()
```
The `{class_info}` placeholder is filled with a structured list of all nodes and relationships within the community, then fed to the DBRX model.
### Example Summary
An example community summary retrieved from the database includes references to “penguin” and notes its role as a team mascot.
## Vector Search Integration
Similar to the RAG example, these summaries are embedded using Databricks Vectorsearch and stored as vectors. When querying, the vector search retriever operates on the new vector index containing summaries instead of raw source text chunks.
Initially, the vector store retriever retrieves the five best community summaries. Upon inspection, three summaries have promising titles and descriptions, while the other two are more extensive and lack the requested Title and Summary components. These two types of communities might serve as complementary data sources.
## Comparative Analysis
The results demonstrate that this approach is superior to Basic RAG. Compared to Context Compressed RAG, it offers a closer comparison but ensures more efficient utilization of LLM tokens.
## Next Steps
**Part 4** — [Link to next part]
#### Links:
  - [graph+medium.com tag knowledge-graph?source=post_p](https://medium.com/tag/knowledge-graph?source=post_page-----fcd31d9a4ee6--------------------------------)