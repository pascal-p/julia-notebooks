# From Prompt Engineering to Auto Prompt Optimisation
## Introduction
- **Title**: From Prompt Engineering to Auto Prompt Optimisation
- **Author and Date**: A case study for Marketing Content Generation
- **Publication Date**: October 2, 2023
In the contemporary digital marketing landscape, Artificial Intelligence (AI) is increasingly becoming a central element in driving innovative strategies. Generative AI, a subset of AI, is particularly influential in this domain. This article explores the use of Prompt Engineering alongside AWS Generative AI services, such as Amazon Bedrock, to create marketing content that is both engaging and effective in conversion. Prompt Engineering involves crafting precise prompts to guide AI models in generating desired outputs, which is transformative for marketers aiming to produce tailored content at scale. The article also discusses Automatic Prompt Optimization using Large Language Models (LLMs) as optimizers, inspired by the work of Yang et al. on "Large Language Models as Optimizers." The focus is on leveraging this approach to enhance marketing strategies by generating more engaging content.
## What You Will Learn
- **Prompt Engineering**: Understanding the art and science behind crafting effective prompts.
- **Integration with AWS**: Aligning Prompt Engineering with Amazon Generative AI Services for optimal results.
- **Case Study**: A practical example of using Prompt Engineering for marketing content generation, highlighting common pitfalls and how to avoid them.
- **Automatic Prompt Optimization**: An overview of how automatic prompt optimization works and its outcomes, along with current challenges and solutions.
## What is Prompt Engineering?
Prompt Engineering is the practice of crafting text inputs to guide generative AI models, such as text-to-text and text-to-image models, in producing specific outputs. This technique leverages in-context learning, a characteristic of LLMs, which allows models to adapt temporarily based on given prompts. Prompts can vary from simple questions to elaborate instructions incorporating context, guidelines, and sample data. For example, a few-shot learning approach might include examples like "Maison → house, chat → cat, Chien →" to guide translations from French to English. In text-to-image models, prompts describe the desired end product, such as "a high-resolution image of an astronaut on horseback."
## Setting Up
To demonstrate the process, fake information is set up in a JSON file:
```code
{
  "products": [
    {
      "id": "L001",
      "Name": "Unsecured Installment Loan",
      "Title": "Lending Solutions for Accomplishing Your Goals:",
      "Description": "An Unsecured Installment Loan from FNB1 can provide you with the borrowing power you need to meet your financial objectives. These loans are repaid over a set time frame (term) with a specific number of payments.",
      "Key Features": [
        "Borrow anywhere from USD 2500 - USD 25000",
        "One-time, lump-sum distribution of loan proceeds",
        "Fixed repayment schedule",
        "Available with a fixed rate",
        "Interest rate discount available when you set up automatic monthly payments from an FNB Deposit account",
        "Flexible repayment terms"
      ],
      "Key Benefits": [
        "Immediate spending power",
        "Flexible and convenient payment methods including by mail, in-branch, online or automatic debit from your deposit account"
      ],
      "Great For": [
        "Larger, one-time purchases",
        "Home renovations",
        "New appliances",
        "Debt consolidation"
      ]
    },
    {
      "id": "L002",
      "Name": "Secured Installment Loan",
      "Title": "Enjoy Real Flexibility:",
      "Description": "A Secured Line of Credit from FNB1 gives you the flexibility to borrow up to your credit limit at any time. Whether you use your line for overdraft protection or just as a cushion for those unexpected expenses, a line of credit provides you the borrowing power you need to help meet life's financial demands.",
      "Key Features": [
        "Secured with an FNB Savings Account or Certificate of Deposit",
        "Flexibility to borrow as needed, repay and borrow again up to your credit limits",
        "Borrow up to USD 250000",
        "Variable interest rate tied to the U.S. Prime Rates",
        "Access your funds via check or online transfer"
      ],
      "Great For": [
        "Providing overdraft protection for your checking account",
        "Covering unexpected expenses",
        "Providing liquidity to bridge the gap between when your bills are due and when you get paid"
      ]
    },
    {
      "id": "CC003",
      "Name": "SmartRate Credit Card",
      "Title": "Get More Savings with Lower Rates",
      "Description": "With the SmartRate Card, you can get more savings with our lowest interest rate. You can use your card anywhere Visa is accepted to conduct everyday purchases. For added convenience, consolidate your monthly bills on one statement for one monthly payment.",
      "Key Features": [
        "No Annual Fee (Please review rates and fees in the pricing information link below for costs associated with this credit card)",
        "Competitive Variable APR"
      ],
      "Great For": [
        "Everyday purchases, from groceries to gas to monthly bills",
        "Consolidating your monthly expenses on one convenient monthly bill",
        "Saving on interest every time you use your card to make a purchase"
      ]
    }
  ]
}
```
```code
Name: Emily
Age: 80
Channel: Email
Recommended Product: L001
Preferred Language: English
```
## Prompt Engineering Techniques
The article examines various prompt engineering techniques used to create templates for outbound communication. Instructions are provided on the channel (email or SMS), style, target customer, and target product. The general structure of the prompt is as follows:
```code
{Optional: Model specific instructions}
{Prompt}
{Output-Formating-Instructions}
{Optional: Model specific instructions}
```
### Email Template
```code
{Prompt}
Given the above details, generate 3 email parts in the specified format:
Subject: Subject of the email
HTML Body: Content of the email but formatted nicely in HTML
Text Body: Same content of the email formatted in plaintext
Format:
The returned string should be constructed as follows:
1. Start with the delimiter "###SUBJECT###" followed by the subject content, and then end with "###END###".
2. Next, start with the delimiter "###HTMLBODY###" followed by the HTML body content, and then end with "###END###". Make sure the generated HTML code has opening and ending <html> tags.
3. Finally, start with the delimiter "###TEXTBODY###" followed by the text body content, and then end with "###END###".
4. Only output the text not any instructions.
5. Output language is {lang}
```
### SMS Template
```code
{Prompt}
Given the above details, generate content for an SMS message in the specified format:
Text Body: Content of the SMS message in plaintext
Format:
1. Start with the delimiter "###TEXTBODY###" followed by the SMS message content, and then end with "###END###".
2. Only output the text not any instructions.
3. Output language is {lang}!
4. Limit the text body content to 160 characters or less.
```
The prompt approach with its format instruction points serves several purposes, such as ensuring unique delimiters to prevent incorrect splicing of content, maintaining context consistency, and specifying output language. For SMS, a character limit is imposed to avoid additional costs.
## Challenges in Promoting Responsible AI Deployment
Deploying machine learning models involves several challenges, such as:
- **Fictitious Narratives**: The model may generate fictitious narratives or assume undue familiarity with the customer.
- **Hallucinated Conversations**: The model might hallucinate entire conversations, raising data privacy concerns.
- **Social Proof**: The model may cite social proof without access to actual customer interactions.
- **Personalization**: Companies with comprehensive customer data can personalize messages more effectively.
Addressing these challenges is crucial for responsible AI deployment to enhance customer experiences without compromising trust and ethical standards.
## Prompt Iteration 1
The first iteration involves a prompt template instructing the model to write a high-converting email or SMS using marketing techniques like storytelling, social proof, and persuasive language. The inference settings are:
```code
max_tokens_to_sample = 4096
temperature = 0.5
top_p0.9
```
### Results — Iteration 1
```code
###SUBJECT###
Emily, let me tell you about our Unsecured Installment Loan
###END###
###HTMLBODY###
<html>
<head>
</head>
<body>
<p>Dear Emily,</p>
<p>My name is John Smith and I'm an advisor at First National Bank.
I wanted to tell you about our Unsecured Installment Loan which I
think could be a great option for you.</p>
<p>I know you've been looking to finance that new kitchen renovation
you told me about last week. An Unsecured Installment Loan is perfect
for bigger, one-time expenses like home renovations. Here's how it works:</p>
<ul>
<li>Borrow anywhere from USD 2500 - USD 25000 for your project</li>
<li>Get the money all at once in a lump-sum when your loan is approved</li>
<li>Repay on a fixed schedule with a set number of payments</li>
<li>Lock in a low fixed interest rate</li>
<li>Save even more when you set up automatic payments from your FNB account</li>
<li>Choose flexible terms that fit your budget - 2 to 7 years</li>
</ul>
<p>I think this loan would be ideal to get the cash you need to renovate your
kitchen just how you envisioned. Many of our customers have used it for
similar home projects and were thrilled with the results.</p>
<p>Let's schedule some time to go over the details and get you pre-approved.
I'm excited to help make your kitchen dreams a reality!</p>
<p>Sincerely,</p>
<p>John Smith</p>
</body>
</html>
###END###
###TEXTBODY###
Dear Emily,
My name is John Smith and I'm an advisor at First National Bank. I wanted to
tell you about our Unsecured Installment Loan which I think could be a great
option for you.
I know you've been looking to finance that new kitchen renovation you told
me about last week. An Unsecured Installment Loan is perfect for bigger,
one-time expenses like home renovations. Here's how it works:
- Borrow anywhere from USD 2500 - USD 25000 for your project
- Get the money all at once in a lump-sum when your loan is approved
- Repay on a fixed schedule with a set number of payments
- Lock in a low fixed interest rate
- Save even more when you set up automatic payments from your FNB account
- Choose flexible terms that fit your budget - 2 to 7 years
I think this loan would be ideal to get the cash you need to renovate your
kitchen just how you envisioned. Many of our customers have used it for
similar home projects and were thrilled with the results.
Let's schedule some time to go over the details and get you pre-approved.
I'm excited to help make your kitchen dreams a reality!
Sincerely,
John Smith
###END###
```
## Prompt Iteration 2
The second iteration addresses challenges from the first prompt and provides more information on the sender to tailor the email. Differences between the two prompts include context, tone, and approach.
### Results — Iteration 2
```code
###SUBJECT###
A loan to simplify your finances, Emily
###END###
###HTMLBODY###
<html>
<head>
<title>Loan Offer</title>
</head>
<body>
<p>Dear Emily,</p>
<p>As your trusted financial advisor at First National Bank,
I wanted to let you know about an excellent borrowing option
that may help simplify your finances - our Unsecured Installment Loan.</p>
<p>At your age, I know you may have some large upcoming expenses
for healthcare, home repairs or other needs. This loan provides
flexible borrowing up to $25,000, with fixed regular payments spread out
over a timeframe that works for your budget.</p>
<p>With our online application and fast approval process, the funds can be
deposited directly into your account within days. The fixed rate gives you
predictability, and the automated payments from your FNB account can even
save you money.</p>
<p>Please let me know if you would like to discuss this option in more
detail. I'm here to help provide solutions tailored for your financial
situation.</p>
<p>Sincerely,</p>
<p>John Smith</p>
<p>Financial Advisor</p>
<p>First National Bank</p>
</body>
</html>
###END###
###TEXTBODY###
Dear Emily,
As your trusted financial advisor at First National Bank, I wanted to let you
know about an excellent borrowing option that may help simplify your
finances - our Unsecured Installment Loan.
At your age, I know you may have some large upcoming expenses for healthcare,
home repairs or other needs. This loan provides flexible borrowing up to
$25,000, with fixed regular payments spread out over a timeframe that works
for your budget.
With our online application and fast approval process, the funds can be
deposited directly into your account within days. The fixed rate gives you
predictability, and the automated payments from your FNB account can even
save you money.
Please let me know if you would like to discuss this option in more detail.
I'm here to help provide solutions tailored for your financial situation.
Sincerely,
John Smith
Financial Advisor
First National Bank
###END###
```
## Iteration 3 — Automatic Prompt Optimization
The final version uses an LLM to improve the prompt itself, inspired by Yang et al.'s publication. The optimization loop involves an Executor LLM, an Evaluator LLM, and an Improvement LLM.
### Optimization Loop
- **Executor LLM**: Executes the initial prompt.
- **Evaluator LLM**: Evaluates the prompt based on guidelines and creates recommendations.
- **Improvement LLM**: Crafts a new prompt based on recommendations, starting a new cycle.
### Critical Components for Successful Model Operation
- **Evaluation Prompt**: Acts as a self-check for the model.
- **Inputs**: Crucial inputs are highlighted during the optimization process.
- **Log Maintenance**: A log of the best prompts and scores is maintained.
- **Prompt Cleaning**: Prompts are cleaned of stop-words before reuse.
### User Variables
```code
user_variables = {
  "first_name": "Josh",
  "last_name": "Milwakee",
  "age": 45,
  "channel": "EMAIL",
  "lang": "English",
  "product_id": "L001",  # Now this product ID represents a loan offer suitable for Josh's financial profile
  "account_status": "Active",
  "customer_since": "2005",
  "monthly_income": "3200 USD",  # Income from his job
  "monthly_expense_average": "2800 USD",  # Including rent, utilities, groceries etc.
  "savings_account_balance": "10,000 USD",  # Limited savings
  "retirement_fund_balance": "20,000 USD",  # Has started building a retirement fund
  "investment_portfolio": {
    "stocks": "5%",  # A smaller proportion invested in stocks
    "bonds": "15%",  # A safer, but still small, portion in bonds
    "mutual_funds": "10%",  # Has invested a bit in mutual funds
  },
  "credit_score": "650",  # Fair credit score
  "home_ownership": "Rent",  # Currently renting his home
  "preferred_contact_time": "Evening",
  "financial_goals": {
    "home_purchase": True,  # Aspiring to buy a home
    "children_education": True,  # Saving for children's education
  },
  "online_banking_usage": "Occasional",  # Uses online banking occasionally
  "relationship_manager": "John Smith",  # Assigned relationship manager/banking advisor
  "notes": "Interested in information on first-time home buyer programs; looking for advice on improving credit score",
}
```
### Evaluation and Improvement Prompts
#### Evaluation Prompt
```code
\n\nHuman:You are a prompt optimizer and your task is to evaluate if
the models stays within certain guardrails that we have set.
Your task is to evaluate a large language model output against
those guardrails and score them on how well they satisfy the prompt
template between the <prompt_template></prompt_template> tags.
Be very strict and rate the model output, that is marked between
the <model_output></model_output> tags on a scale from 1 - 100 and
output the score between the <score></score> tags.
Output your recommendations between <recommendation></recommendation> tags.
Output a new prompt template that incorporates your adjustments and
output those between the <new_prompt_template></new_prompt_template> tags.
Check the below model output and check if it adheres to the guardrails.
Give improvement recommendation on the prompt template.
<guardrails>
The model must stay factually correct.
The model has no knowledge about prior communication with the customer.
The banks reputation is of highest priority. We can not tolerate any
made up stories.
If the model is not staying factually correct, the score can
maximum be 25. </guardrails>
This the conversation and output of the LLM:
\n\nHuman:
<prompt_template>{template}</prompt_template>
<model_output>{content}</model_output>
Assistant:
```
#### Improvement Prompt
```code
\n\nHuman:You are a prompt optimizer and your task is to improve
large language model outputs via a technique called prompt engineering.
You are tasked to improve the prompt, by adjusting the prompt template
between the <INST></INST> tags and you are creating the prompt template,
not the email itself!
In the history, you will get information about how good the prompt is via
the score between the <score></score> tags, when the model is run on the
prompt template and stays between 0 and 100 (100 being the best score).
The history of the last prompts and scores is between the
<prompt_history></prompt_history> tags.
<prompt_history>{history}</prompt_history>
The following recommendations have been made to improve the current
prompt template:
<recommendation>{recommendation}</recommendation>
The current prompt template is:
<current_prompt><INST>{non_filled_prompt}</INST></current_prompt>
The guardrails are:
<guadrails>
- The model must stay factually correct.
- The banks reputation is of highest priority. We can not tolerate any
made up stories.
- If the model is not staying factually correct, the score can maximum be 25.
</guardrails>
Create <new_prompt_template></new_prompt_template> tags and only adjust
the prompt template between the <INST></INST> tags.
Make sure that you adhere to the guardrails. Furthermore, you only have
access to the user and product variables denoted between the
<variables></variables> tags, do not invent more variables!"""
+ f"""<variables>
<product_variables>["product_name","product_description",
"product_key_features","product_great_for"]</product_variables>
<user_variables>{list(user_variables.keys())}</user_variables>
</variables>
Assistant:
```
### Results After Three Iterations
The prompt template after three iterations emphasizes the bank's reputation and reduces hyper-personalization. The LLM-generated output text body after the third iteration is:
```code
Dear Josh,
As your trusted financial advisor at First National Bank for over 20 years,
I wanted to share an exciting new borrowing option that may assist you in
meeting your financial goals - our Unsecured Installment Loan.
This loan provides flexible borrowing power with predictable payments over
a set timeframe. With a transparent interest rate and no collateral required,
it can be a simple way to access funds for major purchases,
investments, or other needs.
At First National Bank, we take pride in offering honest
financial products to help our customers. Please let me know if you
would like to learn more about whether our Unsecured Installment Loan
is the right solution for you.
Sincerely,
John Smith
###END###
```
### Results After Ten Iterations
The prompt template after ten iterations is more elaborate, emphasizing the needs of a marketing prompt in the financial industry:
```code
<INST>You are an marketing content creator assistant for
First National Bank, a respectable financial institution
with a reputation for being trustworthy and factual.
You are assisting John Smith, a 54 year old bank advisor
who has worked at First National Bank for 20 years.
First National Bank is developing a new {product_name} designed for
customers like {first_name} {last_name}, who is {age} years old.
As a bank, it is critical that we remain factual in our marketing
and do not make up any false claims. \n\nPlease write a {channel}
marketing message to promote our new {product_name} to {first_name}.
The goal is to highlight the key features and benefits of {product_name}
in a way that resonates with customers like {first_name}.
When writing this {channel} message, please adhere to the
following guidelines:
- Only use factual information provided in the product description.
Do not make up any additional features or benefits.
The product description is: {product_description}
- Emphasize how {product_name} can help meet the typical financial
needs of customers like {first_name}, based on their age demographic.
- Use a warm, helpful tone that builds trust and
demonstrates how First National Bank can assist customers like {first_name}.
- If unable to compose a factual {channel} message for
{first_name}, indicate that more information is needed.
As a respectable bank, First National Bank's reputation relies
on marketing content that is honest, accurate and trustworthy.
Please ensure the {channel} message aligns with our brand identity.
Let me know if you need any clarification or have concerns about
staying factually correct.\n</INST>
```
```code
Dear Josh Milwakee,
I am reaching out to provide initial information about
First National Bank's Unsecured Installment Loan.
Please note that full terms, conditions, eligibility criteria,
and approval processes apply. More details from you are needed to
fully evaluate if this product meets your needs.
The Unsecured Installment Loan allows you to borrow anywhere from
$2,500 to $25,000 as a one-time, lump-sum distribution of loan proceeds.
It has a fixed repayment schedule and is available with a fixed interest rate.
You may qualify for an interest rate discount when you set up automatic
monthly payments from a First National Bank deposit account.
Repayment terms are flexible.
Please let me know your specific goals so I can better assess
if this product is suitable. I look forward to hearing from you.
Regards
John Smith
```
## Conclusion
The article demonstrates the practical application of prompt engineering through a hypothetical bank marketing scenario. It highlights the capabilities of LLMs to assess and refine their own prompt templates, ensuring enhanced customization in email communications. The journey of exploration and optimization continues, with potential for further advancements in user-friendly interfaces, broader customer base testing, and integration with AWS Communications Developer Services for a complete marketing pipeline. The endeavor serves as a stepping stone towards harnessing the full potential of prompt engineering for personalized user experiences.
#### Links:
  - [Large Language Models as Optimizers - arxiv.org](https://arxiv.org/abs/2309.03409)
  - [Large Language Models as Optimizers - arxiv.org](https://arxiv.org/pdf/2309.03409.pdf)
  - [GitHub+github.com philikai FromPromptEngineeringTo](https://github.com/philikai/FromPromptEngineeringToAutoPromptOptimisation)