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
1. TODO: Extra: re-generate the transcript without the mistakes inherent to the transcript generation
1. TODO: Extra: using both synthesis and re-generated question ask questions
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
PODCAST_TITLE, PODCAST_URL = """All Learning Algorithms Explained in 14 Minutes""", """https://www.youtube.com/watch?v=BT6Aw6Q75Yg"""

# ╔═╡ f1cf76d4-d894-4c80-a4bd-0eb6f37df38d
PODCAST_TOC = map(x -> string(strip(x)), 
	split("""
Intro [0:00]
Linear regression [0:22]
SVM [0:51]
Naive Bayes [2:18]
Logistic regression [3:15]
KNN [4:28]
Decision tree [5:55]
Random forest [7:21]
Gradient Boosting (trees) [8:42]
K-Means [9:50]
DBSCAN [11:47]
PCA [13:14]
""", "\n")
) |> vtoc -> filter(x -> length(x) > 0, vtoc)

# ╔═╡ d2dfeb72-86c6-4535-8d98-e3293beb7c7a
PODCAST_CONTEXT = """In this podcast the goal is to present the essence of the main Machine Learning algorithms succinctly.
""";

# ╔═╡ 2f4ae40f-a1ab-470b-a1b7-a04fec353b0e
PODCAST_RAW_TRANSCRIPT = """
# Intro
every single machine learning algorithm explained in case you don't know an algorithm is a set of commands that must be followed for a computer to perform calculations or like other problemsolving operations according to its formal definition an algorithm is a finite set of instructions carried out in a specific order to perform a particular task it's not an entire program or code it is simple logic to a 

# Linear regression
problem linear regression is a supervised learning algorithm and tries to model their relationship between a continuous Target variable and one or more independent VAR variables by fitting a linear equation to the data take this chart of dots for example a linear regression model tries to fit a regression line to the data points that best represents the relations or correlations with this method the best regression line is found by minimizing the sum of squares of the distance between the data points and the regression line so for these data points the regression line Looks like this

# SVM
support Vector machine or svm for short is a supervised learning algorithm and is mostly used for classification tasks but is also suitable for regression R tasks svm distinguishes classes by drawing a decision boundary how to draw or determine the decision boundary is the most critical part in svm algorithms before creating the decision boundary each observation or data point is plotted in N dimensional space with n being the number of features used for example if we use length and width to classify different cells observations are plotted in a two-dimensional space and decision boundary is a line if we use three features decision boundary is a plane in three-dimensional space if we use more than three features decision boundary becomes a hyper plane which is really hard to visualize decision boundary is drawn in a way that the distance to support vectors are maximized if the decision boundary is too close to a support Vector it'll be highly sensitive to noises and not generalize well even very small changes to independent variables may cause a misclassification svm is especially effective in cases where number of dimensions are more than the number of samples when finding the decision boundary svm uses a subset of training points rather than all points which makes it memory efficient on the other hand training time increases for large data sets which negatively affects the

# Naive Bayes
performance Naive Bayess is a supervised learning algorithm used for classification tasks hence it is also called Naive Bayes classifier Nave Bas assumes that features are independent of each other and there is no correlation between features however this is not the case in real life this Nave Assumption of features being uncorrelated is the reason why this algorithm is called naive the intuition behind naive Bay algorithm is the Bas theorem p a is the probability of event a given event B has already occurred PBA is probability of event B given event a has already occurred PA is the probability of event a and PB is the probability of event B naive Bas classifier calculates the probability of a class given a set of feature values the the assumption that all features are independent makes knif based algorithm very fast when compared to complicated algorithms in some cases speed is preferred over higher accuracy but on the other hand the same assumption makes naive Bayes algorithm less accurate than complicated

# Logistic Regression
algorithms logistic regression is a supervised learning algorithm which is mostly used for binary classification problems logistic regression is a simple yet very effective classification algorithm so it is commonly used for many binary classification tasks things like customer turn spam email website or ad click predictions are some examples of the areas where logistic regression offers a powerful solution the basis of logistic regression is the logistic function also called the sigmoid function which takes any real value number and Maps it to a value between 0o and 1 Let's consider we have the following linear equation to solve logistic regression model takes a linear equation as input and uses logistic function and log odds to perform a binary classification task then we will get the f famous shaped graph of logistic regression we can use the calculated probability as is for example the output can be the probability that this email is Spam is 95% or the probability that the customer will click on the ad is 70% however in most cases probabilities are used to classify data points for example if the probability is greater than 50% the prediction is positive class or one otherwise the prediction is negative class or zero K nearest Neighbors or K&N for short is a supervised learning algorithm that can be used to solve both classification and regression tasks the main idea behind

# KNN
KNN is that the value of a class or of a data point is determined by the data points around it KNN classifier determines the class of a data point by majority voting principle for instance if K is set to five the classes of five closest points are checked prediction is done according to the majority class similarly K&N regression takes the mean value of five CL closest points let's go over an example consider the following data points that belong to four different classes and let's see how the predicted classes change according to the K value it is very important to determine an optimal K value if K is too low the model is too specific and not generalized well it also tends to be too sensitive to noise the model accomplishes a high accuracy on train set but will be a poor predictor on new previously unseen data points therefore we are likely to end up with an overfit model on the the other hand if K is too large the model is too generalized and is not a good predictor on both train and test sets this situation is known as underfitting KNN is simple and easy to interpret it does not make any assumption so it can be implemented in nonlinear tasks KNN does become very slow as number of data points increases because the model needs to store all data points thus it is not memory efficient another downside of KNN is that it is sensitive to outliers

# Decision trees
decision trees work by iteratively asking questions to partition data it is easier to conceptualize the partitioning data with a visual representation of a decision tree this represents a decision tree to predict customer CH first split is based on monthly charges amount then the algorithm keeps asking questions to separate class labels the question get more specific as the tree gets deeper the aim is to increase the predictiveness as much as possible at each partitioning so that the model keeps gaining information about the data set randomly splitting the feature does not usually give us the valuable insight into the data set it's the splits that increase purity of nodes that are most informative the purity of a node is inversely proportional to the distribution of different classes in that node the questions to ask are chosen in a way that increases Purity or decreases impurity but how many questions do we ask when do we stop when is our tree sufficient to solve our classification problem the answer to all of these questions leads us to one of the most important Concepts in machine learning overfitting the model can keep asking questions until all nodes are pure however this would be a two specific model and would not generalize will it achieves high accuracy with training set but performs poorly on new previously unseen data points which indicates overfitting decision tree algorithm usually does not require to normalize or scale features it is also suitable to work on a mixture of feature data types on the negative side it is prone to overfitting and needs to be ensembled in order to generalize well 

# Random Forest
random Forest is an ensemble of many decision trees random forests are built using a method called bagging in which decision trees are used as par parel estimators if used for a classification problem the result is based on majority vote of the results received from each decision tree for regression the prediction of a leaf node is the mean value of the target values in that leaf random Forest regression takes mean values of results from decision trees random forests reduce the risk of overfitting and accuracy is much higher than a single decision tree furthermore decision trees in a random forest run in parallel so that the time does not become a bottleneck the success of a random Forest highly depends on using uncorrelated decision trees if we use the same or very similar trees the overall result will not be much different than the result of a single decision tree random forests achieve to have uncorrelated decision trees by bootstrapping and feature Randomness bootstrapping is randomly selecting samples from training data with replacement they are called the bootstrap samples feature Randomness is achieved by selecting features randomly for each decision Tree in a random Forest the number of features used for each tree in a random Forest can be controlled with maxcore features parameter random Forest is a highly accurate model on many different problems and does not require normalization or scaling however it is not a good choice for high dimensional data sets compared to fast linear models 

# Gradient Boosting
gradient boosted decision trees or gbdt for short is an ensemble algorithm which uses boosting methods to combine individual decision trees boosting means combining a learning algorithm in series to achieve a strong learner from many sequentially connect weak Learners in the case of gbdt the weak Learners are the decision trees each tree attempts to minimize the errors of previous tree trees in boosting are weak learners but adding many trees in series and each focusing on the errors from the previous one make boosting a highly efficient and accurate model unlike bagging boosta does not involve bootstrap sampling every time a new tree is added it fits on a modified version of the initial data set since trees are added sequentially boosting algorithms learn slowly in statistical learning models that learn slowly perform better gbdt is very efficient on both classification and regression tasks and provides more accurate predictions compared to random Forest it can handle mixed type of features and no pre-processing is needed gbdt does require careful tuning of hyperparameters in order to prevent the model from overfitting

# K-means
K means clustering clustering is a way to group a set of data points in a way that similar data points are grouped together therefore clustering algorithms look for similarities or dissimilarities among data points clustering is an unsupervised learning method so there is no label associated with data points clustering algorithms try to find the underlying structure of the data observations or data points in a classification task have labels each observation is classified according to some measurements classification algorithms try to model the relationship between measurements on observations and their assigned class then the model predicts the class of new observations K means clustering aims to partition data into K clusters in a way that data points in the same cluster are similar and data points in different clusters are further apart thus it is a partition based clustering technique similarity of two points is determined by the distance between them consider the following 2D visualization of a data set it can be partied into four different clusters now real life data sets are much more complex in which clusters are not clearly separated however the algorithm works in the same way K means is an iterative process it is built on expectation maximization algorithm after the number of clusters are determined it works by executing the following steps number one it randomly selects the centroids or the center of cluster for each cluster then it calculates the distance of all data points to the centroids it assigns the data points to the closest cluster it finds the new centroids of each cluster by taking the mean of all data points in the cluster and it repeats steps 2 3 and four until all points converge and cluster Center stop moving K means clustering is relatively fast and easy to interpret it is also able to choose the positions of initial centroids in a smart way that speeds up the convergence the one challenge with K means is that the number of clusters must be predetermined cayman's algorithm is not able to guess how many clusters exist in the data if there is a nonlinear structure separating groups in the data K means will not be a good choice

# DBScan
DB scan clustering partition based and hierarchical clustering techniques are highly efficient with normal shaped clusters however when it comes to arbitrary shaped clusters or detecting outliers density based techniques are more efficient DB scan stands for density based spatial clustering of applications with noise it is able to find arbitrary shaped clusters and clusters with noise the main idea behind DB scan is that a point belongs to a cluster if it is close to many points from that cluster there are two key parameters of DB scan EPS which is the distance that specifies the neighborhood two points are considered to be neighbors if the distance between them are less than or equal to EPs and Min pts which is the minimum number of data points to define a cluster based on these two parameters points are classified as score Point border point or outlier a point is a core point if there are at least Min pts number of points including the point itself in its surrounding area with radius EPS a point is a border point if it is unreachable from a core point and there are less than Min pts number of points within its surrounding area and a point is an outlier if it is not a core point and not reach from any core points DB scan does not require to specify a number of clusters beforehand it is robust to outliers and able to detect the outliers in some cases determining an appropriate distance of neighborhood EPS is not easy and it requires domain knowledge 

# PCA
principle components analysis or PCA is a dimensionally reduction algorithm which basically derives new features from the existing ones with keeping as much information as possible PCA is an unsupervised learning algorithm but it is also widely used as a pre-processing step for supervised learning algorithms PCA deres new features by finding the relations among features in a data set the aim of PCA is to explain the variance within the original data set as much as possible by using less features the new derived features are called principal components the order of principal components is determined according to the fraction of variance of original data set they explain the advantage of PCA is that a significant amount of variance of the original data set is retained using much smaller number of features than the original data set principal components are ordered according to the amount of variants that they explain and that is every common machine learning algorithm explained 


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

# ╔═╡ e2ffe835-65dc-4c85-aa9a-d98867da2ff5
if PROCEED_WITH_SYNTHESIS
  for ix ∈ 1:length(podcast.toc)
	length(podcast.toc[ix]) == 0 && continue

    instruct_prompt = """Proceed with the synthesis of the section "$(podcast.toc[ix])"."""
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
