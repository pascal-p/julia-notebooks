# Synthesis of "Text Summarization with LLMs"
## Article Metadata
- **Title:** Text Summarization with LLMs
- **Author:** Pritam Paul
- **Date of Publication:** April 11, 2023
- **Reading Time:** 6 minutes
- **Article Link:** [Text Summarization with LLMs](https://medium.com/@pablopaul1999/text-summarization-with-llms-c7443dc1d7d5)
## Introduction
The article introduces the concept of text summarization using Large Language Models (LLMs), with a focus on GPT-3.5 turbo. It emphasizes the advancements in natural language processing that allow for contextually accurate text generation. The author, Pritam Paul, outlines the prerequisites for using OpenAI's API and provides a step-by-step guide to building a text summarization web application using Python and Streamlit.
## Prerequisites and Setup
Before delving into the construction of the text summarizer, the author lists essential prerequisites:
1. Registration on the OpenAI developer platform and creation of an API key, with a cautionary note to securely save the API key as it is not retrievable once generated.
2. Installation of two dependencies using pip commands:
   - `pip install openai`
   - `pip install streamlit`
## Building the Text Summarizer
The author describes the process of building the text summarizer, which involves interacting with the OpenAI GPT-3.5 turbo model through the ChatCompletion API. This API allows for the creation of a conversational interface that can generate summarizations based on prompts.
### Code Analysis
The article provides a detailed analysis of the Python code used to build the summarizer. It explains the significance of the `messages` hyperparameter, which contains two dictionary objects:
1. The first dictionary sets the model to act as a text summarizer.
2. The second dictionary is where the actual text to be summarized is passed.
The author also introduces the `person_type` and `prompt` variables, which control the style of the summary and the input text, respectively.
## Streamlit Web Application
The article transitions to the development of the web application using Streamlit. The author instructs saving the Python code in a file named `summarize.py` and provides the command to initiate the application:

streamlit run summarize.py

Upon running this command, the application becomes accessible in the default web browser, allowing users to input text and receive summaries.
## Experimentation and Observations
The author encourages experimentation with hyperparameters to observe how they affect the output. A notable parameter is `who are you?`, which adjusts the response style of GPT-3.5 based on the user's persona, such as a second-grader or a university student.
## Industry Implications
The article concludes by highlighting the potential of Generative AI to solve industry problems more efficiently. It emphasizes the practical application of OpenAI's APIs in creating tools like the text summarization application.
## Additional Resources and Conclusion
For the complete code, the author refers readers to the GitHub repository:
- **GitHub Repository:** [Text-Summarization-with-LLMs](https://github.com/Pritam868/Text-Summarization-with-LLMs)
The author also provides a link to their LinkedIn profile for further engagement:
- **LinkedIn Profile:** [thepetrolhead](https://www.linkedin.com/in/thepetrolhead/)
In conclusion, the article serves as a comprehensive guide to creating a text summarization application using LLMs, with practical insights into the use of OpenAI's API and the Streamlit package. The author, Pritam Paul, shares his expertise and encourages readers to explore the capabilities of GPT-3.5 turbo through hands-on application development.