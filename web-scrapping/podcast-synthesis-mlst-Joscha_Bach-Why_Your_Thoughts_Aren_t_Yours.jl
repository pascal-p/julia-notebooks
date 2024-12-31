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

1. reformulate Podcast (raw) transcript eliminating hesitation, ...
1. TBD...
"""

# ╔═╡ 0200cef1-6862-4704-b6e7-30f1ac54a1ed
usage_shared_state = usage_shared_state_maker()

# ╔═╡ 7df1d566-a7a8-4a9d-a477-2e2fea683e27
const LLM_PARAMS = Dict{Symbol, Union{String, Real, LLM_Model, Function, Dict, Nothing}}(
  :max_completion_tokens => 8192,
  :model => DMODELS["gpt-4o-2024-08-06"],
  :temperature => 0.5,
  :seed => 117,
  :response_format => nothing,  # Dict("type" => "json_object"),
  :calc_cost => calc_usage_maker(usage_shared_state)
)

# ╔═╡ 0c5d69c3-8d38-4366-9e2e-23e7475744ac
PODCAST_TITLE, PODCAST_URL = """Joscha Bach - Why Your Thoughts Aren't Yours.""", """https://www.youtube.com/watch?v=3MkJEGE9GRY&t=3590s"""

# ╔═╡ f1cf76d4-d894-4c80-a4bd-0eb6f37df38d
PODCAST_TOC = map(x -> string(strip(x)),
                  split("""
1. Consciousness, Intelligence, Agency, Animism, Evolution
1.1 Consciousness and Intelligence in AI Development [00:00:00]
1.2 Agency, Intelligence, and Their Relationship to Physical Reality [00:07:44]
1.3 Virtual Patterns and Causal Structures in Consciousness [00:13:36]
1.4 Reinterpreting Concepts of God and Animism in Information Processing Terms [00:25:49]
1.5 Animism and Evolution as Competition Between Software Agents [00:32:50]

2. Self-Organizing Systems and Cognitive Models in AI
2.1 Consciousness as self-organizing software [00:37:59]
2.2 Critique of panpsychism and alternative views on consciousness [00:45:49]
2.3 Emergence of consciousness in complex systems [00:50:48]
2.4 Neuronal motivation and the origins of consciousness [00:52:50]
2.5 Coherence and Self-Organization in AI Systems [00:56:47]

3. Advanced AI Architectures and Cognitive Processes
3.1 Second-Order Software and Complex Mental Processes [00:57:50]
3.2 Collective Agency and Shared Values in AI [01:01:05]
3.3 Limitations of Current AI Agents and LLMs [01:05:40]
3.4 Liquid AI and Novel Neural Network Architectures [01:06:40]
3.5 AI Model Efficiency and Future Directions [01:10:06]
3.6 LLM Limitations and Internal State Representation [01:19:00]

4. AI Regulation and Societal Impact
4.1 AI Regulation and Societal Impact [01:31:23]
4.2 Open-Source AI and Industry Challenges [01:49:50]
""", "\n")
) |> vtoc -> filter(x -> length(x) > 0, vtoc)

# ╔═╡ d2dfeb72-86c6-4535-8d98-e3293beb7c7a
PODCAST_CONTEXT = """In this podcast, Dr Joscha Bach discusses advanced AI, consciousness, and cognitive modeling.""";

# ╔═╡ 2f4ae40f-a1ab-470b-a1b7-a04fec353b0e
PODCAST_RAW_TRANSCRIPT = """
1.1 Consciousness and Intelligence in AI Development
Stuff that we find interesting in humans is this ability to become self-authoring. To change their own way in which you're interacting with the world, in which you're interacting with yourself, becoming a different system, developing yourself. Growing. Evolution is the competition between different software agents that can reproduce and can code themselves and use the molecules to encode themselves, and they use the mechanism to implement themselves and perpetuate themselves and compete. But it's actually all about software. It's all about spirits. Joshua. Joshua. Joshua Bach is a leading cognitive scientist and artificial intelligence researcher with an impressive background. You have said that consciousness is a virtual property. Virtual means as if. So, something behaves as if it would exist. And I think that the objects that we are, we are conscious agents, for instance, that observe themselves interacting with the world. We know that from a physical perspective we do not exist. If you take any kind of measuring device and you look at the human brain, you will not see a person. What you will see is an activation pattern between cells that is producing the behavior of the person. In the same way, when you take a microscope and look at the computer that runs Minecraft, you will not find any Minecraft. But you will see is some pattern of electricity that is propagating through the transistors of the computer and at some level is producing the causal structure of Minecraft. But you could also say that Minecraft is nevertheless real. It's implemented, and I find this definition of saying something is real to the degree that it is implemented quite useful. And then we find that there are different degrees of realness. Controlling the future entails making models, and the better you can model, the better you can do this. And at some point you have to discover yourself. You regulate the world in a particular way, and your model making works in a particular way, and then trying to figure out in which ways did my own model not work, and what are the limitations of my ability to observe and make models. And when this is happening, you start to edit your own source code and then it becomes really interesting. Joshua Bach. It's an honor to have you on the show. Thank you. My pleasure. Do you feel the AGI. In some sense, it has not changed very much. I felt that the AGI is coming. When I was a young kid, when I realized what computers can do. And in many ways, I see that the world is now more optimistic. And there is this amazing momentum and also a lot of hype in the air. But it's also not clear how far the present technology is going and when. And so it's a very exciting moment in time, but we don't know how far in the future AGI actually is. What are your timelines for AGI? I think that's going to happen in our lifetime. And there's also the question of what AGI actually is. So it's something that we probably have to think about more deeply. A lot of people thought having a system that is like in Star Trek where you'd say, computer, please do the following would be AGI. And arguably we have that now, right? If you remember this 1980s Star Trek episode where At this time. We're going to go back to the 1980s and walk the streets, and Scotty is trying to use a computer and addresses it in the computer, does not understand him. Speaking to it in natural language, does not understand English, does not parse his sentences. He is flabbergasted. And it's really interesting to see this contrast, because back then it was obvious to us that computers cannot do such a thing, and they can only do it in the far distant future. And now they can. And now we are pitching around the fact that they are somewhat unreliable and sometimes make up stuff, and that sometimes they cannot perform certain tasks and people can do very well. And at the other hand, we are seeing that they are performing skills that we consider to be quite amazing, and we see them getting to the level of a silver medalist in math, but we don't know how well they're doing when something is happening out of distribution. Arguably, there was a lot of training data on the performance of mass in the models that they but the stuff that they were looking at and people fine tuned the model to perform better in such circumstances. But what I observe and I'm playing with the LMS, is that in the domains where I'm truly competent, the LM is typically staying a bit below my own performance. It's only in the domains where I have no competence that the LM is often able to do something that I find very impressive, and so is intelligence, the ability to perform at slightly superhuman level across many, many domains, but being very fast and then somehow combining that to get to the next level, or is there something that is fundamentally missing what we can see, it's it's clearly different from our performance. But maybe AI is is not so much about a skill but about skill acquisition. So when we are testing AI, using intelligence tests for humans that usually don't get the useful results, and that's because intelligence tests for humans are directed on skill. Typically we test the performance on a given task and we hope that people are not able to train that performance very well. So it correlates somewhat to their ability to solve puzzles of ex nihilo from the start, instead of just memorizing how to solve puzzles. But this makes human intelligence tests unusable for using them outside of the human context. They cannot use them for animals, cannot use them for machines, because we measure the skill performance by taking the average human level and then measuring the delta in some sense. And both animals and machines are so far away from this human delta, from the human average that we cannot make a meaningful comparison. And instead, what would be more interesting is if you know the performance of a system before it's trying to figure something out, and then you look at the performance after that and you see how much data it had and what nature that data had, how many operations it did. In the meantime, you have a much better measure for its ability to build a new skill and new ability. And this is actually what intelligence is about the ability to make models. And so you could say AGI is the ability to make any model that is mathematically obtainable under the circumstances, which means given the resources that you have available and given the data that you have available, if that model is discoverable, if you understand this search space for this model, then the system should be able to find it. And very often we have difficulty to formalize the search space correctly. And if we could, if we could find some optimal measure for organizing the search space of functions that we are looking at to get the skills that we want, then maybe we would have the answer to how to obtain AGI. But this is not what our current systems are doing. What they're doing is they, for instance, predict the next token, and the token is some mapping of text from the internet into a form that the model can process. And we see that these models are getting better and better at predicting the next token, which means they're able to imitate the performance that give rise to producing these strings on the internet better and better. And the same thing is happening for images, but it's clearly not quite the same thing as making a proof for the Riemann zeta function hypothesis. Because the Riemann zeta hypothesis, there is no available proof on the internet. And just by combining steps for existing proofs, it's very unlikely that this model randomly stumbles on something. So in a way, we would need to find a way to turn these linguistic problems into a form of self-play where this thing is like in go or chess able to play against itself and in this way has some kind of feedback. Games give you a feedback. Mathematics in principle can give you a feedback or whether the proof works or not. Programming can give you a feedback because the program might compile or not and might achieve a result or not. If you can turn this into self-play, it should be able to go beyond human performance. But the way in which we are training the LLM, we don't know how to get to this level at the moment.

1.2 Agency, Intelligence, and Their Relationship to Physical Reality
 I was speaking with Francois Chollet this morning, and he has a similar conception of intelligence. You know, like model building efficiency. For him, it's abstraction, building efficiency. And I said to him, your your conception is kind of talking about the what, not the how. What about agency? What about this self-play this, you know, autodidactic exchange of information with your environment? And he said that agency and intelligence are they don't have to be entangled, but you do need to be able to set your own goals. And the skill programs might represent a kind of plan, but is it a similar thing for you? I mean, is this self-play part of intelligence or is it just an implementation detail? You find that in real world environments, people often discount intelligence because they realized what intelligence is a tool and what matters is what you deploy the tool for. And that's why agency tends to be more useful than intelligence. If somebody has a lot of agency, they can hire somebody who's very intelligent to solve a problem when there is a problem. But intelligence if this is problem solving ability or model making ability. Somebody who is just making models for the sake of making models is not necessarily going to be successful. And so we have to ask ourselves what is agency? And if agency is the name of the game? I think it's the control of the future. Can contrast this with the thermostat. Thermostat, I think, is not an agent, at least a primitive thermostat. It's a system that is measuring the world in the here and now, and then directly translates this measurement into some kind of regulator action, some kind of switching. And as a result, it's basically regulating the present based on data that is available in the present. But what happens if you are building a system that is able to regulate the future? So if you had a thermostat that basically can anticipate how long it's going to take for the room to heat up after it triggers the switch, and how long is it going to take for the temperature to go down and how is the distance between the sensor for the temperature and the heating in the room? So how indicative is this? Maybe if it's very far, you get a good idea about the actual temperature in the room, but if it's very close, you could make an inference about the size of the room, the volume of the air that actually needs to be heated, and how that measurement is actually a distortion of what's going on. And so the more models you can make, the more efficient your regulation is going to become. And as soon as you have a system that is just not taking measurement right now, but builds a model of how the world is going to change as a result of its action, you end up with a system that seems to have preferences and that has knowledge, and it has commitments, and it seems to be goal directed. And so you have all these properties of an agent just coming out of the ability to control the future. And of course, controlling the future entails making models. And the better you can model, the better you can do this. And at some point you have to discover yourself and this fact that you regulate the vote in a particular way, and your model making works in a particular way, and then trying to figure out in which ways did my own model working not work, and what are the limitations of my ability to observe and make models. And when this is happening, you start to edit your own source code and then it becomes really interesting. And I think that intelligence at some level can be seen as the ability to just deal with a particular domain and develop skills there. But the stuff that we find interesting in humans is this ability to become self-authoring, to change their own way in which you're interacting with the world in which you're interacting with yourself, becoming a different system, developing yourself, growing. Now, we're not going to talk about consciousness just now. We'll save it for later. But you have said that consciousness is a virtual property. It's as if. Could you say the same thing about agency? In some sense, you could say that agency is not a physical property, but what is physical after all? You could say that physics is a theory. It's a model of a of certain kind of reality that is mechanical in the sense you would say that Minecraft is not physical, because it's just a symbolic convention that exists inside of the computer, and that can be completely arbitrary, whereas the physical universe is thought of as something that is not dependent on some things intentions, and it's just acting mechanical pattern out. But what you find that this mechanical pattern gives rise to structure, that we can best model if we project it through the lens of agency of control systems that make models. And if you do not use this lens, there is a lot of things that you can no longer understand. A good example that I think instantly obvious to everybody is money. We all agree that money is not physical, but if you believe that money doesn't exist, there are parts of reality that you cannot explain. And it's not that money is just a belief that people have. And when people stop having that belief that the world is explainable in better ways. No, you can also build a stock market entirely with computers that are only manipulating numbers and bank accounts. And it's still going to be the same thing. So you could say that money is a coarse grained causal pattern that behaves as if it existed. It has causal power, and it's able to create patterns in physical reality at a certain level of resolution. And the money is not just some ephemeral pattern that we discover as an arbitrary way of projecting universe at a certain level of resolution. It's actually an invariance that is not manifest at other levels of the universe. So when you make a model, you're looking for invariances for things that don't change in the world. And money is such an invariance. Right. And the interesting question is, are mental states Invariances. So they all exist as if like money, but to which degree are they actually implemented? To which degree are there causal structure that is shaping the universe in a way for which you do not find another alternative, better representation?

1.3 Virtual Patterns and Causal Structures in Consciousness
Yeah. I mean, one of the themes of our discussion today is you're identifying these patterns of self-organization, these virtual patterns. Presumably you would say they are real, but they have causal powers. So they they change the world that we're in. But you use the designation virtual. What exactly do you mean by that? Virtual means as if. So, something behaves as if it would exist. And I think that the objects that we are, we are conscious agents, for instance, that observe themselves interacting with the world. We know that from a physical perspective we do not exist. If you take a microscope and or any kind of measuring device and you look at the human brain, you will not see a person. What you will see is an activation pattern between cells that is producing the behavior of the person. In the same way, when you take a microscope and look at a computer that runs Minecraft, you will not find any Minecraft. What you will see is some pattern of electricity that is propagating through the transistors of the computer, and at some level is producing the causal structure of Minecraft. But you could also say that Minecraft is nevertheless real because it's implemented. And I find this definition of saying something is real to the degree that it is implemented quite useful. And then we find that there are different degrees of realness. For instance, a simulation of a weather in a country is a simulation because it's not real in a sense, because it is implemented on a different causal structure at a certain level of abstraction, that a certain degree of resolution gives you isomorphism or some kind of projection that you can make that allows you to predict the weather to a certain point and up to a certain resolution. And beyond that, it falls apart because the causal structure below is different. Or another example is you play a computer game, say you play a shooter game and you can shoot a gun, but inside of the computer there is no accurate model of the physics of the bullet going through air or whatever. It's just some vector calculation that allows you to be to play that game in similar ways as if you were doing it in the real world, so you can transfer ideas that you got from your interaction with the physical universe into this game, because that game is actually producing causal interaction pattern, even though it's on a different causal substrate on the CPU and GPU and the computer that allows this interaction. But a movie, for instance, produces a sequence of observables without an underlying causal structure. So you can watch the movie, you have the impression you are maybe in World War Two and you see people shooting at each other, but there is no possibility to causally interact with the structure of the movie because there is no causal structure underneath the celluloid in the movie or in the videotape, beyond the ability to generate a sequence of patterns. And so this is, I would say, a simulacrum, not a simulation. If you look at these different things, you have an observable dynamic that we can project into a model, and then you have a simulation that is such a model that you can dynamically enact in the simulacrum, that is, a sequence of observables that different degrees of realness, observable dynamic is a beautiful way to put it, because, I mean, Richard Dawkins came up with this idea of The Selfish Gene, and I'm a big fan of emergence, right? We have this ladder of emergence. We live in this epic dynamical system. And what we tried to do is, is make sense of the world. So we identify a sufficient level of resolution, you know, on one rung of the emergence ladder. And we identify patterns or phenomena based on their intelligibility, their causal power, how vague they are and the boundaries and so on. And how do you think about that? I don't like the word of emergence because it gives people an intuition that there is this magical thing, emergence, when you are putting things in the universe at a particular kind of arrangement, then for some magical reasons, the emergent thing is happening. It's coming into existence, and then it produces a behavior that somehow is more than the sum of its parts, and it's completely mind blowing. And maybe this explains consciousness. And for some reason, emergence should be a phenomenon that is discussed a lot in the context of the relationship between software and hardware. And it never really is right in software and hardware. This is where you should be seeing it. You see this on one level there's transistors with electricity, and if you zoom further in, there's not even transistors and electricity. It's just atoms and molecules. And if you zoom further in, even they are just some kind of coarse grained abstraction. And then on the other side, you have these computational languages that implement our ideas of logical progressions and computer programs. How do they relate? Isn't that magical? Nobody thinks it's magical. You're completely used to it. You take it for granted. And we know that there is no magic involved, right? If we are unable to wrap our minds around it, the problem is clearly with our mind there is not no big mystery. And yet, when we think about our mental representations about our psyche, for some reason people believe that something entirely different must be going on. And this is this emergence thing. And I think this points to a confusion I should have clarified. I mean, I'm talking about weak emergence, so simply a matter of surprise and complexity, not the de novo generation of phenomena which has no analytical pathway to the. I think there's nothing wrong with this term. Emergence and supervenience can be useful ways to talk about this stuff. I just mean when we are sitting down in, say, a philosophy seminar and the philosophy professor is very enamored with emergence in the context of mental states, but doesn't believe it's important or remarkable in the context of software. I find that suspicious. I think the degree of astonishment should be the same. Mm mm. So the basically the intuitions that this term is loaded with might be slightly different ones. And I think that's often an issue that a lot of our mental concepts of things happening are black boxes to us. And so we pointed them and we give them a label, and we have an idea of what this particular component of our mind is modeling and how it operates. But it's essentially a black box. And if we do not take this black box apart and map it to first principles to explain what kind of function our mind is actually producing, this leads to weirdness. A good example is the intuitions that mathematicians often have about geometry. I remember when I had to draw my first line on a Commodore 64. It was super complicated because it's basic, doesn't have a command to make a line, so you have to poke some values into the video chip to make it forget how to render characters and interpret part of the working memory as pixels. And then you need to tell it where the starting address in memory is, where the pixels beginning, and then eight bits, one byte is eight pixels, and you need to do some binary arithmetic to make it happen. And eight bytes below, because it's still the character matrix, are one block of eight by eight pixels and have 40 in a row 25 below. And so you need a lot of mathematical tricks, a lot of puzzle solving to draw a line by making the right for next loop, to figure out which pixels you need to flip into, which bytes and which addresses they correspond to in working memory. And then you generalize this at some point in a function that works at arbitrary scales. And it would also work with a different pixel matrix and work with a different color resolution. And the more you generalize it, the closer you get to this mathematical ideal of a line. And yet mathematicians think you get the line in some sense for free. And when you tell them, oh, when you talk about the line, you talk about the generalization of all the ways in which you can map such a function onto some kind of lattice or matrix or whatever, use as your substrate, right, as a function of the topology and dimensionality of that substrate. Then then you have that line, and the mathematicians know that's way too complicated. There is a much simpler way. And it's look, it's a simple definition, but this definition is not actually simple. I think it only looks simple because our brain has already made all these tricks. It has already an elaborate feed of machine learning in our brain. As a child. Did the same thing that I did in my Commodore 64. In the most general case, and mathematicians are mapping on this available intuition of geometry in their brain and think geometry is simple and instead geometry is much more complicated than algebra. There is an underlying algebra in our brain that is producing the geometry. And so when we think about how we are manipulating stuff in space, it's nothing that is instantly given. It's not the way in which the universe works. It is a model that our brain has constructed and that we it's a black box to us and which we point at. And if you want to disassemble this black box, we need to build computer games and then build a game engine and realize, oh, our brain is in many ways very similar to such a game engine, but it's a self-organizing one that in some sense does inverse rendering. So it's basically building a game engine that is trying to explain your sensory data so your sensory data are constrained. The constraints that determine the state of this game engine. And I think this is the main of which are perception works. Yeah. Because you actually said that our emotion consists of an intelligent generator, the outer mind and an intelligent interpreter, the self and both our adaptive learning systems and they might be incompatible. Why is that? So there are several ways in which you could implement an agent. If you have an agent that needs to satisfy many demands to stay in the universe, to stay alive, to persist itself like we do, we need a lot of different nutrients, and we need to rest. And we need to build social relationships because we are actually multigenerational agents that also cannot exist entirely by themselves. We also state building agents. So we need to model all these relationships as needs. And we have evolutionary priors that make it easier for us to figure out what those needs are, because we basically can take these as suggestions to start with and only need to modify them and they don't work. And then we need to build a control model that allows us to perform actions in the world, to measure all those needs and translate them into representations to us that we can deal with and operate on. We experience them as urges, as drives, and then we model these drives as purposes as things that we actually have to do in the world. And then we try to build a hierarchy of our purposes that we are serving, and that we can communicate to each other and to ourselves, and that in many ways in which this can be built can straightforward encode this. But it's an interesting way in which it seems to be built in our mind. And as we seem to have two models similar to the Gan, that's generative adversarial neural network, where you have a generator and a critic, there is something in our mind that is generating a world model, and it's also generating our emotions and a model of and our motivation as our alignment to the world. And then there is a self model that is a model of what if, what it would be like if there was a person that cared about having these emotions and cared about having all these problems, and that model itself is being tasked with finding solutions to satisfy the needs that the system has before created. And so we have this bipartite model. We have these two parts. We have on the one hand a word model and on the other hand a self model. And we are the self model right. We perceive ourselves as embedded into this game engine, as a character that has to solve the problem that the game is giving it, and we perceive a score that is computed outside of the self as a multi-dimensional problem that is projected into our self as emotions and motivation, to which we have an unconditional involuntary reaction. And we can see that this is the case by disassembling this, by meditating so long that it becomes transparent to us and we realize, oh my God, this is just a representation and they don't actually have an urge. It's just a model of a self that is having that reaction. But I'm not actually that. I don't have to be that. And you can see it from the outside.

1.4 Reinterpreting Concepts of God and Animism in Information Processing Terms
You said something very interesting a while ago, which was that, you know, agency is about predicting the future. And something was ringing in my mind. It's about controlling the future, you said. And my mind was ringing saying, no controlling the environment in the future. But you didn't say the word environment and you were talking about abstractions just now. So, you know, geometry and we learn more and more representative abstractions. But coming back to what you were just saying about, you know, we have we have a self and then we have a kind of outer model. Are they two parts of the same whole? Like does the world exist? Basically the thing is you are part of your own environment. So in many ways, the environment of your consciousness is also the agent that your consciousness is interacting with and serving. Right. So there is in a sense there is only environment. There is nothing else that you could control by virtue of being able to observe and manipulate it. Something becomes environment, right? But it's not the physical environment. It's the environment that is represented in your mind as accessible to you. So you're always dealing with a representation. And some of these representations are causal pattern. They basically similar to computer programs. There are things that are represented in such a way that they can be used to control what an organism is doing, but they're not primal forces in the universe. If you look down, they're still just activation patterns between words or messages that are being passed between cells. That then lead to lots of actions at the cellular level that can, or below the cellular level inside of the cell, that over very large scales can be integrated. If you squint very hard and zoom out very hard, it looks as if an organism is doing something right. But this entire organism is also a fiction. It's an as if it's something as if all these cells would behave animated by the same idea, but the same goals. And because that is very useful, that's also largely what they approximate. And of course, we realize it's an approximation, but it's not a bad approximation. And for as long as we can maintain this approximation for that long, we say there is an organism and not just a bunch of cells that are falling apart. But what's more real are the animating patterns more real than the what we think of as the physical world? Well, they're real to the degree that they're implemented. And so there is a structure in our organism that implements coordinated behavior across the cells, and that gives rise to what we call the organism. The organism is not actually a physical thing. It is a function that is describes the interaction between cells to the degree that they are coherent. Well, now's a good time to talk about your cyber animism talk. I watched your keynote yesterday at the at the AGI 24 conference. Now. Animism is this idea that, you know, systems that are living have a kind of soul or a spiritual essence which gives them agency and consciousness, almost as if we are just vessels which become animated with some kind of vital force. And of course, you've in, you reinterpreted this in an information processing kind of way. Is that fair? I mean, would you mind bringing it in? I find often that we have difficulty to understand the concept properly. If we try to translate it into what we already believe to be true. And so, for instance, if you are, say, an atheist and a Christian tells you about God, and you take the mythology of Christian laypeople, that gods are supernatural beings that are in the habit of creating physical universes. You might think this is a propositional belief that this person has, and it's a confused belief because there can be no epistemology, no theory of right and wrong from which this data can be derived. What would an experiment look like that tests whether something like this has actually happened? And so if somebody makes such a claim, they cannot have evidence to support that claim. And so they're confused. And as a result, atheists might think that concept of a god is a superstition and everything that the person reports about this God, maybe they're talking to angels, or maybe the experience that God gives meaning to their life, or that God loves them and so on is clearly a confusion or a superstition. But I think that's just the result of us mistranslating a concept, and is not helped by the fact that the other person is not able to articulate the concept in a language that makes sense to us. But if we observe that the other person is intelligent and is not delusional, then you might notice that there is something that we are mistranslating. And so, for instance, I think God is a representation in the mind in the same way as the self is a representation in the mind. Once I realize that I am in a story that my brain is telling itself in such a way that I can hear my inner monologue, my self can utter a voice in my mind that I'm hearing right. Why should a God not be able to do the same thing right? Why should there only be one story in my mind? And there are apparently people which have other genetic stories in their mind that get synchronized about across larger groups of people, just not a single self. And so gods are simply selves that are distributed across multiple minds. And when somebody reports that they are, um, that God is present to them, they are describing a psychological condition that is basically described, the presence of this other agent in their mind. And they can interact into this agent and observe it to some degree. And the same thing with animism. My first interaction with the idea of animism that I remember was quite young. Somebody explained to me that people in Japan and other animal cultures believe that everything in the universe is conscious in their life. And my reaction was this bullshit, because I am pretty sure that people in Japan have a concept of a person being dead and another person being unconscious, for instance, if they get anesthesia, and so they will probably not say everything in the universe is conscious in the life except for a dead person or an unconscious person. So you just mistranslated the term into something that you think you know what it means, But they mean something different with conscious in their life than you do, right? It's clearly not the same thing that we use in our culture. So maybe it's a more complicated concept. Maybe it's something like it's dynamic or it is something that is self-sustaining, right? It's difficult to have such words in our culture. We came up at some point with Autopoiesis for a self-sustaining system, and nobody does really know what that means. But in between, nobody had this concept of a self-sustaining pattern. It is a causal structure that is not entirely physical, right? But once you understand the existence of causal patterns, that is themselves not physical objects, but software, and some of these might be self-sustaining, self-reinforcing, right? You can certainly make sense of these concepts. And you realize, oh, maybe this is what they actually meant all along. Maybe it was never a superstition because it is literally what they are saying. If you are able to map it into something that you understand. And so I think the difficulty is that our own culture is stupid, that it lacks the correct metaphysics to describe certain classes of objects and certain invariances in the world. And, for instance, we might not be able to distinguish psychological objects from physical objects. And so, for instance, some philosophers are confused about the notion of free will because they think of will as an object that is comparable to, say, a photon or a bench. Right? And that's not right. A bench is an affordance that you have that you can sit on, and that is part of your game engine. But will is a representation of a psychological state. And so when you think about free will, you have to think about the modifier that is applied to that particular kind of representation, not to some condition in the physical universe. And it's not easy to understand once you see it. But a lot of the discussion about free will is about category errors.

1.5 Animism and Evolution as Competition Between Software Agents
It makes a lot of sense to me when I first saw your talk, and it is a very interesting interpretation of of that animism philosophy. And I just realized, I mean, I read a book called The Language Game by Morten Christiansen and Nick Chaytor. And that was talking about, you know, kind of virtual agents, you know, um, memetics because language is a symbiotic organism, um, that parasitizes us. And I'm a big fan of externalism as well, you know, so these, these memetic agential virtual structures are floating around there in the infosphere, and they parasitize us and they animate us. Yes. It's exactly the same as what you're saying. So that makes sense to me. Yes. And it's basically the same idea. Yeah. So I think it's quite clear that with the language of modern cognitive science, there is software running on our brains, and the software that is running on our brains is giving us the ability to make decisions, to observe, to recall memories and so on. And this is software that is being formed. And artificial intelligence, despite using different abstractions and different substrates, uses these concepts to produce behavior that arguably is in many directions already quite similar, even though it is not emerging in the same way. It does not have the same self-organizing abilities, but the idea that the spirit is a particular class of software, that it's an agent that has the ability to implement itself on a substrate that is suitable for it, that can itself can be entrained with that agent. And it's a software that is able to control this region of the physical universe that it entrains itself with to some degree, and it's able to perceive itself. That's an interesting properties, right? So something that's able to make models of the environment to such a degree that given enough resources, it's going to discover itself in the interaction with the environment as an agent and uses this to make its model more sophisticated. These are all properties that our ancestors assign to spirits, and it's something that we, as cognitive scientists and AI researchers discover as existing, obviously, in nature. And then we notice it's not just in our brains, it's also in our bodies. And once we make the step to realize that thing that makes a cell, a cell is not just a bunch of mechanisms that, for some magical reasons, happen to work all the time. It's actually a software that is running on the cell that is so powerful that it's able to control individual molecules sometimes in a cell, not via magic, but because of the mechanisms that are being leveraged by the software. But the software is basically in training itself on the hardware. It's recruiting hardware in a self-organizing fashion to enact the software. And so there are in some sense two sides of the same coin, but the actual invariance is maybe not the mechanism, it's maybe not the physical thing, but it's the causal pattern. It's actually the software in the same way as money is an invariance that doesn't really care what you print it on, as long as it's being printed on something that can serve to implement money. And I guess a similar thing is happening in our own mind. Our mind is somewhat robust against an individual neuron dying. It's just going to recruit a new neuron. So over a quite large range of states, our mind is going to still be functional. It's only when the mechanisms leave a certain range that you can no longer compensate for. When you no longer compensate for the errors and the noise in the environment and your substrate, then you fall apart and the software crashes and dies and other software goes in. But this also means that when you look at the living world around us, it's full of these software agents that are competing about regions and physics that can be substrates for it. There are thoughts in our mind that compete for our brain matter, and there are ideas that compete for groups of people, and there are organisms that compete for regions in which they can build new cells and, and train them with the patterns and the colonies of the organisms. So you see all these spirits acting in nature, and then you look at the way in which Japanese people, for instance, conceptualize animism and you realize, yeah, they are realizing that there are layers of this. For instance, humanity itself is a spirit, a society is a civilization is also some form of a spirit. A relationship is also a spirit. So in a sense, you could say the animated universe. This universe that is interesting. Intelligent control structure is the result of self-organizing software agents. And if that is the claim of animism, that's an actually very insightful claim, and it's one that we are beginning to understand. We are still focused on the mechanism. And so Darwin says evolution is the competition between species. And then Darwin seems to make the next step and says, no, it's actually the competition between certain molecules that give rise to something that looks like species to us when you coarse grain it. And these are the genes, right? So it's actually about the gene. But the animist perspective gives it was one step further and says no, evolution is the competition between different software agents that can reproduce and can code themselves and use the molecules to encode themselves, and they use the mechanism to implement themselves and perpetuate themselves and compete. But it's actually all about software. It's all about spirits. And so it's a physicalist perspective. It's nothing superstitious, nothing magical, nothing woo in there. It's just a way to reframe what we are observing in a way that makes more sense. Yeah, well, it's a kind of stance because there's a hierarchy of mimesis.

2.1 Consciousness as self-organizing software
I mean, I gave the language example that that's, you know, the highest level. And then as you say, you can go down a step and you can go to evolution, which is about the, the competition of physical forms and their evolution. And, you know, Dawkins was talking about the gene and you're talking about the software, the software agents, or you can call them spirits that compete with each other. But the thing is the software agents, they need to find a host. And the interesting thing is that they might be doing some kind of meta optimization because this ladder of mimesis is entangled. So so they might be selecting their host based on meta optimizing the, the the language mimetic, if that makes sense. Well, it's not just that nature is growing a body for you. And then the spirit moves in and possesses that body. But what's happening is that there is some software that is organizing a bunch of cells into becoming a body and that is already a spirit, right? It's a self-organizing thing that is producing the architecture of your body. And so you could say an emergent phenomenon, but there is no magic involved, right? It's really just a self-organizing software that manifests by producing the architecture of that body that then produces complex behavior that implements more complex spirit. Right. But then once I had this insight that what our ancestors meant with spirit is exactly self-organizing software agent, my mind was blown. And then the next step, when you realize living nature is actually all about software, it's all about control structure. And the actual invariance is not the molecules or the connection between the molecules or some patterns in the molecules, but it's actually the causal structure itself, the software. I realized, oh, nature is healing. We are able to put different worldviews together in a way that is not superstitious. And they make more sense now, because we now can use our scientific worldview to make sense of a bunch of concepts that are difficult to explain so far, and where we felt that our ancestors had, for some funny reason, veered. Yes. What we noticed is that animism is not a perspective that only exists in some regions in rural Japan. It's also a position that existed in Europe before Christianity came along. And even during Christianity, it's something that only stopped with the enlightenment. It still exists in Scandinavia. It basically exists everywhere. People are living inside of forests. So consciousness as software, I mean, we should bring in consciousness. So there's a kind of competition between these software agents. They they find hosts. And you said consciousness is a virtual property of this pattern of self-organization. And you said it is second order perception. What do you mean by that? A lot of people try to avoid the notion of consciousness, and it has multiple reasons. One is that they feel it's too many people have different opinions about what it is. They also there is very little upside in discussing consciousness, because there are very few decent research programs for it. Within science, very few people look at it because neuroscience don't know, doesn't know how to make progress on it. I doesn't really look at it. Psychology is not looking at it. So all the people that talk about consciousness tend to almost all of them tend to be outside of science. And people outside of science don't have very good epistemology for the most part, and not proper formal education. So the way in which they make their arguments typically doesn't scale and doesn't hold up in the eyes of scientific methodology. And so people don't want to be drawn into this. On the other hand, it's consciousness is something that we are all confronted with. And for a lot of us, it is not just significant, but also mysterious. But the significance of consciousness is something that seems to be undeniable. And so when we ask ourselves, what is it that we mean by it? When we look at consciousness, I would say that there are two features that spring to our attention. That is what we mean when we point at what we mean with consciousness in ourselves. One is that we are experiencing and this nature of experience is not just content is present. It's not like it's insufficient that you build a camera sensor that registers photons, or you build a machine learning system that is discovering patterns in the activations of the camera sensor. That is insufficient. Nothing experiencing here. What does it mean? The experience goes a step further. It basically registers that something is registering it. Something notices that something else is noticing. So it's not just the presence of the content, it's the registration that this content is present. And this is not an inference that you do logically with some symbolic reasoning. A few steps remote, but it happens in the moment or entangled immediately in this process. So it happens in near real time. It happens at the perceptual level. So it's not reasoning, it's perception. It's this immediate thing that happens in the coupling with the perceptual process that brings you in contact with the environment and your internal state. And so it's it's not cognition. It's perception, and it's not perception directly of a content, but it's the perception of the perception. And that's why it's the second order perception. That's what I mean by that. See the other aspect is when you ask yourself where is consciousness? That's a category of software. It's not in space, right? It's just a modeling a space as a content. But by itself, it can be also implemented in a region of the physical universe. But where it happens is is not the right question. When does it happen? It always happens. Now that's a really interesting feature of consciousness that it's never in the past, never in the future, and never not now. It's always now. And so consciousness seems to be this bubble of nowness and or inhabit this bubbles of nowness, depending on how you use the term. And in this bubble of nowness, you have the things that are currently the case in your perceptual system. So it's a particular state of your mental game engine that's tracking sensory perception, and it's the operators that you are using to change your ideas and thoughts. So when you are reasoning, your thoughts are not necessarily about the now, but you're thinking that's what's happening now. When you manipulate your own thoughts, you observe yourself doing that. It's an interaction that's happening in the environment. It's also in this knowingness. And the knowingness is not an instant in time. It's not a point on a timeline. It's a region. It's a region in which you can fit a curve to your perception, so to speak. It's a region that's slightly dynamic. You see a small movement, a handshake, an eyeblink, something like that, something that fits into this window of our attention, of a moving, dynamic environment. And the bubble of nouns can be larger or smaller, depending on how much we are in sync with the environment, how calm we are, how much we can integrate into this bubble. And it seems to be the bubble that is completely devoid of contradictions. The stuff that has contradictions cannot be seen, not be perceived because it makes no sense. So it might be that there is some kind of constraint propagation that goes back and forth. So our working memory and the region that we can integrate into this bubble, this is the content of our consciousness. And so maybe consciousness is the operator that performs that. And there is some overlap to for instance Tononi's integrated integration theory, which I think is formally not a very good theory, but the intuition that underlies it, that consciousness is about the integration of contents, I think is sound. And this is something that also makes sense from the perspective of a machine learning engineer that thinks about how does a self-organizing system process information. And maybe it does this by producing this bubble of nouns, and it does this by resolving contradictions in your sensory apparatus. And it starts out by observing the observer itself. And it's basically the first stage that you ram into the ground to establish something that has no contradictions. Once you notice there is an observer, it is cogito ergo sum. You can branch out to try to explain the rest. And you don't do this logically. It's just what you do experientially. It's what's happening in some sense. When you observe ourselves as observers that start making sense.

2.2 Critique of panpsychism and alternative views on consciousness
It's quite similar to Stephen Wolfram's observer theory, and he spoke about this cone of an intelligible cognitive horizon which is intelligible to us as, as in a computationally bounded observer's. But the thing is, we're talking about perception, and most people have an idea of what perception means because they think about it in terms of our sensory perception. But am I right in thinking that you're talking about a kind of perception between the software agents in this mimetic space? No. I think that the idea that there are other agents is an idea that I form in my mind. I don't have access to your internal states. What I observe is there seems to be an agent that has a similar makeup as myself. And so I assume that you are functioning in very much the same way and then can communicate about the reality that's shared, and I assume that our brains are naturally converging in many regions to similar models. So we communicate by forming pointers in the architecture that we hope is similar in your mind. And then in some regions we find that there are differences. And this is why we discuss philosophy. Interesting. So consciousness is a virtual property of the hosts, not the software agents. No, it is a software property. The host is a concept that the software is making about its substrate. But you cannot know whether I'm running on a GPU or in a human body. It's I'm just observing that there is something that I can interpret as a human body. And my best models that I can come up with is that I'm actually running on that human body. Right. But I cannot actually know this. It's just a model that I'm making. And so this concept of host is a part of a model that I'm making. It's nothing that is immediately given. The only thing that I can infer is some necessity, that there seems to be something that's able to host me. Right. There is a substrate that makes it possible for these representations to play out. To what extent does it make sense to say that consciousness is universal? I mean, I recently had Philip Goff on and he's a fan of panpsychism and Cosmo Psychism. But in your worldview, how universal is consciousness? I don't really know how to make sense of panpsychism, because the idea that matter itself is conscious. If I try to formalize this, I don't really know what that means. So is this everything in the universe equally conscious? Is consciousness equally distributed? Does this mean that everything in the universe behaves the same with respect to forming representations of itself and experiencing those representations? Probably not. Why would you make such a claim? It would be pretty complicated to implement and it does not explain any observables. There is no mechanism that would bring it into existence. It doesn't make anything easier. So I suspect the reason why people are sometimes panpsychists is not the result of them thinking very hard about physics and consciousness, but it's more an experiential thing. And I think it happens because in our normal state, as adults, we have a self, a personal self that we normally perceive as the agent of consciousness. So it's basically the thing that gives us this human first person perspective. And when you meditate very much, or when you are using psychedelics in large doses, some people report that this, that they dissociate also sometimes happens in clinical cases where they basically depersonalize and the consciousness is no longer attached to this personal self, because after all, the idea that this representation of of what we would be if there was a person is a trick that your brain is producing and associating your conscious perceptions observer to that thing is a sleight of hand. And if we are able to dissolve the sleight of hand by changing the neurochemistry of our brain, or meditating so much that we figure out how it actually works, we basically realize that our consciousness is somewhat independent. And so what's happening then to our consciousness? And it seems we can bind it to other objects. And if we don't do that, it might bind itself to the entirety of our model. So our model of the of reality to our universe. And suddenly, subjectively, people who meditate or use LSD get into a state where they realize, oh my God, everything is conscious. And it has always been, why didn't I notice? And this gets translated into panpsychism, but it's a category error because what got conscious? Are there representations? It's not the physical universe. It's not that suddenly they discover that quantum mechanics and particles and whatnot is conscious. No, there are ideas of things or idea of what it would be like to be a photon, or the idea of what it would be like to be a cell gets instantiated in the mind as a dream and think about it, and they experience that thing as a conscious agent that is basically having a first person perspective, but is now a first self perspective or a first photon perspective, and it can be even multiple looking at each other simultaneously. And when such a thing is happening, it's probably pretty mind blowing and can confuse a lot of people until they figure out no, it's just a mental representation. It's a dream. What does this dream signify?

2.3 Emergence of consciousness in complex systems
I mean, let me let me try and sketch this out to see if I've understood it correctly. Because by the way, even Philip Goff, even though he thinks that he's also a fan of realism, by the way. So these various ontological ideas that the, the primary substrate of the universe has the kind of the potential for phenomenal and material, um, components. But why would you think that it's basically our idea about the stuff that is below. Particles that we can observe are pretty vague, and even the particles do not seem to require the assumption that they have agency in any way. It's not necessary for a photon to plan ahead. It seems that the photon is able to happily do what it does. If it's far less intelligent than, say, a Roomba, it's a photon is probably just as stupid as a rock. It just follows a very simple mechanism reactively, without planning ahead. It's not an agent. It's not regulating a future state. Instead, it's just implementing an error correcting dynamic on the present state that allows the photon to persist. But it's not doing any more than that. So I personally do not see a reason to assume that the photon has any kind of representation, that it will, that it solves any kind of complicated control problem that would require that thing to build a representation in a model of its environment. And so I would be very hesitant to go in and assume that it does. Instead, it makes much more sense to think that systems that are so complicated that they can make models of reality, learn how to read and learn how to use an inner voice or want something, or reflect on the puzzling nature of their consciousness. A system that are compositional, that are made of much smaller, more primitive parts that don't have that ability and implemented step by step. And it seems to be also what we are observing. Did I get it right, though, that that Goff and Chalmers think that there is an ontological potential for phenomenal experiences given certain organizations of information in the case of Chalmers, or material in the case of Goff. But but you're saying given certain types of organization, then there's a memetic software sharing, which itself gives rise to consciousness. The reason why we are conscious seems to be that we care at some level.

2.4 Neuronal motivation and the origins of consciousness
I notice when I introspectively when I meditate, I can resolve my motivations. And so when I go to this state where I stop caring about anything in the world but aesthetics, I feel that I am an unmoving observer that is just looking at the world and looks for patterns. And if I resolve my interest in aesthetics and structure, if I stop subjectively paying my neurons to look for structure in the world become super lazy and they just space out and fall asleep, everything becomes fuzzy. And because there's no point anymore, right? So at some level, you actually care about understanding the universe, reflecting it, and that gets translated into an impulse to the neurons to please perform this activity. So we get a useful model out of you. If you stop doing it, it's not going to happen. And the reason why we are able to pay our neurons for performing this task is because we can feed them better if they make models of reality, because we're able to navigate our trajectory through the universe in such a way that we can find food to give to the neurons eventually. And so this is how it all works. Ultimately, it's about energy. And so the reason why we are conscious and have all this organization is because there is a benefit in building controlled reactors. And every reactor, every kind of chemical reactions that happens in nature is exploiting some negentropy gradient. And intelligence and consciousness allow organisms to exploit more complicated negentropy gradients, more complicated chemical reaction chains. And so if you ask yourself which things in the universe have the potential to build minds, it means they have to be able to benefit from that organization so that organization can come into existence and persist, right? Otherwise, it wouldn't happen. And you also need a way to evolve that organization. So you need to have some structural degree of freedom and a certain probability that such a structure emerges in the first place. And so in this sense, I think it's conceivable, even though it's a stretch to imagine that maybe on Jupiter you have an intelligent structure. Imagine you have storm systems on Jupiter that exist over millions of years, and they rotate and they produce magnetic fields because some of the clouds are metallic, and some of these metallic clouds react differently to those fields and others because they have different metals and different concentrations. And the whole thing is driven by tidal dynamics. And maybe it gives rise to feedback loops. That ultimately leads to Jupiter waking up, basically the cloud systems on Jupiter. But I wouldn't know why this is happening in a single rock, which is just sitting there and is not producing internal dynamics that do anything interesting. And I don't see how the rock would be able to exploit some internal negentropy gradient, and so I would be very reluctant to assume that the rock is able to produce that structure. But over billions of years, maybe in the mantle of the Earth, maybe there you have something interesting going on. Who knows? There are some versions of animism who also have this idea that maybe the universe itself, in the sense of the physical universe, is something like an organism. It's something that wants something or it has a certain structure. Maybe this is the case. Maybe flat space to have particles in is not something that happens naturally by itself. Maybe something bulldozed at first into this, this shape. Who knows? I don't think it's likely. I think it's more likely that we find a way to derive that the universe that we're observing is the result of a tautology, some kind of fractal that emerges by itself in base reality, right? If not, then maybe it only exists in a corner where you have something that actually wanted something to happen. It's unlikely. Right? The fact that the religion says. That doesn't make it more likely because people just say things, especially if it impresses other people. But if you think about means and motive, if something comes into existence and why, I don't see a reason to assume that the lowest levels of reality or the levels below particle physics or the particles themselves, or anything that is simpler than a cell is running self-organizing software agents.

2.5 Coherence and Self-Organization in AI Systems
Yeah. So, um, patterns of physical dynamics are a necessary condition in order for those things to become hosts of these software agents. But you've also spoken about, you know, this kind of coherence mechanism. I mean, could you could you sketch that out? Yes. So when we think about in which way does software work in a computer, we notice that it works because we force the computer to do it. We basically build a substrate that is almost completely deterministic, and we can fully control it. And by building such a substrate, for instance, a GPU, we can implement a starting state on their GPU that leads to a necessary sequence of steps that are enacted with an extremely high reliability. And so we basically can do that thing. Do whatever you want. We can play Call of Duty on the GPU, and it has no choice but to enact that. But if you want to imagine Call of Duty on your own mind, or want to create a fantasy of a better world or, uh, any kind of interesting dream, how do you do that?

3.1 Second-Order Software and Complex Mental Processes
You need to basically get something that is a second order software that is designing itself. You need to implement something that is growing into the right shape. And the same way as you want to have a tree, you cannot just go into nature and build a tree. You need to build something that wants to grow into a tree. You need to have something like a seedling. And initially it's maybe just a single cell that is creating a group of cells that then interacts in such a way that it creates a seedling that ultimately becomes a tree. So everything in the universe is basically a higher order design that requires multiple level levels of genesis before it turns into the shape that is realizing the function that you are eventually observing. And that's also true for our own mind. And so if you ask yourself, what are these principles of self-organization, it seems that an important one is coherence. Coherence basically means that the system is behaving as if it could be described by a single function, by a single goal, by a single behavior. And we observe this, for instance, in our own mental development, when we are very young, we might have very different conflicting impulses and different thoughts, different goals. And the older we get and the smarter we get, the more we integrate them with each other, which means we build them into some kind of conditional hierarchy where every behavior has its place and understands what its role is and when to shut up. The same thing happens in a good relationship or in a society and so on. And it's the more coherent it is, the less friction it has, because it behaves as if it was a single agent with high internal structural complexity. And so can we formalize this coherence principle that would allow a system to design itself from the inside out? And I think we can capture it as the minimization of constraint violations. So a constraint is basically something that says if something is like this, then the other things must be one of the following and none of those. And once you have a valid state and the thing is coherent, why does the world seem so incoherent though? Is it because we just don't understand the coherence function? No, it's because there is only partial coherence, and our own consciousness is directed on the things that are incoherent so we can fix them. And that seems to be the role of consciousness. It's like a conductor in an orchestra that listens to instruments, and when the instruments are out of sync, the orchestra, the conductor marches in and says, look, you go up a little bit, you go down a little bit, and then it works. And so everything is on the same page. And maybe this is also the role of consciousness in our own mind, that it basically focuses on those things that are disharmonic where there are conflicts and then tries to resolve them. So your work suggests that there's a kind of continuum of consciousness. And of course, to varying degrees, even in the ecosystems on the planet. I'm not sure if you're familiar with James Lovelock's Gaia theory, and that really captivated me when I was younger. He kind of thinks of the all of the earth as being this kind of living, self-regulating organism. And what are your thoughts on that? So most agents are collective agents. You could also say that all intelligence, because it's not manifesting at the level of individual particles and individual molecules or even individual cells, is the result of them interacting in a coherent way as a collective. Basically, every agent of with a certain complexity is a collective agent. It's made out of sub agents that perform this behavior together by becoming coherent.

3.2 Collective Agency and Shared Values in AI
And so in this sense, coherence is a principle that gives rise to agency on the next level. And when people become coherent with each other, then they can create relationships with each other family units, teams, organizations, nation states, civilizations. And so all these are collective agents that you can say that a civilization is a collective agent that is made out of all the subagents, and it's implemented to the degree that these subagents realize that this other thing should exist, should be collectively enacted, and become coherent. And it only exists to the degree that it can come coherent. But the prerequisite for becoming coherent is that they recognize that there should be regulation at this level. And so if you now think about Gaia. Gaia would be a collective agent that is regulating at the level of life on Earth and other agents on on Earth that think that regulation should happen at the level of life on Earth. Probably. Right? There are a few people at least, maybe also some ecosystems who knows, that are able to form models at this level. So I would say that Gaia exists to a non-zero degree, but it's probably very incoherent. Do you think that agency can be hierarchically factorized? And the reason I say that is, to me, having a distribution of agency would lead to incoherence, because agents are trying to control the environment, and it's an adversarial thing. But am I just thinking about it wrong? Is there actually some super agent which could be thought of as coherent? There are sometimes competing agents with conflicting goals, and this leads to incoherence. There is an agent that wants to eat another agent, and the other agent doesn't want to be eaten, and leads to some kind of conflict and loss of energy because one agent is trying to escape from the other. Right. But if they were all on the same side, they will figure out what the right solution is. So basically, if my family is traveling with an airplane on a snowy mountaintop, my family will first eat me and then my wife, right? And it's something that in some sense we would more or less peacefully agree on. In an ideal case, as a gruesome metaphor, because we realized that this is the goal that we are submitting on as a family unit, right. So the existence of the parents is instrumental to the existence of the children when you are a parent. For most parents, it's like that, I think. And so when when you have such a world and it becomes harmonic, it becomes harmonic to the degree that the agents perceive themselves as being part of a larger agent that is more important than their personal agency. And so we call this because you're willing to sacrifice for it sacredness. And basically the sacred shared sacredness leads to collective agency. Our friend Connor Leahy talks a lot about coherence in the context of AI alignment. Do you think there's an interesting story there? Um, yes and no. I'm not sure how coherent Conerly's perspective on AI alignment is, because I don't really know how he perceives collective agency. When I tried to talk to him about the way in which we are coordinating, his perspective was that, oh, the only thing I want is I don't want to die and I don't want my mother to die. And there are others who have conflicting interests. And so it's all a fight, basically. And this seems to be the logic of a tapeworm of nothing that is able to see shared purposes and is able to build ethics via a notion of collective agency. I think ultimately, ethics is about what should be done from the perspective of an agency that we are both part of. It requires shared purposes. Without shared purposes you cannot have ethics. And so if you think of AI not as a tool, in which case we don't need to align it in an ethical sense, but we just need to make it behave in such a way that we can properly control it. And that's what we want. If we turn it into something that is agentic in such a way that it has actually choice about its own allegiances, about its own goals and so on. Then the question is, can we build it in such a way that we have shared purposes? I often make the argument that current AI is not agentic, but given your philosophy, I guess you could make the argument that it is. Well, we could say that there is some agentic AI, but it's not universally agentic, and the agentic AI that exists is mostly not happening in the level of systems that are able to solve the Turing test. So if you look at the agents that are created via Llms, they are in some sense deepfakes of agents because their agency is not intrinsically built into the LLM.

3.3 Limitations of Current AI Agents and LLMs
It's a side effect of the LLM trying to predict the next token. And the LLM doesn't do that because it's an agent. It doesn't have a choice about it. It's deterministically built in such a way that it's going to give you the most likely next token. And if that entails pretending that an agent exists, then for as long as that is necessary, it's going to make a simulation of that agent. And that simulation can be good enough to actually act as a stand in for actual agency. It's able to control the future and so on. It's a simulation of a software is still a software, and a simulation of a software agent is going to be a software agent. But the underlying reason of that thing is not that this is going to try to self-optimize and try to survive in the world. The underlying reason is still it's instrumental to predicting the next token, and it sees this once the token is there.

3.4 Liquid AI and Novel Neural Network Architectures
What should you know when it comes to language models? What's your weapon of choice right now? Are you an anthropic guy or a ChatGPT guy? I'm a liquid guy. Liquid AI is a startup that is basically rewriting some of the bottom of the stack. And if you think about the neural networks that we're using, in a way there are a surprisingly crude idea. They're not like biological neurons at all. And the biological neuron is a small animal that tries to survive. It's quite complicated. It's really a single celled animal that is able to learn message passing and then perform computational tasks in the service of a larger group of cells. But the neuron in the neural network is a real number that is the result of summing up other real numbers and multiplying them with weights, right? So it's just sums and multiplications that we arrange into a series of steps. And then when we make a model we predefine the shape of of this function. We for instance, say we have 100 layers, which means we have 100 steps of adding up. And each of those layers has maybe a million weights, which means we make a million multiplications of individual values on the previous layer and propagate them to the next. And then we adjust the weights in the hope that our function fits into this thing. So it's not an optimal use of space, because the space is can be an arbitrary function. And in context of deep learning we look at the differentiable function. So we express the function in such a way that it's somewhat continuous, and this allows us to shift the function around, and that makes the whole thing learnable. We basically hope that in many domains we can define it so that small nudges in the function make it slightly better at, for instance, telling dogs from cats, even though this is a discontinuous problem. It's amazing that this works at all when you think about it, but it's it's not the best way in which you could represent such a differentiable function. Maybe you want to represent it directly as a system of differential equations, and then shift the parameters around with a second level learning system. And so this is things that liquid AI is exploring. And by now it works. And the initial work that we did with liquid neural networks was flying drones around. So in some sense cybernetic control tasks and showing that this works pretty well. And Ramin Hasani in his PhD has shown that these liquid neural networks are more expressive than normal. Neural networks basically means that per memory cell, per compute step, you are expressing more of the features that you actually care about in your function, and that translates into having models that are cheaper to train and more efficient to run, and they need less memory. And the thing that we are doing now is that we are training this thing to build LMS, and now we basically have built internally some mid-sized models that we can show actually quite efficient and run at Sota. So these methods basically can supplement some of the existing machine learning methods with slightly more intelligent algorithms. But there is a lot of potential that we are not using yet. For instance, because these liquid neural networks have a continuous steps and a continuous resolution, they basically flow into the shape of the function that you need. And this means you could, in principle, build systems that continuously learn rather than being just trained on one batch of images, and then you retrain them at a later point from scratch. Instead, you could continuously train them. But there are, of course, difficulties that come with this when you need to edit your knowledge in such a way that this thing doesn't break down. And so there's a lot of research that we still need to do, but this makes it very exciting because it feels that we basically open up a fresh avenue of research.

3.5 AI Model Efficiency and Future Directions
Yeah, because in a way, I mean, Francois said to me earlier that one thing he was wrong about is that it's surprising how good stochastic gradient descent has worked. But but we still have this paradigm where we're doing back propagation and the networks are very dense, and we're training them left to right. And I was really interested in the work that that liquid is doing. So you built these very, very small models. They're very robust. They're much more sample efficient. Do I remember correctly that their kind of physics inspired. So they're learning about the the evolution of parameters over time rather than the current kind of left right neural networks? You could say so. But also physics if you want, is actually physics. A lot of people think of physics. It's discovering the structure of the universe. But if you look at what physics PhDs are actually doing, almost none of them end up working on discovering the structure of the universe. Instead, what physics is, it is describing systems using small systems of differential equations. So it's a particular way to use short algebraic stuff to describe systems that can be described in this way. And so stuff that cannot be described in this way is completely ignored by physicists. For instance chemistry. Right. It's difficult to do chemistry this way because at some point we will get around to it to translate the stuff that underlies the table of elements into differential equations, and they fall out of it. But until then, we leave this to lesser people, to these chemists who deal with this messy stuff, and instead we have this elegant, compact stuff. Right? And it's pretty weird when you think about this, this continuous mathematics that physicists are using is basically pretty good stuff from one and a half centuries ago. Basically checked out this code base from the mathematicians. And it's very versatile. So when you take a physicist, they are able to describe changes in dynamical systems very well and can reason very well about this. But I also found when I got physics students to write code for me, they often try to translate the code into differential equations first, and this happens to be extremely useful for most of machine learning. So the physics approach is very good as an inspiration for machine learning, but it's not generally a good approach for doing coding, because there are a lot of problems that are actually discrete discrete automata. And physicists don't think in terms of discrete automata. There is also, when you zoom out a little bit, the question. Shouldn't we build machine learning on top of discrete automata rather than linear algebra? Because if you think about the stack of our computers, you use a CPU that is or a GPU that is an automaton, right? You have a boolean table that you are where you're mapping bit arrangements against other bit arrangements, and you implement this pretty directly as circuits, and then you build a logical language on top that uses these patterns to as if they were evaluations of logic. And then you build arithmetic and so on and at some level of abstraction you get to linear algebra. Then you train your neural network off it, and then you train that thing to do logic again. That's pretty weird, right? What if what if we would start at the bottom of the stack? It takes humans less than half a generation to go from automata to building linear algebra and computer. Computer science is not an old discipline. And so imagine that you build a machine learning system at the bottom using automata. That would be quite interesting. And a few people would do that. But of course our learning algorithms right now depend on differentiability. And so it makes sense to use a more direct inspiration from physics rather than the ideas from the perceptron, only to build our machine learning systems. How would that look like? You know, if you if you were implementing a large language model because it's still a self-supervised training objective? I mean, how would you model something like that? You pretty much do it in the same way as before, which means we have data that allow us to tell the system whether it was successful to predict the next token. So you can use the. Same training regime and you can use the same batches and you extract the. Same information out of the data but using slightly different formalism to. Represent your function. You can map it into something that is slightly more efficient. So basically your computer needs to use fewer cycles to manipulate bits that represent the same function distributed slightly different on the same substrate. So in some sense it's a mapping. It's a compilation into a slightly different formalism. And so the interesting feature about computer programming languages, all programming languages have the same power. They do exactly the same thing. They all let the computer do the same thing. The difference between programming languages is that it allows us to think differently about what the computer should be doing. So from the perspective of one who makes a model of what the computer should be doing, the language make a very big difference. And you can think of the an LLM as something like a language that is compiling natural language into code that the computer can run. So you can just give it a prompt, and the prompt is being translated by the LLM into a computer program that can be represented as a 100 layer neural network, or implemented as activations in that neural. Layer neural network. And you pipe the activations through and as a result it performs a certain behavior. And if you are representing this function in a slightly more efficient way, then you maybe need less memory. And what we currently see is there is a big bottleneck with the Llms and we are running against that bottleneck. And that is basically every generation of models is more expensive to train and requires more data, and they are still more useful and so on. But we also see that with every generation, it might be harder to recoup the cost of training them, because you need to create a lot of revenue to make that whole thing worthwhile. And from the total perspective, if you zoom out, it makes a lot of sense because if you are able to build AGI, it will completely transform our economy. It will unlock tremendous amount of value. And so putting a few billion dollars or even \$1 trillion into training models might be totally worth it. But that is not necessarily the case for startup, right? If you, as a startup are putting a few billion dollars into training a model, then you need to have extremely good business development to actually find business cases that create enough revenue so you can recoup this investment. And a lot of people are bracing for a time, a second dotcom bubble where there was a situation where everybody was banking on the internet generating retail revenue and whatnot, and was investing into the development of the internet, and then it took like 3 to 5 years longer than everybody thought. And there were tears. Right? And it was a big dotcom bust. And everybody lost their hope in the internet. And of course, the stock market recovered and these companies came back. Those that have survived and the internet became much more beautiful than anybody ever anticipated, and much more lucrative and useful. But still, there was this time in between, when the individual companies could not recoup their investments. And so, of course, this is what you need to think about as somebody who deploys a system. And what we see right now, we want to have systems that are smaller. We want to have systems that can be deployed on the edge locally, on user devices, to unlock all the applications that we want. We cannot send everything to a big data center and process it on a server farm and then get it back. We need to find systems that are smaller and I think the llms are way too big. You're still using this because we don't really know how to compress them in the right way. But there is a certain thing that our own mind can do that is similar to an AI, and that is we basically in one step we create an association and but we don't stop there. We take that association, we criticize it, we construct it. We iteratively go over associations to improve them into the product. In the LM or the image generator is mostly using one step And this is what it does in one step. This one step association is mind blowing. It's far beyond what a human mind can do in one step, even if that one step is 100 layer function and implement neural network, right? But we get our performance only by going lots and lots of steps in very clever ways. And so I think there is going to be a development in this direction that we think about. What's the minimal engine that can do inference. Maybe you don't want to have a model that is trained on everything in the internet. Maybe you just want to have something that's like a very precocious 12 year old. You compress it as much as you can into a shape that it's able to understand the book and understand how to reason from first principles. So if you had such an epistemological engine, a thing that is able to take in data and generate knowledge, right? Ideally even a canonical form, so you can save this knowledge and give it to another model. And that would be great to compare to a task. You give it the library, it reads the library for that task is not going to take long, right? It's going to be half an hour to boot up for this task. And then it translates this into a knowledge base that you can also then ship as a binary to other people if you want to. So this goes even faster. But the model itself, how big is it going to be? We don't know at this point, but I suspect it's going to be much, much smaller than the present. That's interesting. Yeah. I'm not sure if you remember that paper by, um, uh mordvintsev.

3.6 LLM Limitations and Internal State Representation
It was the neural cellular automata, and it was, you know, generating the gecko. But what's so interesting about that is it was Turing complete because it had this iterative component, because we often I think last time we spoke about how neural networks are finite state automata. They do a fixed amount of computation per iteration. There's a lot of computation that's out of bounds. But if I understand correctly, you're building a dramatically sparsified smaller model that has this iterative component and that creates this emergent. You're not doing that yet. So at the moment, what we are doing is still we are working to reproduce Sota using models that are slightly smaller and slightly more efficient for some interesting value of slightly. That is economically interesting, but what I would be interested in the long run about the field is interested in. When you look at the field of AI research, I think will be ultimately what is the smallest engine that is able to make sense of the world? When you are confronted with data, what is the smallest thing that can bootstrap itself efficiently into what you need it to be? And it's going to solve a lot of problems, because ultimately it's not going to be tainted by copyrighted data. It's not going to produce stuff that you don't want to have in your present context. It's going to be exactly focused on the use case that you want it to be in. It's going to be more much more modular and useful. And so if you could get there, that would be great. It's very difficult to make a system that is not Turing complete. It's we shouldn't think of a neural network as a model of a nervous system. Instead, the neural network is a function that is mapping adjacent brain states to each other. And so the transformer weird thing is the brain state of the transformer that we are mapping it to and from is not this intermediate representation that our brain is using. Instead it's text. So imagine you would need to translate your working memory into text. And then the next brain state is computed by taking that text and translating it again into a mental representation that simulates the contents of what you're writing in the text and then going back down. That's obviously not very efficient. And it's also very lossy, because not all of your thoughts can be very well translated in the text, and it's going to limit your performance. So instead what you want to have is you want to represent your thoughts. So for instance, and your idea is and the state of your working memory. And I notice when I'm thinking, I have been thinking so much in English and German that I no longer think in any of those languages. I feel it's more like I think in a conceptual language that is some kind of sub token embedding, so to speak, and then only translate it into English or German when somebody wants to download it into a podcast or into a conversation. And so I observed this model more or less working from the outside. I basically feed a string of subtoken embeddings into my language generator, and the language generator is a tool that doesn't require a lot of attention in relatively quickly parses this into a format of string of discrete symbols that you hopefully understand. And so can we do this with the LLM. And there are more things happening in the research in large companies right now where people are making this much more optimal by representing these internal states and holding them. And now imagine we could turn these internal states of the LLM into a canonical form. So we actually understand what they mean, and we can use them to manipulate knowledge. And that in a way that is similar to manipulating knowledge and language, maybe just a little bit more regular, but it's also can be used to manipulate geometry or abstractions over programming code or causal structure in general. And I think that there are amazing breakthroughs that are waiting. And these breakthroughs are unrelated to the way in which we currently think about scaling or applications of llms or the alignment debates or whatever. There is going to be really exciting research and I feel sometimes people are have the wrong expectation. Personally, I am amazed by everything that I is doing and my mind gets blown every week. But it's also I don't expect AI to perform at a human level. I expect AI to solve problems that I couldn't solve a year ago, or two years ago, or ten years ago, and that we thought would be incredibly hard to solve. And we now see that they can do these things. And so I am quite optimistic about AI is doing, and I don't see obvious limitations of what the stuff is doing. But I also see lots and lots of difficulties to realise that. So I have no proof that a given approach cannot do a certain thing. Unlike Gary Marcus, who seems to have that proofs these proofs. I am seeing opportunities to do things, but I also don't have a certainty that we are going to have AI next week. But we also know there could be. Maybe it's just one paper away, but we really don't know. It's just just by scaling up, we we can predict how long that approach is going to get to a certain level. Not clear if it goes beyond that, but what is the next breakthrough? That's very difficult to anticipate before we get there. Yes. And Gary will be sitting in your chair on Saturday morning. But, you know, one school of thought, though, is that we just need to scale language models. And I think that I really deeply respect people who are willing to go out and say something wrong in public. That's very rare. And it's basically a lot of people prefer to play it safe, because credibility is a currency that is easy to lose. And so when you are saying things that don't come true, like when you are saying to machine learning researchers, deep learning is hitting a wall and deep learning is doing no such thing. You lose all credibility, especially if you do not error. Correct? Right. It's different if you talk to people in New York Times who hate AI for political reasons, and you tell them what they want to hear, then they are going to make you popular, but it's going to kill even more of your credibility among the people who actually build stuff. But Francois is not like that. Francois is somebody who is very arrogant in his beautiful French intellectual way, going all in and saying intelligence is generalization ability, and it is all there is, and shows that the Llms cannot do this. And it's a really bold prediction that he's making, and I think he will be very happy if somebody is going to build an LLM that solves the ARG challenge and is happy to eat his hat, and he is going to stir people into talking back to him and trying to find a solution. So he really has skin in the game, and he puts his hat in the ring by saying, here is a challenge. This is the problem I think that you cannot solve. Go ahead, try solving it and prove me wrong. And this is something that I deeply respect. And he's one of those people who comes out with bold predictions. And he's but he makes these predictions in a way that is challenging people to go out and and show him In which way? He was right and wrong. Right. And he is extremely smart. So his predictions are pretty good and interesting and people are paying attention. But basically just making predictions in one way that are not looking at the alternatives to your prediction and not making an actual argument. That is, that would invalidate what you are saying or retracting when you have been proven wrong. That is, I think, counterproductive. I mean, I asked Francois this morning whether he was worried because, you know, he's got it's got a lot to lose if someone trivially beats the arc challenge with a large language model, that would be quite scary. But just in defense of Gary, though, I've just read his new book and he's advocating, I mean, obviously there's the whole reliability thing and it's not reasoning and all the rest of it. Let's leave that to one side. But he's also making the the safety case. He's saying cigarettes were bad. Social media is bad. The future eludes us. This could be very, very harmful. We should be thinking about it. I mean, that seems reasonable to me. I'm not quite sure. I think that AI is a technology that solves problems by giving us better models. And this is ultimately what it is. And the way in which you deal with a bad guy with AI is ten good people with an AI. And there is always more value in creation than in destruction, more value in cooperation than in perfection. And we live in a world that is optimizing these benefits that are accruing. And so we can put our attention on the things that, for instance, the internet has made worse. And what we are forgetting is that what the fuck it did? Sorry, media get away with a few years ago because nobody was able to check up on it, right? Government conspiracies today are really difficult to make because there are so many back channels, so many outlets. Nobody is keeping their mouth shut. It's basically we have so much information available, we can actually do fact checking. And so what is happening is a slightly different thing. We have a government that is used to something like the financial industry being an arm of the government and controlling every transaction and monitoring every transaction and so on. And this is arguably in many ways useful as long as you trust your government, right. But we also realize that our government doesn't have perfect incentives. So there is a certain degree to which we do not trust your government. And so we typically agree that the government should not have all the data, it should not have all the control, it should not have full control of public opinion. Who is the one who's controlling the government? Is this the media? Well, yes, we distrust the media to the degree that the media is not also such a homogeneous cluster that is aligned with the government. And if that is happening, for instance, in eastern Germany, the media and the government were pretty much the same thing, right? And in a country like this, where the media is basically all the mainstream media seems to be aligned with one political party, people who disagree with the policies of that one political party, regardless of their party is good or not, might have a reason to fear a world where all the publicly available information is gatekept by that media that is partisan. And so what you find is that a lot of the attempts to control the content of social media fact checking and so on, election integrity, are partisan. They're directed directly on one particular party. And it could be that this is actually happens to be the good party, right? Like in China, you have only one good party. And so you don't need a second party. Maybe we want that, right. Maybe we realize that to save democracy, we should skip the next election to make sure that nothing endangers democracy. But it's a very touchy issue. Maybe we need to design democracy in such a way that it's robust. Maybe you already have that democracy. And a lot of the fear that we have is the result of incentives of media. And so if the government feels that media should be an arm of the government and that social media should be an arm of the government, but the government might feel we sent a list of accounts to social media platforms that we want to get deleted because they have opinions that we don't like, right? Maybe there is somebody who says that Covid comes from a lab, right? Maybe it does, maybe it doesn't. But it would be really, really bad if somebody said so because it would jeopardize trust in science. And if trust in science is jeopardized, maybe society can no longer function as well. And maybe it's necessary for us to memory hole the idea that yesterday we thought that masks don't help, and today we think it does. And maybe we need to memory hole the idea that there was no way that Covid emerged in a lab. And now we think it's quite possible and quite likely. And so this is a very weird situation. The control of information. And so I feel very uncomfortable with this idea of saying social media is bad because as somebody who grew up in eastern Germany, we didn't have social media. And social media is the only way in which you can form opinions outside of the government. And the reason why I believe in this Western project is this idea that we believe in a certain human aesthetic, and the core of this aesthetic is that in order to be free individuals that are not oppressed in any way, that are not enslaved by others. We need to be able to communicate about ideas non-violently. And so this freedom of speech is absolutely at the core of our democracy. And currently we have a group of people who are very influential who do not believe in this freedom of speech. They may or may not be correct, and I think they should be completely free to make their case and have better arguments. But they should not stop me from making counterarguments. And I am really worried about the consequences, because it seems to be obvious as soon as one side is able to limit speech, they can implement arbitrary opinions that might be against the interests of the majority and everything that's good in the world, and with an insight that would at one point was completely clear to everybody in the society. And now it's less clear. So I'm much more in favor of preparing social media. Social media seems to have the wrong incentives. Largely. It's a very unpleasant experience, but I don't think that's the result of freedom of speech. I think it's the result of social media being badly designed.

4.1 AI Regulation and Societal Impact
 Yeah. I mean, I agree that we need freedom of speech and pluralism of ideas, but I mean, Kenneth Stanley actually set up his own social network because he was worried about the the objective likes kind of, you know, distorting the system. Chomsky spoke about manufacturing consent, which is that even in a, in a free society, you know, the the information is very distorted. So we think that we're free and we're selecting information and we're thinking, but actually we're not. So how do we overcome this? I mean, look at AI regulation for example. We need to have expertise. We need to have people in the government that actually understand what they're talking about and are making informed decisions, because we don't really know that much about this technology as a whole. But you also need to have regulators who are incentivized to regulate in the right way. And there are different incentives that exist at the moment. It seems that we live in a society that has some kind of entropy with respect to its public institutions, its ability to produce goods and services, so somehow goods and services seem to be hollowed out over time to become more efficient, which means they get reduced to a minimum viable product, but they don't necessarily become cheaper. Right. So it's basically in many areas where you don't have an effective innovation anymore. We arguably have that. But maybe with the doors in your house you don't have in some region, basically improvement stops and things are just getting more sloppy every year and worse. And so our society depends on innovation to maintain a certain level because otherwise it rots. Basically, the innovation needs to outpace the rot in the other areas. And the main area where we're currently innovating is AI. There's almost no area where we're still innovating at scale, and everything else seems to be more about redistribution of goods and services that are increasingly no longer produced here, but financialized. And this creates, I think, a very brittle society that ultimately will make us poor. And so I think it's very important to maintain that innovation. But from the perspective of those who compete with the innovation, if, say, you are a professional prompt completer, your job is to write opinion pieces that are completely predictable. You will get a prompt and everybody knows what you will be saying, right? Arguably, I think that's what Gary Marcus I criticism is doing because I have not seen me writing anything that could not be predicted by GPT three. And that's a big issue that I have is there because it's not really original. It is sloppy. It's a model trained on its own output, and there is part of the society that is sloppy because it's just the model trained on its own output. It's no longer innovating. How can we, these people, compete with something that is innovating, that will try to regulate it out of existence? So there is a part of our society that basically wants to have something like an AI, FDA. And if you want to deploy a new model, any kind of say, I want to update GPT, maybe you need to get it to the FDA, FDA first, and the FDA will take only six months to test. And we take a pretty large fee and maybe a few million dollars, and it will be no open source models, and you cannot import the model from abroad to use it. And maybe make sure that the internet is no longer allowing that. And we ask the internet providers to make sure that this doesn't happen. Right. And you end up with having four large AI companies that are able to pay for the fees, and it's going to be similar to the way in which pharmaceuticals are going to be produced. And it's clear that that might be the interest of the four large AI companies and the interest of regulators, and in the interest of people who don't want AI, because maybe they're afraid of being turned into paperclips. And this is one part of the regulators are actually the doomers doomsday cult that is terrified because they listened very closely to Eliza Witkowsky and thought, it's true what he's saying. And on the other hand, there are people who just don't want their industry disrupted or they want to have political control over the output of llms. I agree with you. I mean, Gary does talk about the risk of regulatory capture. But and I mean, in his book, he, you know, quoted Mark Zuckerberg. You know, they said move fast and break things. And we had the PayPal story. So it started off there were no fees and it was wonderful. And they actually paid you to use it and now they exploit you. Same thing with with Netflix and Uber, for example. We're not a we're not a taxi company. So he's kind of saying that when when you let technology and go into a sector, they kind of they modify things so that none of the rules apply to them. And even if they have the best of intentions, it kind of causes harm after a while. And yes, indeed, the regulations we've got now are completely broken. They just don't work. Limiting the number of flops on, on on a model is ridiculous. Or I don't see how Uber has made the world worse. Uber has created transportation for people that didn't have transportation before. There are regions in cities where taxis just don't go and they don't have public transport. And Uber has resolved that situation by creating a market between drivers and people who want to be driven and that market is working. It also creates a lot of employment. And before we had a situation that the number of taxicabs was controlled with a central regulation, you had these medallions you could inherit or buy, and they were extremely expensive and they created friction in the market. And this friction in the market was actually not beneficial. And for me, it was fascinating when Uber came up in this, how this rating system worked in the car that basically you when an Uber came, you could rely on the car being clean and the driver being nice. Whereas if I took a taxi cab in Boston, the car was dirty and the driver tried to cheat you and the driver often didn't know where to go, and you had to tell them with Google Maps where to go and so on. That was really interesting when I came to the US and realized, okay, there is this free market thing that is innovative and that is doing things. And I asked people, how do you live off Uber? Do you make a lot of money? And they say, no, but I didn't have a job before and it gives me a way to earn money, and it's regulating depending on how many people need that service. So I believe that is a good thing. I think that technology, by and large, is a force for good, and it's something that certain regions of our society, people who are mostly depend on redistribution, people who are not productive but mostly rent seeking, who basically get money not for doing some things, but for having opinions, have opinions about technology because they see it as a competition. But competition technology allows us to make things more affordable that before were unaffordable. They produce more goods and services that can go around and they basically raise our boat. Many of the things you say is true, but I mean Uber, for example, they did this greyball thing where they detected if you were using the app and you were near a police station or a local council office, so they would say no cars available so they couldn't be investigated in China, they ordered they hired some hackers to get the IMEI code of the phone, and they almost got banned from from the App Store. So I'm totally in favor of controlling criminal behavior. I am also totally in favor of regulating things that we don't want as a society. Regulation is necessary. It's really important. There's also a lot of stuff that needs to be regulated with respect to AI. For instance, there is stuff going into the training data that should be private, and that was not thought to be an issue. For instance, say a lot of medical publications are built on medical data for which patients gave consent to be used for medical research. And the fact that this went into medical journals that were basically open access was not a problem, because nobody was reading those journals outside of extremely narrow contexts. But when these journals end up legitimately, legally in the public domain, and you legitimately, legally establish that you can train on public domain training data, maybe suddenly, personally recognizable data end up in an AI model, and nobody ever wanted that and anticipated it. And you need to create rules around this, and they need to be fair and equitable and create a good outcome for everyone to the degree that we can make it happen. There's also other stuff. For instance, I'm not in favor of creating a tax on future creation to reward past creators. I think the benefit for having something like copyright is that we incentivize the creation of important cultural artifacts that otherwise wouldn't exist. The reason that copyright exists is not that we limit creation, that we diminish the things that are in circulation. And so we need a society. Think about this conflict, about incentives where some people want to be paid and the interest of society where we want stuff to be created. And so the question is, how can we make a society that makes us as rich as possible and not just monetarily rich, but culturally rich that gives us the world that we want to be in? And I think that these technologies are amazing for that, but we need to use them in the right way. And how can we regulate our innovators and regulators? How can we incentivize the people who set the incentives? And this is a very deep question. I hope that I can also help us understanding this, modeling it, but at the moment we have forgotten about this question in a way. But but this is one of the themes that that Gary talks about though, because, yeah, the flouting the copyright that OpenAI presented to the House of Lords in the UK and they made the case that, um, don't worry about us flouting copyright because we as a society need to have good AI. So it kind of makes sense. And with Uber, um, they lost, you know, the workers lost their their protections and so on. But the thing is this is all about conservatism and adaptation. So of course now when people see deepfakes on Twitter, they, they just they don't take it seriously because they don't trust anything they see online. And now people know that we're moving into a regime where copyright is being devalued and so on. But but there is something to be said, for maybe we should protect what we have now and maybe change if it's too fast can be harmful. I think if a capitalist society works well, it is not going to create a lot of profit in the in a given place for very long, because what the profit prophet is representing is an arbitrage. It basically means that you are doing something that could be done more cheaply, more efficiently. And so if you see something that has increasing margins over a long time, it means that somebody else has to pay more than they would have to. And so the idea that you have cab drivers that exist as a protected class, and that are somewhat disengaged from how many drivers is needed, is a problem, because it also means that people who actually need to be driven around cannot be driven around, and that people that want to drive them around are not allowed to drive them around, even if they're totally capable to. And that's that's a misallocation of resources. And so sometimes we need to resolve such misallocation of resources by removing regulation. That makes things worse. We have this issue that if you want to dig a new subway tunnel in New York, you need the union demands that you're paying people for doing things that are no longer being done in modern, tunnel boring machines. So you have people that have a six digit paid jobs that are not actually doing anything just because we have a regulation, and as a result, we don't build new subway tunnels in New York because it's way too expensive and it's bad for everyone, right? So in many ways, we need to think about what regulations do we build that have which effect. And copyright is a quite complicated thing at the moment. Part of the internet is an outrage because Elon Musk has released an update to grok. Yes, his AI that is able to generate pictures that don't have the same guardrails as other pictures. So you are now able to generate a picture of Donald Trump with a machine gun flying into the nine over 11 skyscrapers. And the outrage is incredible. It's people who just typed in this prompt and are say to Elon Musk, what an evil person are you see what you made me do? It's hilarious. It's, uh, it's a really, really interesting situation. And then people say, oh, my God, I noticed the same thing in my Apple two computer when I type in my Apple two computer print, Eat More Rocks. It tells me to eat more rocks, which is really, really dangerous. This should be completely outlawed. And so there is an issue here. I think that in one side the AI generative AI is a brush. It allows you to paint things and translates what you want to, what you envision into a visual. But by itself, it's not a product, it's a it's a tool that allows you to produce a certain content. And I think that people are not free to produce any kind of content in any kind of given context. It's not just a matter of free speech. There are legitimate copyright interests. There are interests to not disrupt communities in legitimate things that they are doing right. There are libel laws and many other things. so people are responsible for the content that they are producing, using Photoshop, or using a text editor or using a paintbrush. And in the same way, they are responsible for the content that they're producing with an LLM. And nobody was forcing that person to produce a picture of Donald Trump doing nine over 11, right? Nobody was thinking that Trump did nine over 11. If that person is producing a deepfake to insinuate that Trump was doing nine over 11, the person might be already legally liable. We might not even need a new regulation for this. But if we want to impose a regulation that prevents the AI from producing this particular thing, right, it's going to have side effects. And these side effects are going to negate a lot of the benefits that we can get from that technology. So if we want, for instance, have social media that only allow you to say things that have been fact checked before, most of the benefits of the internet will no longer manifest. And so it's much better when we develop technology that deals with the drawbacks of having more power, having more freedom, having more productivity, more innovation, rather than preventing the innovation in the first place. Yeah, and I completely agree that when you start regulating things very quickly, it explodes into a bureaucracy. And I can really see where you're coming from. Yeah, but there are really people there that try to eliminate not just freedom of speech, but also freedom of thought, freedom of imagination, freedom to create certain things. And I find this very ugly and I think we need to oppose it. We need to defend a certain idea. And this idea, I think, is the core of our society, of a world that works to free us, that allows us to take responsibility for each other, that allows us to discover ethics, that allow us to coordinate by autonomously recognizing what is that we actually want. And to do this, I think we need to be free. This is not that there is some kind of group in a university of enlightened 20 year olds that have their preferred ideology and can impose it on everybody by controlling what can be printed in social media or what can be generated by AI. This doesn't mean that there is no problem with AI. There are no difficulties that we need to figure out how to solve or with social media. But we need to be very mindful of what is the idea of a society that we want to live on while we impose these regulations. But but isn't our freedom to book an Uber the drivers kind of prison? I mean, there are examples of drivers committing suicide and stuff like that, you know, isn't it something that we really need to think about what the cons are, you know, for our freedom? So you mean it's better if people are not allowed to drive an Uber? I mean, under which conditions should the government step in to prevent two people from making a contract with each other? This is, I think, an interesting question. Right. Is it actually beneficial when you have a government that is able to regulate every contract, especially if this government is captured by existing industries that prevent you from making contracts because they want to make more profits. I think that the taxi industry is an extremely good example. You have basically an Organized industry that is, has a regulated profit while providing a suboptimal service, and it maintains that advantage by preventing competition. There are reasonable people that have good reason to believe that both sides are capable and safe and sound and well intentioned, and they want to make that contract. They're not allowed to. What? How do you justify that? And I think that's the main issue. Interesting. Let's move on a tiny bit. What are your thoughts on the the AI and startup ecosystem and LLM companies in particular? I think that the majority of the companies that exist in this ecosystem are building applications, and these applications basically use the benefits that are provided by having generative AI and turn them into value. And it's often possible to do this with relatively little investment. So a lot of these startups that can now come into existence are of people that use the benefits of LM, for instance, to auto generate websites, to auto generate functionality of databases. And we're just at the beginning of this where the LM is no longer an agent, but a software or an environment or a larger application that is dynamically changing its shape in interaction with the user. So I think we're standing at the beginning of an explosion of services that people can provide and basically give rise to a lot of value that is going to be created. And then a handful of companies that are developing the technology at scale that were devising these new frontier models. And there is an issue with these frontier models, because if you build the leading model, then this thing is going to be valuable until somebody makes the next model that is slightly better than yours. So the cost that you built into training this model is going to be sunk in that moment. That's a very interesting situation because not everybody is able to absorb that hit. And it's not like you're building an airplane and you are deploying that airplane, and somebody builds a slightly better airplane and your airplane suddenly is worth zero. It's still a useful airplane, right? But with the LM, because the software that you can just just put in the update into the server farm, of course, you should always be using the most recent version to create value. It's not like there is a lot of value by using last year's version, because you still need to amortize it. So this is a question who can absorb these losses? And this means these need to be research labs that are mostly driven on producing value by making innovation. And they either need to have extremely good business development to produce revenue for customers that need particular models, for particular applications that cannot be easily updated that easily or quite subtle trajectories, or they need to be affiliated with other companies, like companies that build operating systems or that build logistics applications and so on, and that produce a lot of money and can basically fund the development of new technology on the side. Yeah. It's interesting. I mean, what's your prediction about something like Mistral?

4.2 Open-Source AI and Industry Challenges
So at liquid you have a clear moat. You've got a technology that no one else has has done yet. Yes. And what about Mistral? I think that when you're building open source models that are, in a way, in a similar situation as people who build open source websites or open source languages or open source software development frameworks or libraries, what you are creating is an ecosystem in which more people will be able to survive, including yourself. So you're developing something that doesn't exist today and by, for instance, deploying the stable diffusion models. A lot of people got the opportunity to develop innovations for generative Stability AI. (n.d.). Stable Diffusion. GitHub. AI than existed before, and it created an extremely large ecosystem of people that then would start companies and come up with ideas. So I think these investments are extremely valuable, and they should be encouraged and rewarded, and they often are. But also, I understand totally when Mistral at some point says no, now we're going close to us because we need a way to capitalize on this, and we don't see how to do this in the present case. I'm extremely grateful that these historical accidents like meta exist. I think what happened at Mark Zuckerberg had enough money in the bank and thought about how to get social media to the next level and thought it's going to be VR, and then invest it into a large server farm to do VR, and then realized that VR is not yet realizable in the present form, or it's going to go in a slightly different direction and suddenly had a lot of servers and then thought, oh, what do we do with all these GPUs? Let's train train a few models and make them publicly available. And I'm very grateful for that happening because it is creating a baseline and a tool that other companies can build on and innovate on and develop new ideas that are also feeding back into the frontier labs. So I think that despite people locally looking in despair or being worried or so from the perspective of somebody who's interested in AI itself and on the effect of these things on the ecosystem, I'm grateful that these things exist. Yeah. It's interesting. I read in Gary's book that apparently Zuckerberg did it because nobody in the Valley wanted to work for meta, so they had to have some exciting projects just just to hire people in. I have visited the Facebook offices from time to time and they were quite empty, but I think that's because of the pandemic. It's not that meta has any problem to recruit talent. Meta is very profitable, and it is a workplace that most people like to work in. And so I think that when Gary Marcus says such a thing, I'm not sure what is this based on? Does he have any kind of statistics that show that meta has difficulty to find candidates? I don't think that's the case. I must admit, I was surprised because I would love to work at meta, but, um, yeah, that's very interesting. Anyway, I think we've run out of time. So Yoshua, it's been an absolute honor and a pleasure. Thank you so much for coming. I enjoyed this very much. Amazing, wonderful.
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
sys_prompt = resolve_sys_prompt(podcast, SYS_PROMPT_4REFOR_TMPL);

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

# ╔═╡ e2ffe835-65dc-4c85-aa9a-d98867da2ff5
if PROCEED_WITH_SYNTHESIS
  for ix ∈ 1:length(podcast.toc)
	  length(podcast.toc[ix]) == 0 && continue
	  instruct_prompt = """Proceed with the transcription of the section "$(podcast.toc[ix])" as precisely and as faithful to the original as possible."""
	  # println("instruction: \n", instruct_prompt)
	  synthesis = make_timed_chat_request(
		  upd_sys_prompt,
		  instruct_prompt;
		  LLM_PARAMS...
	  )
	  str_synthesis = join(synthesis, "\n")
	  println("Synthesis:\n$(str_synthesis)")
	  if ix == 1
	  	save_synthesis(fh, string("## Content\n\n", str_synthesis))
	  else
	  	save_synthesis(fh, str_synthesis)
	  end
  end
end

# ╔═╡ 31e10d8d-d176-49cd-b6a0-51e9136bea21
PROCEED_WITH_SYNTHESIS && (close(fh));

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
begin
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
    max-width: calc(1100px + 25px + 6px);
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
# ╠═e2ffe835-65dc-4c85-aa9a-d98867da2ff5
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
