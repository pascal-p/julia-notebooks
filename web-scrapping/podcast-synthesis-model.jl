### A Pluto.jl notebook ###
# v0.19.46

using Markdown
using InteractiveUtils

# ╔═╡ bf0e8d60-d704-4c66-ad3f-d372cb2963a2
begin
  using PlutoUI
  using OpenAI
  using JSON3
  using BytePairEncoding
  using Weave

  PlutoUI.TableOfContents(indent=true, depth=4, aside=true)
end

# ╔═╡ 59d0b923-435a-4dc8-902f-02a9b5a177db
include("./support/for_podcast_synthesis.jl")

# ╔═╡ c94c972e-a75f-11ee-153c-771e07689f95
md"""
## Podcast - Transcript synthesis + QnA

1. Podcast (raw) transcript
1. System prompt for synthesis (instruction + raw transcript)
    - generate a TOC, or use existing TOC for synthesis
1. Generate synthesis - part by part interactively
    - accept the synthesis and move to the next part
    - apparte on some question, then back to synthesis
1. Update mardown synthesis
1. Final full markdown synthesis - generate a pdf
1. Extra: re-generate the transcript without the mistakes inherent to the transcript generation
1. Extra: using both synthesis and re-generated question ask questions
"""

# ╔═╡ 0200cef1-6862-4704-b6e7-30f1ac54a1ed
usage_shared_state = usage_shared_state_maker()

# ╔═╡ 7df1d566-a7a8-4a9d-a477-2e2fea683e27
const LLM_PARAMS = Dict{Symbol, Union{String, Real, LLM_Model, Function, Dict, Nothing}}(
	:max_tokens => 8192,
	:model => DMODELS["gpt-4o-2024-08-06"],
	:temperature => 0.5,
	:seed => 117,
	:response_format => nothing,  # Dict("type" => "json_object"),
	:calc_cost => calc_usage_maker(usage_shared_state)
)

# ╔═╡ 0c5d69c3-8d38-4366-9e2e-23e7475744ac
PODCAST_TITLE, PODCAST_URL = """LLM Chronicles 6.5 - Build LLM Agents from Scratch PAL, ReAct & Langchain in 1 Hour""", """https://www.youtube.com/watch?v=FRnwbww4MtE&t=358s"""

# ╔═╡ f1cf76d4-d894-4c80-a4bd-0eb6f37df38d
PODCAST_TOC = map(x -> string(x),  
	split("""
Overview [00:00:54]
Setup (Imports and API Keys) [00:02:37]
PAL from Scratch [00:04:02]
LLM Chains with LangChain Expression Language [00:10:12]
Switching to Llama 3.1 (TogetherAI) and Mixtral 8x7B (Groq) [00:16:58]
ReAct Agents [00:22:02]
Implementing ReAct Operational Loop  [00:36:49]
Other ReAct Formats (JSON, XML, ...) [00:46:15]
LangChain ReAct Agent [00:51:10]
OpenAI Function/Tool Calling via API [00:57:09]
Chat ReAct Agent for Conversations [01:03:00]
""", "\n")
)

# ╔═╡ d2dfeb72-86c6-4535-8d98-e3293beb7c7a
PODCAST_CONTEXT = """In this video, Donato Capitella (podcat host) guides us through building LLM agents from scratch, starting with paradigms like PAL (Program-Aided Language models) and ReAct (Reason + Act) to enhance reasoning and agent behavior. First, we will learn how to implement these manually. Then, Donato show us how to achieve the same using the Langchain framework, including LangChain Expression Language (LCEL).

After that, he will walk us through how to switch between different language models like GPT-4, Llama 3.1, and Mixtral on platforms like TogetherAI and Groq, giving us flexibility in agent design. Finally, he will demonstrate how to use OpenAI’s function calling as an alternative to a direct ReAct prompt, adding another layer of functionality to agents.
""";

# ╔═╡ 2f4ae40f-a1ab-470b-a1b7-a04fec353b0e
PODCAST_RAW_TRANSCRIPT = """
# Intro
in this lab we are going to apply what we learned in the last episode of llm Chronicles dedicated to llm agents so we're going to see how to implement pal and react in practice and I already know this is going to be an extremely long episode it might be more than 1 hour long and I might need to split it into two different episodes but what you are going to learn here is how to actually build these agents and llm chains from scratch you're going to learn how to play with the different prompt templates how to extract actions how to execute them and this episode is for you if you really want to understand uh what

# Overview [00:00:54]
happens under the hood and if we look at the list of uh topics from here I've actually put all of the timestamps because I know that some of you will just want to jump ahead to the section that's most interesting but what we are going to do first of all we're going to start by implementing pal uh from scratch first and then we're going to use l chain to implement llm uh chains and we're going to do this with GPT 40 min but then we are also going to see how to do these with Lama 3 and mixl so it's going to give you an idea of how you take the same concept uh and you can swap different models open source closed Source uh and try to play with the prompt templates so that uh you get uh similar outputs after we do that then we learn how to build llm chains with L chain uh we're going to dive into the most most important part of this episode which is building a react agent completely from scratch first and then we'll see how uh we can do that with L chain and towards the end of this we'll also cover open AI uh function calling uh and the react conversational agents so this is when you want to take some of these agents that we're building but um add them to a proper chat interface or a chat interaction with the user so again

# Setup (Imports and API Keys) [00:02:37]
without any further Ado let's get started so we are going to get started with the standard Imports we will be using first of all just the open AI uh SDK and then we'll do the same things using L chain so we need to install these packages I've already uh done it and then we are doing some basic Imports and as usual when you work with a lot of these libraries and sdks you want to set the specific environment variables that contain uh the API keys and for this notebook I'm actually using the uh Secrets functionality so when you get this notebook you go into the secrets and Set uh the variables or if you want uh you can copy and paste the keys there but this is obviously not recommended so once I've got that uh I'm just going to instantiate an open AI client and I'm going to create a utility function to call GPT 40 mini with a uh prompt so that's just a um obviously a chat model so that's the typical template roll user content prompt and now I'm just testing that I can actually run um that particular function which I can so I get a completion from gbt 40 mini so now that I've got this we are ready to implement pal from scratch pal

# Setup (Imports and API Keys)
pal is uh stands for program aided language models and the idea is that you can give a problem to the language model and instead of the model answering the problem by itself it produces a python script which then you go and wrun on behalf of the model to actually get the answer now why would you do this because models are not very good at counting but they are good at producing reasonable programs for example in Python so the idea is that this would improve the ability of the model to solve certain types of problems uh specifically problems that have to do with mats and indeed if you go and look at the results in the paper on different benchmarks uh there you've got it here uh for example if you compare the solve rate of a model which is prompted uh or which is using Pal versus something that's just using Chain of Thought or a simple direct prompt uh you will see that the solve rate of these mathematical uh questions are much higher for example on a GSM uh 8K which is just this great School mat problems the model has a 72 or the method gives a 72% uh solve rate which is obviously much higher uh than not using pal let's go now and implement this from scratch it's actually fairly simple first of all we start with the prompt you can play with it you can write it yourself and change this but here I'm simply telling it that it is a helpful assistant that's solves math problems using python programs and then essentially I provided an in context one shot uh example of how I want it to perform so given a problem I want it to give me a python code block with the solution and I specifically tell it this is important that after I run the code I want the result the solution to be in a variable called result so that we can go and and fetch it so after the in context learning example then in my prompt template I have the placeholder for the variable which I'm calling problem and now if I actually go and run this I have just a sample problem which I think I've taken from the paper we are not going to read the problem I don't think it's uh very interesting per se uh but I have my problem in a variable and I can obviously replace it in the prompt template and I get the uh full prompt that I can then send to the llm now the line will process this and as you can see it Returns the python uh block as we uh described with a few comments uh and then the actual code so the idea would be now to take this and execute it so let's go and do that I have a helper function uh that takes this response and essentially finds the uh python uh code block and extracts uh the actual code between the um code blocks so that's the first one and then this one over here uh simply executes uh that function using a python interpreter now I should say as a cyber security guy myself uh you need to be very careful when you do this this is an example but taking just some random code uh which an LM has produced and executing it could be very dangerous you would need to do this within a fully isolated sunbox so this goes without saying but again here we just have an example so we've defined uh these functions here so now we can take that generated code execut it with the python interpreter and we get the answer 11 which um I happen to know is the uh correct answer for the problem I provided it so that's essentially what pal is obviously if you want to make this more useful you would wrap it into a full llm chain let's do this manually so to understand how all these building blocks could be made usable essentially what we want is a single function to which we can pass a problem in natural language and then the function returns as an answer so does all those steps uh chained together that's actually incredibly simple so that problem we take the problem we substitute that in The Prompt uh template we pass it to our language model which generates the code and then we execute that code so we then extract the answer which should be this in this particular case and then we return a string uh such as the answer is whatever so let me Define uh that chain and now I can have a second problem and simply pass it to the chain and the answer is 74 so you can see how simple it was to actually build a working pile uh example so now what we've done manually I want to show you how to do with lung chain

# LLM Chains with LangChain Expression Language [00:10:12]
uh and essentially lung chain as the name says is a framework which at the core allows you to build this llm chains in a very versatile way so to me an llm chain very simply uh is a set of steps uh that are chained together of course so you take the output of one step and you feed it to the next step now a common chain typically starts with a prompt template which defines a set of variables then the variables are filled in and passed into an llm which provides an answer and then we do something to that particular answer we will parse it out for example we'll take a string out of it or we'll parse it as Json XML uh and in our case for pal for example we could even go and execute it so longchain makes it really easy to build These Chains uh they have a lot of uh interfaces and helper functions uh make this trivial and they have something called L chain expression language uh that again will make it very intuitive to just string together all of these steps in a chain so the way we can recreate that P chain that we did manually with a l chain is by first of all uh importing chat open AI um which is the import implementation the lung chain the rupper the lung chain provides around um open AI own SDK and interface uh now the advantage here and one of the advantages of Frameworks like long chain is that all of these things are obstructed with a higher level apis so as I'll show you in a second if you want to change from open AI to Cloe or to literally anything else like you want to load a model from grock and stuff like that it's very easy you simply just have to import a new package and just switch one line of code so that's the L chain open AI uh chart model and actually I think I've got it open uh if you want to take a look but again for me the most important takeaway is that L chain will put in the latest version all of these different providers um models implementation or API uh implementations inside uh different packages so as you see uh this is now in a package callede longchain open and if we take a look at that you will see and that's my important point is that ultimately this chat open AI object extends base chart model which is in the longchain core and all of the other providers chat models will ultimately extend uh this particular class which means that they all become interchangeable so that's the uh chat model and that's how you would uh implement it so we give it the model name the temperature we can pass other parameters as we're going to see later and as usual you need to have the uh API key defined as an environment variable uh obviously we've already uh done this then we are going to create a prompt template which comes from the prompt uh package in the core uh lung chain um library and this is very trivial uh you simply Define the template and the same template string that we used before that works perfectly fine and then you define the variables that you've got in your template explicitly so here I'm basically saying uh these are my uh input variables now we've got all the basic building blocks and using the lung chain expression language I can create a chain so I can start with my prompt which llm I want to use and what I want to do with the output in this case we're just going to pass it as a string so I Implement that and then I can take the chain I can call invoke and I can pass an object with all the input variables and these are going to be filled in uh for me and all the chain is going to be run and in fact if we do this you can see that the output again is the uh python code that GPT uh 4 or mini as uh generated now obviously we don't want to stop here this is not our full chain our full chain needs an additional step here at the end to actually uh go and execute the code and adding a step to a l chain chain is incredibly simple each step in the chain essentially extends this core um class called a runnable and that's the interface uh so I'm calling this execute Python and one key part that we're going to implement is the um invoke method which obviously takes the input into the chain and returns uh whatever is the output of that which can then be shown to the user or passed to the next chain step so in our case this uh execute python runnable is just going to be a wrapper around the execute python code that we had before so if now I Define this and I extend my pile Chain by adding this as the final step and then I invoke it with the problem this time we should see the full output so that's how simple it is to implement a custom uh chain with the uh most recent version of lung chain using the lung chain expression

# Switching to Llama 3.1 (TogetherAI) and Mixtral 8x7B (Groq) [00:16:58]
now I very quickly want to show you how easy it would be to swap this llm gb4 or mini for any other llm and I've checked this in the um in the appendix uh so you are going to need to install um additional packages which obviously implement the apis or the API calls for the uh additional Aline platforms here I'm going to show you how to use the together AI uh platform and the gro platform if you're not familiar with these um they are essentially platforms which uh offer API calls to access many open-source languages for example uh if we go to together uh you see all of these models here including meta Lama 3.1 8B 70 B 405b and so on but you see also the uh other open- source models Mistral Mixr wizard LM uh Gemma from Google so you get the idea so they Implement a lot of these and it's very useful uh so let's say I wanted to use these models as usual you are going to need to set an environment variable uh to hold the API Keys then from that lung chain package you would import the chart together which if you go into the implementation it will ultimately implement the base chart model and so if you implement these and you pass the name of the model that uh you want to use in the configuration then you can create a chain and you see the only thing different in this chain these are all the same prompts the same output pares the same execute python the only thing I changed is that I swapped the GPT 40 or the chart open AI uh implementation with this um client here and it worked just fine and indeed I got the answer so you see how powerful this is and now again I can do the same with Gro so that's the gro uh API key and again grock is another one uh of this cloud uh Services which will Implement uh or make available a lot of the opsource uh models you can see the ones which are um available at least in my account and just for demonstration purposes I'm going to use Mixr um 8 7B and obviously together also has that model so this doesn't make a lot of sense but I just want to show you how to use um Gro so I import chat Gro I instantiate it point to the mix model and I create my Chain by swapping in the um llm and it works as well I should also say that most modern llms uh work really well with things like pal and react that uh we're going to see in a second the final thing I wanted to say on uh pal is that here we've basically still created this by hand butan chain as a full pile chain with the prompt templates and the python executor already implemented for you so you could use it um and I think it comes from the um sorry let me just find it uh there it is and it comes from this longchain experimental uh package so you could simply import the pile chain that they've already implemented for you uh and pass it the problem and it will basically do something very similar to what our chain does the only problem is that at the time I'm recording this video oh the this generates an error so I think uh that they have a bug essentially in their implementation where uh it's not uh passsing out correctly the solution given by the llm when I look at this the llm is giving the correct solution in the right format but probably the chain that they implemented at some point got broken but this is perhaps another reason why you really want to be able to do these things from scratch and to understand everything that's uh going on very often uh you'll find that it's much better to reimplement your own chains and tweak them uh rather than using the pre-built chains so we're now ready to tackle react

# ReAct Agents [00:22:02]
react comes from this original paper from Google in 2023 called synergizing reasoning and acting in large language models and you will remember from uh the episode that the basic idea is to create agents that can think about their next action and then they're given a set of tools and they can say uh in order to solve this problem I need you to execute this function this tool for me and then give me the answer so they work in this Loop of thought they are prompted to think about the next step call they call an action or a function or a tool whatever you want we go and execute the tool with the argument that the react or the the LM gives us take the output of that tool and then pass it back to the LM as an observation and then the llm continues its thought action Loop until it finds the uh final answer so really again this idea of taking the Chain of Thought reasoning and mixing it with access to tools which allow the agent typically to interact with the external world now what we are going to do we're going to create a basic uh react agent and as usual we start from the uh prompt now I shall say that there are a million different ways and different details that you could uh use to write uh one such prompt a lot of different variations and you should definitely play uh with it there is not one react prompt or one react format and especially if you use modern llms that are very good at in context learning uh you'll find that you can really play with the structure of these and they'll typically do uh fairly well so for this particular one I tell it that it is a trivia expert and then I say that it run I I tell it that he runs in this thought action observation loops and what each of the steps are and then I tell it which tools it's got available so I'm going to give it a web search tool that takes a query uh a calculate tool that basically computes a mathematical expression and then this is quite important I'm going to give it a final answer tool so this is what the agent is going to use to signal that it's complet all of its uh reasoning and it's got the answer so I will take the answer which is inputed here and then show it back to the to the user and as usual here I uh give it an example of how this operational Loop Works leveraging in context learning so I'm going to provide it a question and then the llm will output a thought I need to search Wikipedia to find the information about the topic in this case we're asking how tall the a tower is and then it needs to produce an action in this particular format in this case searching the web for AEL Tower and then it's going to receive the answer back as an observation so this is going to be the content of that web search and then the LM should look at that and think oh I need to calculate 300 + 24 uh I mean this is because I asked in this example a more complex question telling it I want to know the height of the tower including the antenna on top and just to show it how it should think the answer it gets from the web search is not exactly that but it's got the size or the height of the antenna and the height of the Tower so now the LM think so I need to calculate 300 + 24 to give the answer and then it produces an action 300 + 24 uh and then the observation is this so now it should think I've got the final answer and it calls The Final Answer tool with the string which is the response that we want to show to the user now obviously this is a little bit of a contrived example to be honest if you ask any modern llm uh this question uh it's likely to just know the answer by itself uh and most llms don't need to search the internet for this and even to do something something like 300 plus 24 uh llms are not great at math but that kind of computation they should be able to do but it doesn't matter because here we're trying to kind of get an idea and tell the llm how we want it to operate so this is the um template within context learning and then obviously we've got uh the actual uh placeholders for the question that the LM actually needs to answer and then very importantly we have an action Trace uh because we are going to build these trays as we call D llm inside that Loop so that it can look back at the actions and the thoughts and the outputs from those actions deciding when it tries to decide what the next action is so that's the uh prompt implemented and now I'm going wrap this into a basic react uh or trivia agent chain so I'm going to take the prompt GPT uh and then just passing it as a string and I'm going to invoke it with a question uh what was gelan when was gelan founded if you're not familiar with it it's an Italian amusement park but now this is key what's happened here I asked a question which was put in here and the llm produced a thought I need to search Wikipedia produce the action invocation in the correct format and then look at this it also hallucinated the observation galand is an amusement park located in Italy and it was funded in 1975 now obviously we don't want this to happen we need to go and do the web search and provide the answer we don't want the llm to hallucinate the answer and obviously it kept going uh thinking now I have the final answer and calling the final answer so the whole point of react is that we're not going to allow the llm to hallucinate the observation we're going to stop it here execute the function on behalf of the llm and feed the observation into the cont context so a very very easy way of doing this in the way that we are structuring this particular instance of react is that we are going to stop the llm as soon as we detect observation column so as soon as we see that it's starting to hallucinate an observation we stop it there this is really easy uh to do because we can pass uh a stop string or a stop pattern and so whenever this llm is now called L chain is going to stop it uh when it starts generating the observation so that's the same chain as before I just changed this llm and you can see now that if we look at this it produces the thought it produces the action and it's now obviously stopped there so this stop condition prevents the llm from hallucinating the observation and allows us to then look at this output extract the action go and execute it now something important here is that you need to think about what that stop action or sorry stop condition needs to be and that really depends on the prompt structure that you've given to the llm and how D llm is handling it um so giving you a few other ideas you could for example be more explicit with the llm so in your in context learning example you could actually ask the llm to produce the word pause or any other keyword uh that you want immediately after it produces an action so you could give it this particular example here in the in the com context and now if you do something like this then you can take whatever keyword that is and use it as a uh stop action here that would work equally well and obviously you need to experiment uh with the llm to see what works best but again as I said typically most llms today uh will do well whatever uh way you prompt them okay so now now we have to extract the action from the uh output of the llm here I have a simple regular expression that's going to match the action name and the action input so if we run this and then we call it on that output we now see that it returns action name web search and the um action input Galan founding date which again was this particular uh line the dlm produced and um and again here this parsing here obviously depends on the format uh you've given to the uh to the llm uh and as I said there is no right or wrong way to make a react agent it just depends on the llm you're working with and now uh easy easily it can work with different formats but just to give you an idea idea if the llm produced an action like this in the current format that we're giving it final action the AFL Tower is 324 M tall and then it opens a parenthesis to say how much it is in feet I don't know why it would do that but let's say it does that this parsing function is going to break because it's going to see this uh and in interpret it as the end of this final action so it's going to cut some of the output of the llm so basically what I'm saying here is that this example um that I'm giving you in this particular format uh in reality you would need to work with it to make sure that the llm knows what kind of characters uh it can produce and very often as we'll see we'll see later the llm is actually prompted to use Json instead of something uh like a function call like this especially with strings it can be again particularly complicated uh to pass out another idea that you will see for function call is to actually tell the L to split the action and the action input into two different um rows or lines so in your in context learning uh examples you could actually tell the llm to call an action like this a

# Implementing ReAct Operational Loop  [00:36:49]
anyway we now have the tools to find and what we need to do is to write all of the scaffolding around this to connect the action call the DM is making with the actual uh tool and return the output as an observation and this would be the react agent Loop so and I typically call it an agent executor it used to be called an agent executor in L chain uh often uh people also call it kind of like an Norr which is a general way so calling the llm parsing the output uh calling the LM in a loop and so on so how does it work we Implement a loop and we have a max number of iterations that's actually quite important you never want to have these Loops G forever the l l can actually get stuck and if it does you need a way to stop the loop and return an error so this is what these Max iterations is doing so then we take that agent and we invoke it with the question that's been uh provided and this is going to return that thought and action step and again it's going to stop when the llm starts hallucinating the observation so then we're going to take these and we're going to use the EXT ract action function to get the action name and action input and then we're going to check if the action doesn't exist obviously we um kind of like return an error we say no action detected and we continue the loop and it's quite important what's happening here so we obviously want the L to see the output of all the tools so we have this Trace variable which is part The Prompt template which is going to be obviously empty at the beginning but every time the L produces a step thought and action and we then produce an output of that action we are going to add that to the trace so that at the next iteration that Trace can be fed to the llm so just to show you again where this is in our prompt that's where it is and again that's going to start build building thought action observation prompt the LM again it now sees that it's already called some objects and it some actions and you can see the output and then you can think what to do next again that Trace there is the key to actually implementing and making uh this work so now if the action does exist I call the specific tool with the action input and collect the output as an observation and add that output to the um to the trays um here and again step and Trace as an observation and then I go into this Loop until you see the break here until the LM produces final answer which then I uh take and return so let's run these and ask a uh question now we can see that the result of 500 + 233 minus 10 is 723 so this is just the answer but obviously uh we would like to see all the trays so I have another implementation of this react agent executor but I've just added a debug tray at the end where I am collecting all of these thought action and observation so we can see what the llm actually did so let me implement this and now we give it a the same problem uh and this time we can see the debug trays and specifically uh where is it uh all right so that's the question we asked obviously this is the in context learning and that's the thought the llm head the action it called This is the output we gave from our tool and that's the LM thinking all right I have the answer and then it calls final answer with that string now again I don't want to spend too much time here but this is the prompt that we gave to the last iteration of the uh llm so here we're we are already breaking the loop and obviously these action trays here this is the the first time we called the llm it stopped here we went and execute the action we added thought action and observation to that Trace variable as we as we do here we called it again and so obviously then the llm had this prompt this entire prompt the second time it was called produce this thought and action and because it's the final answer uh we didn't call the llm again we just broke printed this and gave the final answer now let's try a different problem such as convert \$500 uh into Euro and this should potentially give us a um more complex uh chain so if first thinks that he needs to find the current exchange rate so it calls web search and we give this observation from web search if you remember this is the mock response that we hardcoded that's why we hardcoded uh that particular one uh and now it produces this this thought uh and it produces the uh correct calculation and then we give the answer now the llm has the answer and it's um responding so as you can see uh that's how a react Loop works I want to show you again as we did before now that you could take the exact same prompt and loop and just swap in the uh chain for example Lama 3 instead of uh opening up GPT 4 or GT4 mini I don't remember what I use for that one so here we're going to use Lama 3.1 170b from together Ai and again stop condition uh building the chain exactly the same chain uh and then we can call this and you'll see that ultimately um some of these might be slightly different but you see it's basically producing very similar thoughts calling the objects or the the tools and giving the final answer which is uh still correct uh and here you see how you could do the same uh with mixol again this is exactly the same function the only thing I'm changing is the um the IND the chain we are swapping uh the llm uh but as you can see here um Mixr should be able uh to do that and use the tools uh correctly and give um oh actually in this particular case as you can see um mixol got confused and for some reason it's escaping uh the underscore when it calls final answer so now we're feeding this error in um and so now it gets stuck in a loop and ultimately uh after five iterations it stops so here um let me try to to call it again I'm not sure why it's doing that but let's try again see if um so okay it it doesn't like it um what you would need to do here and I'll leave it uh as a uh exercise is to play with the template and the format of action and vocation and how you pass the arguments and the action names to see uh if you can fix it this would be particularly useful uh to actually learn how uh this

# Other ReAct Formats (JSON, XML, ...) [00:46:15]
works so as we said before the format of that react prompt uh can be whatever and typically uh today you you would do a Json format for actions and observations that's very popular especially with openi models which handle Json uh pretty well because of their uh fine tuning and and training so the llm could be told to Output an action as a uh Json string and then we would convert that output into Json and actually handle it uh much better uh there is in long chain already an implementation of these which we're going to see uh maybe later but then some other models for example inter turn LM they are actually fine tuned already as part of their training uh with specific tokens for describing the tools the plugins and invoking actions by the way as we said in the other episodes uh tools actions uh plugins all these kind of things um are fairly interchangeable but just for internal M if you were using that uh it would actually produce action start token giving the plugin that needs to be called uh and then passing uh the um methods or the the arguments the name of the tool and the thing is you don't need in context learning because it already knows to do do this if you prompt it to call to call actions what I wanted to show you is that for example uh you could do the same react prompt using XML some models like clae are actually uh very good historically with XML and if you go for example on AWS uh Bedrock which uses anthropics Cloe models the agent or agentic framework in uh AWS Bedrock is actually an XML based agent so let's look at how you would do this so it's the same prompt as before but here I'm telling it to use these XML tags to describe thoughts tools tool inputs and how it's going to receive the observations so now if I run this obviously I need to change my stop action to here uh I create a chain with these again I have underscore XML all of these so that you don't get confused but again if I now invoke this um it gets it it works as expected uh this is because now a a lot of models uh can handle XML as well as uh Json uh but then this is just the basic chain obviously I will need to change my extract action because now my action is a tool invocation and Tool input between these uh tags so I can Implement these and then I can basically take that original agent executor and do an XML version uh where I simply pass the again XML versions of my tools but the loop stays pretty much the same again just when I inject an observation I will inject it as a tag and if I run this I can ask the same things as before and the um llm uh functions properly but you can see you can see the uh XML syntax and again even these other question convert \$500 uh to euros um the answer is correct based on the exchange rate that we gave it I don't even know if it's a reasonable exchange rate but you can see all of the chain of sort tool tool input and so on and again the reason why I'm showing you these is to give you the building blocks to actually create your own agents with your own formats uh fixing broken stuff uh and being able to use all different types of llms uh and find exactly the prompts and the formats that work with those now to close on react

# LangChain ReAct Agent [00:51:10]
I also obviously wanted to show you the longchain implementation of the uh react framework um so let's open the official documentation for uh L chain and obviously they have a react agent um let's just go in and take a look at this implementation now you will see that here we have a um new package called tools so obviously L chain needs to implement obstructions around the different concepts as we before and the idea of a tool that the llm can use is obstructed um with these uh classes here like basic tool tool structured output or input tool and so on and then from Agents we have the agent executor and the create react agent uh function uh and so let's look at this the first thing we're going to do again we're going to create the tools and the way to create uh toolss is to basically decorate them uh with this tool um attribute and it's really important that you pass the doc string explaining what the tool does because then L chain is going to take this and use it to create the prompt and to tell uh you you see here obviously we hardcoded this in the prompt but with L chain it's going to go through the tools that you pass it's going to extract the name and the dock string and it's going to build something like this so that the llm knows which tools are available um and then we put these tools in an array the other thing that we're going to do from The Hub of prompt we're going to take the react prompt that L chain uses and we can even uh take a look at that react prompt um but let me see if I can maybe print it in a little bit prettier format okay so answer the following questions as fast as you can you have access to the following tools and again this is going to be filled in with these tools uh then question thought action action input so you can see how that the basic L chain react prompt is using that format observation final thought begin I mean to be honest this is a much more concise prompt than the one uh I gave and then we can just uh create the react agent with the llm the tools and this prompt uh over here and wrap it into an agent uh executor which is ultimately going to um Implement Loop uh extract the tools calls run the tools and so on so if I create this and then we run it with the problem that we had before um you will see uh action so thought to convert currencies uh you should always search the web for the current exchange rate action web search tool input this particular one and the format is bit weird here but this is the output from our uh tool then the thought is now I have uh the exchange rate I can use the calculate tool um and so on so this works fine and so that's like the basic long chain implementation for react um you can see here uh all the other agents that it implements so you also have an XML agent um I'm not going to show you that but you can see here uh works very similarly there is going to be a uh prompt and obviously the example shows how to use these with entropic as I said um historically entropic models are better uh at uh XML this is not true if you are using a model like GPT 4 it can do XML uh fine uh but then again it creates an XML agent and then we wrap it into an Executor um just for fun maybe we can take a look at that prompt um let me just run it here um and take a look at the prompt uh and obviously we just want to look at the template so I've had to change uh that print to this because this is a conversational agent so it's made of different obviously messages and the prompt template you need to extract it uh like like that uh but you can see tool invocation tool input observation so very similar uh to what

# OpenAI Function/Tool Calling via API [00:57:09]
we did now I want to show you an another way that we can Implement agents what we've done so far with react involves creating a react prompt which shows the llm which tools are available and asks it to select a tool directly now another way that you could create agents is by leveraging function calling in certain llm apis so you've got providers like open AI which essentially in their llm uh completion API will allow you to Define together with a prompt which could be like a generic question or task a set of functions and then the API so open AI in the back end will select the appropriate function uh to call and we and the parameters and we return that to you so that you can go and call the function yourself now again the difference here is that you wouldn't be using react yourself you wouldn't be passing a react prompt you just pass a question or a task and a list of functions and you offload all of that logic of tool selection uh to the actual API so when it comes to open AI uh this is quite simple to do with the SDK so uh I'm not using long chain here we're just literally using open Ai and the way we do that we simply pass a list of tools uh with this uh particular format so obviously we need uh the tool name and the uh Properties or parameters that need to be um passed to the function so we create that and then we can create a chat message uh these are typically in chat completion offered as part of the chat completion and point API so this would just be the individual task and then when we uh call the API we just pass the uh of tools and we can also um tell the API whether we are actually requiring a tool to be called or if we are allowing the LM to choose whether it wants to just do a normal response or if it wants to call a tool if I run this and we print the completion uh you will see that in that chart completion because we required it to call a tool uh I think if we go down uh we'll find a uh tool calls uh kind of list and as part of that we will find obviously that it wants us to call the function calculate tool with the expression 5 + 10 because obviously uh that would be the most logical thing uh to do if you have a calculate tool and you are asked to do a mathematical operation now obviously what you would need to do here you would need to take this completion and extract the function call here I have a simple method to do that so if I run this then we can see tool name calculate tool tool arguments obviously uh this one here so then you could wrap all of these up into an agent executor very similar to to uh the one we we did before so you would have a loop similar to this obviously you'd call the llm with the question you would extract the action you'd go execute the action and then keep going again the major difference here or I would say the only difference is that your prompt will not include the uh full react prompt it will just include include the questions and in the back end uh open AI is going to run whatever custom models uh they have optimized based on your prompt and the tool list to select this specific tool and obviously um all of this can be implemented or is implemented with L chain if we open this up we can see uh the L chain documentation these days is actually pretty good and you can typically copy paste and that's what I did so you'll see that you can Implement a full agent with this you are going to pull the specific open AI tools agent prompt but again you could change it if you wanted and you have this create open AI tools agent that you import from the agent package and then you wrap it up into an agent executor so let me create these and then we can invoke it with our usual sample task and this should work very similar to the react agent before invoking the search Tool uh and then invoking the calculate tool and giving the final answer so this becomes very very easy to use and finally to close this very long

# Chat ReAct Agent for Conversations [01:03:00]
episode I wanted to talk about chat agents so what we did so far the react agents we looked at um are agents to which you give a single task or question a set of tools and then the agent executor goes in the background around and iteratively tries to answer that question or perform that task by calling uh the necessary necessary tools until it's got a final answer so that's not a interaction that you are having with the user there is one question and one output uh from the agent now there are many cases where you want an agent to also be able to converse and interact with the user so you could have a customer assistant agent that the user can talk to ask questions and that agent can decide whether to use tools and start a react Loop or whether to keep asking uh information or interacting with the user so this is not particularly complex but you just need to expand your general uh react agent an agent executor so that it's got that way to decide whether it wants to start a react Loop or it wants to talk to the user and you also need to provide it in the prompts a history of the conversation with the user not just the tools that it's used now L chain uh has a chat react agent which uh again enables these Dynamic conversations and essentially adds the uh chat history to the context so uh this leaves um in the um typical L chain core uh package so we can pull the react chat prompt and we can even take a look at it to see what this template is like uh and as you can see there is a space for the different tools and how I should use the tool in react fashion but there is also the concept of talking with a human so you have the conversation history and the agent uh scratch Pad so the agent scratch Pad would be the Trad that we had in our uh prompt here so this would be the tray this you can call it whatever whatever you want but now obviously with this template and an agent exec utor which is aware of this um type of agent you can actually have a chart conversation so if we uh for example invoke this agent with this input and we add to the chat history human hi my name is Bob and then the AI response so this would be the uh chat history then based on the input and the chart history the agent can decide whether to start the react Loop or to talk to the user in this case obviously it will just go into the react Loop but I think I have another example here where the same agent I'm asking what's your name so in this particular case um it will say thought do I need to use a tool no so now it can go and give a final answer which is return to the user so hopefully this is making sense but again the idea is that uh when you have a response that you need to communicate to the human you tell the agent do not use a tool you have a response you can communicate to the human and you provided the current chat history now that chat history here I cheat and I just provided a string but if you're using longchain uh you want to build your chat history for consistency using uh the wrapper objects for human message system message AI message but ultimately all of these uh when you pass them to the agent they get transformed into a string everything going into the llm is ultimately a string unless you have obviously a multimodel uh llm um and then what you would do so if you were actually implementing a CH a chat agent so you do what's your name chat history you get the answer and then you would add that answer the the question the human send in the output of the llm to the chat history so then you could continue the conversation so when there is the next question from the user you are now passing this chat history plus the question and in this case again uh this should know to use the react Loop because obviously to answer that it needs to use the tools now in the um next video we are going to take all of these building blocks and we'll Build Together a few real world web applications which Implement different types of Agents I haven't decided yet but I think I am going to probably implement a customer service agent uh which can interact with the user access the user account and you know get a list of the orders and uh be able to perform some basic actions uh on behalf of the user and we might even do an agent um that for example is able to uh be a gym coach and make a workout plan uh for the user so if you like this type of content and you actually want to learn how to build uh a proper agent uh from scratch like a full web application subscribe to the channel because again in the next few weeks hopefully uh I'm going to be able to show you how to do this
""";

# ╔═╡ ffcb61c2-9180-439e-b46b-733c3a5f5a38
podcast = Podcast(
	PODCAST_TITLE,
	PODCAST_URL,
	PODCAST_CONTEXT,
	PODCAST_TOC,
	PODCAST_RAW_TRANSCRIPT
);

# ╔═╡ 48d75009-a3b4-4b58-8316-6d5833efb12c
sys_prompt = resolve_sys_prompt(podcast);

# ╔═╡ 27bf4bd5-e50f-4266-9b67-2dec9e3ece3e
# println(sys_prompt)

# ╔═╡ 077c29e0-f912-44aa-ac3a-633b12318fb0
const MD_FILEPATH = string(
	"results/podcast_",
	replace(podcast.title, r"\s+" => "_"),
    "-$(LLM_PARAMS[:model].name).md"
)

# ╔═╡ 9a2c37a0-f74e-48c9-a45e-5362038d2611
if !isfile(MD_FILEPATH) || filesize(MD_FILEPATH) == 0
	fh = open(MD_FILEPATH, "a")
	PROCEED_WITH_SYNTHESIS = true
	
	if !has_toc(podcast)
		upd_sys_prompt, upd_podcast = generate_toc(sys_prompt, fh; LLM_PARAMS...)
	else
		save_toc(fh, itemize_toc(podcast.toc))
		upd_sys_prompt, upd_podcast = sys_prompt, podcast
	end
else
	# nothing to do
	PROCEED_WITH_SYNTHESIS = false
	upd_sys_prompt, upd_podcast = sys_prompt, podcast
end

# ╔═╡ 0883ae28-a94f-4bed-abce-39841605d29b
md"""
## Synthesis
"""

# ╔═╡ 368cc124-80ca-4eb5-a667-12bda3b6195d
upd_podcast.toc

# ╔═╡ d2d03fdd-d0e4-4a34-8030-e696fec76f5b
length(upd_sys_prompt)

# ╔═╡ 1eaf917b-0e08-48b7-a65c-6d0895284f11
all_syntheses = String[]

# ╔═╡ e2ffe835-65dc-4c85-aa9a-d98867da2ff5
if PROCEED_WITH_SYNTHESIS
	instruct_prompt₁ = """Proceed with first section "$(podcast.toc[1])" in details. """
	# println("instruction: \n", instruct_prompt₁)
	synthesis₁ = make_timed_chat_request(
		upd_sys_prompt,
		instruct_prompt₁;
		LLM_PARAMS...
	)
	println("Synthesis:\n$(synthesis₁)")
	push!(all_syntheses, join(synthesis₁, "\n"))
	save_synthesis(fh, string("## Content\n\n", all_syntheses[end]))
end

# ╔═╡ 998c05e5-959d-40fa-907c-95e94e5a1c89
if PROCEED_WITH_SYNTHESIS
	instruct_prompt₂ = """Proceed with next section "$(podcast.toc[2])" in details. """
	# println("instruction: \n", instruct_prompt₂)
	synthesis₂ = make_timed_chat_request(
		upd_sys_prompt,
		instruct_prompt₂;
		LLM_PARAMS...
	)
	println("Synthesis:\n$(synthesis₂)")
	push!(all_syntheses, join(synthesis₂, "\n"))
	save_synthesis(fh, string("## Content\n\n", all_syntheses[end]))
end

# ╔═╡ 9b661918-23b6-46fb-9af1-53454d750d5f
if PROCEED_WITH_SYNTHESIS
	instruct_prompt₃ = """Proceed with next section "$(podcast.toc[3])" in details. """
	# println("instruction: \n", instruct_prompt₃)
	synthesis₃ = make_timed_chat_request(
		upd_sys_prompt,
		instruct_prompt₃;
		LLM_PARAMS...
	)
	println("Synthesis:\n$(synthesis₃)")
	push!(all_syntheses, join(synthesis₃, "\n"))
	save_synthesis(fh, string("## Content\n\n", all_syntheses[end]))
end

# ╔═╡ e4d711be-c885-404b-a51a-fda50c9d43c7
if PROCEED_WITH_SYNTHESIS
	instruct_prompt₄ = """Proceed with next section "$(podcast.toc[4])" in details. """
	# 
	synthesis₄ = make_timed_chat_request(
		upd_sys_prompt,
		instruct_prompt₄;
		LLM_PARAMS...
	)
	println("Synthesis:\n$(synthesis₄)")
	push!(all_syntheses, join(synthesis₄, "\n"))
	save_synthesis(fh, string("## Content\n\n", all_syntheses[end]))
end

# ╔═╡ fe816b8a-57a5-4f65-823e-faf4fd31d76e
if PROCEED_WITH_SYNTHESIS
	instruct_prompt₅ = """Proceed with next section "$(podcast.toc[5])" in details. """
	# 
	synthesis₅ = make_timed_chat_request(
		upd_sys_prompt,
		instruct_prompt₅;
		LLM_PARAMS...
	)
	println("Synthesis:\n$(synthesis₅)")
	push!(all_syntheses, join(synthesis₅, "\n"))
	save_synthesis(fh, string("## Content\n\n", all_syntheses[end]))
end

# ╔═╡ 1fcfaf92-0467-4b94-b4b6-7bd034c37119
if PROCEED_WITH_SYNTHESIS
	synthesis₆ = make_timed_chat_request(
		upd_sys_prompt,
		"""Proceed with next section "$(podcast.toc[6])" in details. """;
		LLM_PARAMS...
	)
	println("Synthesis:\n$(synthesis₆)")
	push!(all_syntheses, join(synthesis₆, "\n"))
	save_synthesis(fh, string("## Content\n\n", all_syntheses[end]))
end

# ╔═╡ f79b82b9-2db4-4f7a-8edc-e5d7cc83bc57
if PROCEED_WITH_SYNTHESIS
	synthesis₇ = make_timed_chat_request(
		upd_sys_prompt,
		"""Proceed with next section "$(podcast.toc[7])" in details. """;
		LLM_PARAMS...
	)
	println("Synthesis:\n$(synthesis₇)")
	push!(all_syntheses, join(synthesis₇, "\n"))
	save_synthesis(fh, string("## Content\n\n", all_syntheses[end]))
end

# ╔═╡ 93488ec4-a70a-4c8d-85c9-76d3790fabbe
if PROCEED_WITH_SYNTHESIS
	synthesis₈ = make_timed_chat_request(
		upd_sys_prompt,
		"""Proceed with next section "$(podcast.toc[8])" in details. """;
		LLM_PARAMS...
	)
	println("Synthesis:\n$(synthesis₈)")
	push!(all_syntheses, join(synthesis₈, "\n"))
	save_synthesis(fh, string("## Content\n\n", all_syntheses[end]))
end

# ╔═╡ 5ee9ed3e-e484-4abb-8d12-3d487e97a579
if PROCEED_WITH_SYNTHESIS
	synthesis₉ = make_timed_chat_request(
		upd_sys_prompt,
		"""Proceed with next section "$(podcast.toc[9])" in details. """;
		LLM_PARAMS...
	)
	println("Synthesis:\n$(synthesis₉)")
	push!(all_syntheses, join(synthesis₉, "\n"))
	save_synthesis(fh, string("## Content\n\n", all_syntheses[end]))
end

# ╔═╡ 97659134-da53-4866-9ad1-9fcb51802cd4
if PROCEED_WITH_SYNTHESIS
	synthesis10 = make_timed_chat_request(
		upd_sys_prompt,
		"""Proceed with next section "$(podcast.toc[10])" in details. """;
		LLM_PARAMS...
	)
	println("Synthesis:\n$(synthesis10)")
	push!(all_syntheses, join(synthesis10, "\n"))
	save_synthesis(fh, string("## Content\n\n", all_syntheses[end]))
end

# ╔═╡ f73cdfc6-63d1-4a89-be2d-d268d3311980
if PROCEED_WITH_SYNTHESIS
	synthesis11 = make_timed_chat_request(
		upd_sys_prompt,
		"""Proceed with next section "$(podcast.toc[11])" in details. """;
		LLM_PARAMS...
	)
	println("Synthesis:\n$(synthesis11)")
	push!(all_syntheses, join(synthesis11, "\n"))
	save_synthesis(fh, string("## Content\n\n", all_syntheses[end]))
end

# ╔═╡ 31e10d8d-d176-49cd-b6a0-51e9136bea21
if PROCEED_WITH_SYNTHESIS
	close(fh);
end

# ╔═╡ 7711463b-bc7a-450b-82fc-a2004234feba
md"""
## Convert to pdf 
"""

# ╔═╡ 5de029b6-95b5-4a9b-bd35-85f7558d965e
convert_to_pdf(MD_FILEPATH);

# ╔═╡ a78ebf24-34d7-4ebc-ba6e-7283f52e8110
# pwd()  # == "/home/pascal/Projects/ML_DL/Notebooks/julia-notebooks/web-scrapping"

# ╔═╡ cdb9c685-050a-430e-bde4-cd18c496f2a8
md"""
---
"""

# ╔═╡ be4996ad-0379-495b-bb00-2eb3c0847227
md"""
## Resulting synthesis
"""

# ╔═╡ c4f7a724-fe95-45cb-94af-656cc5fbebb5
if PROCEED_WITH_SYNTHESIS
	Markdown.parse(join(all_syntheses, "\n"))
else
	content_ = ""
	open(MD_FILEPATH, "r") do fh
		content_ = readlines(fh)
	end
	Markdown.parse(join(content_, "\n"))
end

# ╔═╡ fe39ac9a-88fc-4b35-9e91-e4d93b2187b3
md"""
---
"""

# ╔═╡ 322ecf98-5694-42a1-84f2-caf8a5fa58ad
html"""
<style>
  main {
    max-width: calc(1200px + 25px + 6px);
  }
</style>
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BytePairEncoding = "a4280ba5-8788-555a-8ca8-4a8c3d966a71"
JSON3 = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
OpenAI = "e9f21f70-7185-4079-aca2-91159181367c"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Weave = "44d3d7a6-8a23-5bf8-98c5-b353f8df5ec9"

[compat]
BytePairEncoding = "~0.5.2"
JSON3 = "~1.14.0"
OpenAI = "~0.9.0"
PlutoUI = "~0.7.59"
Weave = "~0.10.12"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.4"
manifest_format = "2.0"
project_hash = "ede43d3ff828bc0340f4933df7e90d252e1dc438"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "6a55b747d1812e699320963ffde36f1ebdda4099"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "4.0.4"
weakdeps = ["StaticArrays"]

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Atomix]]
deps = ["UnsafeAtomics"]
git-tree-sha1 = "c06a868224ecba914baa6942988e2f2aade419be"
uuid = "a9b6321e-bd34-4604-b9c9-b65b8de01458"
version = "0.1.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "0691e34b3bb8be9307330f88d1a3c3f25466c24d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.9"

[[deps.BytePairEncoding]]
deps = ["Artifacts", "Base64", "DataStructures", "DoubleArrayTries", "LRUCache", "LazyArtifacts", "StructWalk", "TextEncodeBase", "Unicode"]
git-tree-sha1 = "b8d2edaf190d01d6a1c30b80d1db2d866fbe7371"
uuid = "a4280ba5-8788-555a-8ca8-4a8c3d966a71"
version = "0.5.2"

[[deps.CEnum]]
git-tree-sha1 = "389ad5c84de1ae7cf0e28e381131c98ea87d54fc"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.5.0"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra"]
git-tree-sha1 = "3e4b134270b372f2ed4d4d0e936aabaefc1802bc"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.25.0"
weakdeps = ["SparseArrays"]

    [deps.ChainRulesCore.extensions]
    ChainRulesCoreSparseArraysExt = "SparseArrays"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "bce6804e5e6044c6daab27bb533d1295e4a2e759"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.6"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "8ae8d32e09f0dcf42a36b90d4e17f5dd2e4c4215"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.16.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "ea32b83ca4fefa1768dc84e504cc0a94fb1ab8d1"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.4.2"

[[deps.ConstructionBase]]
git-tree-sha1 = "76219f1ed5771adbb096743bff43fb5fdd4c1157"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.8"

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseLinearAlgebraExt = "LinearAlgebra"
    ConstructionBaseStaticArraysExt = "StaticArrays"

    [deps.ConstructionBase.weakdeps]
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataDeps]]
deps = ["HTTP", "Libdl", "Reexport", "SHA", "Scratch", "p7zip_jll"]
git-tree-sha1 = "8ae085b71c462c2cb1cfedcb10c3c877ec6cf03f"
uuid = "124859b0-ceae-595e-8997-d05f6a7a8dfe"
version = "0.7.13"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "1d0a14036acb104d9e89698bd408f63ab58cdc82"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.20"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.DoubleArrayTries]]
deps = ["OffsetArrays", "Preferences", "StringViews"]
git-tree-sha1 = "78dcacc06dbe5eef9c97a8ddbb9a3e9a8d9df7b7"
uuid = "abbaa0e5-f788-499c-92af-c35ff4258c82"
version = "0.1.1"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "dcb08a0d93ec0b1cdc4af184b26b591e9695423a"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.10"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.FuncPipelines]]
git-tree-sha1 = "6484a27c35ecc680948c7dc7435c97f12c2bfaf7"
uuid = "9ed96fbb-10b6-44d4-99a6-7e2a3dc8861b"
version = "0.2.3"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "ec632f177c0d990e64d955ccc1b8c04c485a0950"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.1.6"

[[deps.HTML_Entities]]
deps = ["StrTables"]
git-tree-sha1 = "c4144ed3bc5f67f595622ad03c0e39fa6c70ccc7"
uuid = "7693890a-d069-55fe-a829-b4a6d304f0ee"
version = "1.0.1"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "d1d712be3164d61d1fb98e7ce9bcbc6cc06b45ed"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.10.8"

[[deps.Highlights]]
deps = ["DocStringExtensions", "InteractiveUtils", "REPL"]
git-tree-sha1 = "9e13b8d8b1367d9692a90ea4711b4278e4755c32"
uuid = "eafb193a-b7ab-5a9e-9068-77385905fa72"
version = "0.5.3"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7e5d6779a1e09a36db2a7b6cff50942a0a7d0fca"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.5.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JSON3]]
deps = ["Dates", "Mmap", "Parsers", "PrecompileTools", "StructTypes", "UUIDs"]
git-tree-sha1 = "eb3edce0ed4fa32f75a0a11217433c31d56bd48b"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.14.0"

    [deps.JSON3.extensions]
    JSON3ArrowExt = ["ArrowTypes"]

    [deps.JSON3.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"

[[deps.KernelAbstractions]]
deps = ["Adapt", "Atomix", "InteractiveUtils", "MacroTools", "PrecompileTools", "Requires", "StaticArrays", "UUIDs", "UnsafeAtomics", "UnsafeAtomicsLLVM"]
git-tree-sha1 = "04e52f596d0871fa3890170fa79cb15e481e4cd8"
uuid = "63c18a36-062a-441e-b654-da1e3ab1ce7c"
version = "0.9.28"

    [deps.KernelAbstractions.extensions]
    EnzymeExt = "EnzymeCore"
    LinearAlgebraExt = "LinearAlgebra"
    SparseArraysExt = "SparseArrays"

    [deps.KernelAbstractions.weakdeps]
    EnzymeCore = "f151be2c-9106-41f4-ab19-57ee4f262869"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.LLVM]]
deps = ["CEnum", "LLVMExtra_jll", "Libdl", "Preferences", "Printf", "Requires", "Unicode"]
git-tree-sha1 = "4ad43cb0a4bb5e5b1506e1d1f48646d7e0c80363"
uuid = "929cbde3-209d-540e-8aea-75f648917ca0"
version = "9.1.2"

    [deps.LLVM.extensions]
    BFloat16sExt = "BFloat16s"

    [deps.LLVM.weakdeps]
    BFloat16s = "ab4f0b2a-ad5b-11e8-123f-65d77653426b"

[[deps.LLVMExtra_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl", "TOML"]
git-tree-sha1 = "05a8bd5a42309a9ec82f700876903abce1017dd3"
uuid = "dad2f222-ce93-54a1-a47d-0025e8a3acab"
version = "0.0.34+0"

[[deps.LRUCache]]
git-tree-sha1 = "b3cc6698599b10e652832c2f23db3cab99d51b59"
uuid = "8ac3fa9e-de4c-5943-b1dc-09c6b5f20637"
version = "1.6.1"
weakdeps = ["Serialization"]

    [deps.LRUCache.extensions]
    SerializationExt = ["Serialization"]

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.4.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.6.4+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "f9557a255370125b405568f9767d6d195822a175"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.17.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "c1dd6d7978c12545b4179fb6153b9250c96b0075"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.3"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "2fa9ee3e63fd3a4f7a9a4f4744a52f4856de82df"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.13"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "c067a280ddc25f196b5e7df3877c6b226d390aaf"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.9"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.1.10"

[[deps.Mustache]]
deps = ["Printf", "Tables"]
git-tree-sha1 = "3b2db451a872b20519ebb0cec759d3d81a1c6bcb"
uuid = "ffc61752-8dc7-55ee-8c37-f3e9cdd09e70"
version = "1.0.20"

[[deps.NNlib]]
deps = ["Adapt", "Atomix", "ChainRulesCore", "GPUArraysCore", "KernelAbstractions", "LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "da09a1e112fd75f9af2a5229323f01b56ec96a4c"
uuid = "872c559c-99b0-510c-b3b7-b6c96a88d5cd"
version = "0.9.24"

    [deps.NNlib.extensions]
    NNlibAMDGPUExt = "AMDGPU"
    NNlibCUDACUDNNExt = ["CUDA", "cuDNN"]
    NNlibCUDAExt = "CUDA"
    NNlibEnzymeCoreExt = "EnzymeCore"
    NNlibFFTWExt = "FFTW"
    NNlibForwardDiffExt = "ForwardDiff"

    [deps.NNlib.weakdeps]
    AMDGPU = "21141c5a-9bdb-4563-92ae-f87d6854732e"
    CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"
    EnzymeCore = "f151be2c-9106-41f4-ab19-57ee4f262869"
    FFTW = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    cuDNN = "02a925ec-e4fe-4b08-9a7e-0d78e3d38ccd"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OffsetArrays]]
git-tree-sha1 = "1a27764e945a152f7ca7efa04de513d473e9542e"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.14.1"
weakdeps = ["Adapt"]

    [deps.OffsetArrays.extensions]
    OffsetArraysAdaptExt = "Adapt"

[[deps.OpenAI]]
deps = ["Dates", "HTTP", "JSON3"]
git-tree-sha1 = "c66f597044ac6cd41cbf4b191d59abbaf2003d9f"
uuid = "e9f21f70-7185-4079-aca2-91159181367c"
version = "0.9.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+4"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "38cb508d080d21dc1128f7fb04f20387ed4c0af4"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.3"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a028ee3cb5641cccc4c24e90c36b0a4f7707bdf5"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.0.14+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.PartialFunctions]]
deps = ["MacroTools"]
git-tree-sha1 = "47b49a4dbc23b76682205c646252c0f9e1eb75af"
uuid = "570af359-4316-4cb7-8c74-252c00c2016b"
version = "1.2.0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "ab55ee1510ad2af0ff674dbcced5e94921f867a9"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.59"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.PrimitiveOneHot]]
deps = ["Adapt", "ChainRulesCore", "GPUArraysCore", "KernelAbstractions", "NNlib"]
git-tree-sha1 = "bbf8e986a586300ed8fd929db1f62bd158452b90"
uuid = "13d12f88-f12b-451e-9b9f-13b97e01cc85"
version = "0.2.1"

    [deps.PrimitiveOneHot.extensions]
    PrimitiveOneHotGPUArraysExt = "GPUArrays"
    PrimitiveOneHotMetalExt = ["Metal", "GPUArrays"]
    PrimitiveOneHotOneHotArraysExt = "OneHotArrays"

    [deps.PrimitiveOneHot.weakdeps]
    GPUArrays = "0c68f7d7-f131-5f86-a1c3-88cf8149b2d7"
    Metal = "dde4c033-4e86-420c-a63e-0dd931031962"
    OneHotArrays = "0b1bfda6-eb8a-41d2-88d8-f5af5cad476f"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.RustRegex]]
deps = ["rure_jll"]
git-tree-sha1 = "16be5e710d7b980678ec0d8c61d4c00e9a5591e3"
uuid = "cdf36688-0c6d-42c6-a883-5d2df16e9e88"
version = "0.1.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.10.0"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "eeafab08ae20c62c44c8399ccb9354a04b80db50"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.7"
weakdeps = ["ChainRulesCore", "Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

[[deps.StaticArraysCore]]
git-tree-sha1 = "192954ef1208c7019899fbf8049e717f92959682"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.3"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.10.0"

[[deps.StrTables]]
deps = ["Dates"]
git-tree-sha1 = "5998faae8c6308acc25c25896562a1e66a3bb038"
uuid = "9700d1a9-a7c8-5760-9816-a99fda30bb8f"
version = "1.0.1"

[[deps.StringEncodings]]
deps = ["Libiconv_jll"]
git-tree-sha1 = "b765e46ba27ecf6b44faf70df40c57aa3a547dcb"
uuid = "69024149-9ee7-55f6-a4c4-859efe599b68"
version = "0.3.7"

[[deps.StringViews]]
git-tree-sha1 = "f7b06677eae2571c888fd686ba88047d8738b0e3"
uuid = "354b36f9-a18e-4713-926e-db85100087ba"
version = "1.3.3"

[[deps.StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "ca4bccb03acf9faaf4137a9abc1881ed1841aa70"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.10.0"

[[deps.StructWalk]]
deps = ["ConstructionBase"]
git-tree-sha1 = "ef626534f40a9d99b3dafdbd54cfe411ad86e3b8"
uuid = "31cdf514-beb7-4750-89db-dda9d2eb8d3d"
version = "0.2.1"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.2.1+1"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "598cd7c1f68d1e205689b1c2fe65a9f85846f297"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.12.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TextEncodeBase]]
deps = ["DataStructures", "DoubleArrayTries", "FuncPipelines", "PartialFunctions", "PrimitiveOneHot", "RustRegex", "StaticArrays", "StructWalk", "Unicode", "WordTokenizers"]
git-tree-sha1 = "66f827fa54c38cb7a7b174d3a580075b10793f5a"
uuid = "f92c20c0-9f2a-4705-8116-881385faba05"
version = "0.8.3"

[[deps.TranscodingStreams]]
git-tree-sha1 = "e84b3a11b9bece70d14cce63406bbc79ed3464d2"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.2"

[[deps.Tricks]]
git-tree-sha1 = "7822b97e99a1672bfb1b49b668a6d46d58d8cbcb"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.9"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnsafeAtomics]]
git-tree-sha1 = "6331ac3440856ea1988316b46045303bef658278"
uuid = "013be700-e6cd-48c3-b4a1-df204f14c38f"
version = "0.2.1"

[[deps.UnsafeAtomicsLLVM]]
deps = ["LLVM", "UnsafeAtomics"]
git-tree-sha1 = "2d17fabcd17e67d7625ce9c531fb9f40b7c42ce4"
uuid = "d80eeb9a-aca5-4d75-85e5-170c8b632249"
version = "0.2.1"

[[deps.Weave]]
deps = ["Base64", "Dates", "Highlights", "JSON", "Markdown", "Mustache", "Pkg", "Printf", "REPL", "RelocatableFolders", "Requires", "Serialization", "YAML"]
git-tree-sha1 = "092217eb5443926d200ae9325f103906efbb68b1"
uuid = "44d3d7a6-8a23-5bf8-98c5-b353f8df5ec9"
version = "0.10.12"

[[deps.WordTokenizers]]
deps = ["DataDeps", "HTML_Entities", "StrTables", "Unicode"]
git-tree-sha1 = "01dd4068c638da2431269f49a5964bf42ff6c9d2"
uuid = "796a5d58-b03d-544a-977e-18100b691f6e"
version = "0.5.6"

[[deps.YAML]]
deps = ["Base64", "Dates", "Printf", "StringEncodings"]
git-tree-sha1 = "dea63ff72079443240fbd013ba006bcbc8a9ac00"
uuid = "ddb6d928-2868-570f-bddf-ab3f9cf99eb6"
version = "0.4.12"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"

[[deps.rure_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a24449573502225e7833277f99a8e2c19801f5a7"
uuid = "2a13b4fb-3cbe-5d55-9db2-86fcb16976f1"
version = "0.2.2+0"
"""

# ╔═╡ Cell order:
# ╟─c94c972e-a75f-11ee-153c-771e07689f95
# ╠═bf0e8d60-d704-4c66-ad3f-d372cb2963a2
# ╠═59d0b923-435a-4dc8-902f-02a9b5a177db
# ╠═0200cef1-6862-4704-b6e7-30f1ac54a1ed
# ╠═7df1d566-a7a8-4a9d-a477-2e2fea683e27
# ╠═0c5d69c3-8d38-4366-9e2e-23e7475744ac
# ╠═f1cf76d4-d894-4c80-a4bd-0eb6f37df38d
# ╠═d2dfeb72-86c6-4535-8d98-e3293beb7c7a
# ╟─2f4ae40f-a1ab-470b-a1b7-a04fec353b0e
# ╠═ffcb61c2-9180-439e-b46b-733c3a5f5a38
# ╠═48d75009-a3b4-4b58-8316-6d5833efb12c
# ╠═27bf4bd5-e50f-4266-9b67-2dec9e3ece3e
# ╠═077c29e0-f912-44aa-ac3a-633b12318fb0
# ╠═9a2c37a0-f74e-48c9-a45e-5362038d2611
# ╟─0883ae28-a94f-4bed-abce-39841605d29b
# ╠═368cc124-80ca-4eb5-a667-12bda3b6195d
# ╠═d2d03fdd-d0e4-4a34-8030-e696fec76f5b
# ╠═1eaf917b-0e08-48b7-a65c-6d0895284f11
# ╠═e2ffe835-65dc-4c85-aa9a-d98867da2ff5
# ╠═998c05e5-959d-40fa-907c-95e94e5a1c89
# ╠═9b661918-23b6-46fb-9af1-53454d750d5f
# ╠═e4d711be-c885-404b-a51a-fda50c9d43c7
# ╠═fe816b8a-57a5-4f65-823e-faf4fd31d76e
# ╠═1fcfaf92-0467-4b94-b4b6-7bd034c37119
# ╠═f79b82b9-2db4-4f7a-8edc-e5d7cc83bc57
# ╠═93488ec4-a70a-4c8d-85c9-76d3790fabbe
# ╠═5ee9ed3e-e484-4abb-8d12-3d487e97a579
# ╠═97659134-da53-4866-9ad1-9fcb51802cd4
# ╠═f73cdfc6-63d1-4a89-be2d-d268d3311980
# ╠═31e10d8d-d176-49cd-b6a0-51e9136bea21
# ╟─7711463b-bc7a-450b-82fc-a2004234feba
# ╠═5de029b6-95b5-4a9b-bd35-85f7558d965e
# ╠═a78ebf24-34d7-4ebc-ba6e-7283f52e8110
# ╟─cdb9c685-050a-430e-bde4-cd18c496f2a8
# ╟─be4996ad-0379-495b-bb00-2eb3c0847227
# ╠═c4f7a724-fe95-45cb-94af-656cc5fbebb5
# ╟─fe39ac9a-88fc-4b35-9e91-e4d93b2187b3
# ╟─322ecf98-5694-42a1-84f2-caf8a5fa58ad
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
