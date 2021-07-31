### A Pluto.jl notebook ###
# v0.14.4

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 3d4d751a-b972-4e88-b568-1f19f0f20564
begin
        const DIR = "$(ENV["HOME"])/Projects/ML_DL/Notebooks/julia-notebooks/Julia_Investigation/"

        using Pkg
        Pkg.activate(DIR)
end

# ╔═╡ e95db99e-a9ec-437c-9557-4dec4f42926f
begin
        using PlutoUI
        using CSV, DataFrames, TextAnalysis
        using Pipe: @pipe
        using Plots
end

# ╔═╡ 35b8ad6d-7c5e-43bf-b014-ce24010a959a
using TextAnalysis: NaiveBayesClassifier, fit!, predict

# ╔═╡ cbad2e04-9d92-11eb-3d84-9da6f9a3c818
md"""

## Sentiment analysis with Julia

Based on [HoJ - Tom Kwong](https://github.com/Humans-of-Julia/Challenges/tree/main/Week2-TextAnalysis.jl/tk3369) and the presentation [Sentiment Analysis in Julia with TextAnalysis.jl by Tom Kwong](https://www.youtube.com/watch?v=vZr1SOxjDms)

This notebook explores the [Twitter US Airline Sentiment](https://www.kaggle.com/crowdflower/twitter-airline-sentiment) data set from Kaggle.

We will use [TextAnalysis.jl](https://github.com/JuliaText/TextAnalysis.jl) as the primary tool for analyzing textual data.


$(html"<div><sub>&copy; Pascal, April 2021</sub></div>")
"""

# ╔═╡ 26957ae3-1a74-4be7-b96e-d3292991a82a
PlutoUI.TableOfContents(indent=true, depth=4, aside=true)

# ╔═╡ 225ebbac-2232-47ff-b7dc-e2c59814f196
md"""
### Loading the Data
"""

# ╔═╡ 3ab74396-3e42-4545-af0b-f5746345324d
begin
        cd(DIR)
        df = CSV.File("./data/Tweets.csv") |> DataFrame
end

# ╔═╡ 13a43945-1a9c-4526-9f63-03a306b8d459
md"""
### Data Wrangling

Let us take at look at the data to get some understanding about what is going on.
"""

# ╔═╡ 7e812f27-4129-48ba-b4f5-a49ddc4169ca
describe(df, :eltype, :nmissing, first => :first, last => :last)

# ╔═╡ 3a0b11b9-a51e-47f1-833c-8c9a2e4d73ce
md"""
It looks like the column `:airline_sentiment` is our label.
"""

# ╔═╡ 5f3e9cc0-fb07-4f2d-be7c-590f13bbd03d
let gp = combine(groupby(df, :airline_sentiment), nrow)
        bar(gp.airline_sentiment, gp.nrow,
                title="Airline Sentiment",
                label="",
                # legend=:topleft
        )
end

# ╔═╡ 1c0d74d4-aac6-4fa4-8957-84457c73107e
md"""
OK, so this dataset is unbalanced, there are more negative sentiment than positivie one (maybe not surprising - we write to complain about...)
"""

# ╔═╡ 668b9aac-454a-43a6-8c40-44a0c023129a
histogram(df.airline_sentiment_confidence;
        legend=nothing, title="Airline Sentiment Confidence")

# ╔═╡ 23c79d73-3431-44c3-a4ef-4dd8337f7931
let gp = groupby(dropmissing(df, :negativereason), :negativereason) |>
                df_ -> combine(df_, nrow)
        bar(gp.negativereason, gp.nrow;
                title="Negative Reasons", label=nothing, xrotation=45)
end

# ╔═╡ ca585d7b-d7f1-48f6-ac88-10aa582b6dbe
md"""
The CSV file contains over 14,000 tweets. Let's quickly examine some individual data.

Before we go further, it would be nice to display a single record in table format. We can define a `table` function that converts an indexable object into Markdown format, which can be displayed in this Pluto notebook.
"""

# ╔═╡ 1289f7cf-6c2a-4b67-a817-3de3926d46ec
function table(nt)
        io = IOBuffer()   ## the link with the bind macro
        println(io, "|name|value|")
        println(io, "|---:|:----|")
        for k ∈ keys(nt)
                println(io, "|`", k, "`|", nt[k], "|")
        end
        return Markdown.parse(String(take!(io)))
end;

# ╔═╡ dbc871c5-9ca9-432c-98f8-af386ebdb22e
md"""
Let us define a variable called `row` and bind it to a slider for quick experimentation.
"""

# ╔═╡ e4c7dc20-f703-4d56-9835-af4fdcb32668
@bind row html"""
<input type="range" min="1" max ="100" value="36" />
"""

# ╔═╡ 6d7d638a-93a5-4c40-8d60-899ccafb0cdc
"Current Record: $row"

# ╔═╡ 4a649215-b35b-4e5c-96ab-ee9808d2de8e
table(df[row, :])

# ╔═╡ 9e89132b-ae35-4d85-ae98-15b1ea326991
md"""
As an example, record #36 has the tweet text as:
```
Nice RT @VirginAmerica: Vibe with the moodlight from takeoff to touchdown. #MoodlitMonday #ScienceBehindTheExperience http://t.co/Y7O0uNxTQP
```
This is a tricky one because it contains all of the followings:
- mention (`@VirginAmeria`)
- hash tag (`#MoodlitMonday` and `#ScienceBehindTheExperience`)
- URL (`http://t.co/Y7O0uNxTQP`)
Technically `RT` is a shorthand for "retweet" so perhaps it should be expanded but let's not worry about that for now.
"""

# ╔═╡ de978888-c378-46e9-8158-2cdbc1a6fe2f
md"""
### Handling mentions and hastags

If we just ignore these problems then it can be a disaster.
"""

# ╔═╡ e31a7663-6705-450e-9100-346b8fe51e15
let s = df[36, :text]
        sd = StringDocument(lowercase(s))
        op = 0x00
        op |= strip_punctuation
        op |= strip_stopwords
        op |= strip_html_tags
        prepare!(sd, op)
        stem!(sd)
        table(ngrams(sd))
end

# ╔═╡ 8db4042d-fba1-4bb7-ba43-0acc718e1389
md"""
We can see some problems here. It seems that when we stripped punctuations, it also took the `@` and `#` signs away. The URL also became weird. OK, that is what stripping punctuation means...
"""

# ╔═╡ 5fc69267-810a-479c-acdf-6026ca901f64
md"""
#### Extracting mentions, hash tags, and URL's.

This neat idea came from José Bayoán Santiago Calderón when I asked the question on Slack. Let's define some functions using regular expressions.
"""

# ╔═╡ 50e09727-5fb9-4f02-9a71-f2fa65eb19b9
const Regexp = Dict{Symbol, Regex}(
        :mention => r"@\w+",
        :hashtag => r"#\w+",
        :url => r"http[s]?://(?:[a-zA-Z]|[0-9]|[$/\-_@\.&\+]|[!\*\(\),]|(?:%[0-9a-fA-F]{2}))+",
)

# ╔═╡ 9ea51080-e3f8-4d70-a139-aa29ddf6d13b
extract_tokens(s::AbstractString, token_type::Symbol) =
        collect(x.match for x in eachmatch(Regexp[token_type], s))

# ╔═╡ d55d2b3c-82cf-4328-9aee-279e839d0a92
function remove_tokens(s::AbstractString)
        for re ∈ values(Regexp)
                s = replace(s, re => "")
        end
        s
end

# ╔═╡ 69c18f2f-7e22-4188-9464-9705f4aed7e3
remove_tokens("Nice RT @VirginAmerica: Vibe with the moodlight from takeoff to touchdown. #MoodlitMonday #ScienceBehindTheExperience http://t.co/Y7O0uNxTQP")

# ╔═╡ e4186b6a-2ee3-4fd7-b1a3-06a499aeaf07
values(Regexp) .=> ""

# ╔═╡ 7f5d2d98-e170-46ff-a470-e7708cbe3fb3
md"""
#### Create a new DataFrame with extrated and clean textfields
"""

# ╔═╡ 10a4ddbc-66c4-472d-999e-99838da6652d
begin
        d = Dict(
                :airline_sentiment => df.airline_sentiment,
                :text => df.text,
                :mentions => extract_tokens.(df.text, :mention),
                :hashtags => extract_tokens.(df.text, :hashtag),
                :urls => extract_tokens.(df.text, :url),
                :clean_text => remove_tokens.(df.text) .|> strip .|> lowercase
        )
        df₂ = DataFrame(d);
end

# ╔═╡ a65e9da9-0e8b-4356-820f-266eaba857c8
table(df₂[36, :])

# ╔═╡ 09441471-d246-4511-8d8e-e941b1166159
md"""
As we can see, the mentions/hashtags/urls are extracted into separate columns in the DataFrame. The `clean_text` field contains the cleaned version of `text`.
"""

# ╔═╡ 5855ee27-4d34-41e4-9881-70ad4b5f064e
md"""
### Using Naive Bayes Classifier

"""

# ╔═╡ 819af8d7-c242-4f7b-a61f-121263bdb54c
md"""
In our DataFrame, we already have a column `x_string_doc` with `StringDocuments` values. So we can just fit them to the classifier.
"""

# ╔═╡ 41a18e5c-7e01-4828-9df0-53d446da9eb1
function create_string_doc(s::AbstractString)::StringDocument
        sd = StringDocument(s)
        op = 0x00
        op |= strip_punctuation
        op |= strip_stopwords
        op |= strip_html_tags
        prepare!(sd, op)
        stem!(sd)
        sd
end

# ╔═╡ 3ac25d84-b396-4341-956b-c550054038c0
model = let
        labels = df₂.airline_sentiment .|> strip |>
                unique ## ≡ labels = ["neutral", "positive", "negative"]
        nbc = NaiveBayesClassifier(labels)

        for (clean_txt, y) ∈ zip(df₂.clean_text, df₂.airline_sentiment)
                x = create_string_doc(clean_txt)
                fit!(nbc, x, y |> strip)
        end

        nbc
end;

# ╔═╡ cd495081-805b-4e71-814a-10add9a65d03
typeof(model)

# ╔═╡ bcae0e95-22fc-4526-9c71-a186e20d5d8d
typeof(NaiveBayesClassifier)

# ╔═╡ 032ddbf5-5995-4ff9-be43-3cfa16eaac91
function test_model(model, tweets::Vector{<: AbstractString})
        df = DataFrame(text=tweets)
        df.doc = remove_tokens.(tweets) .|>
                create_string_doc .|>
                TextAnalysis.text
        # TextAnalysis.text.(create_string_doc.(remove_tokens.(tweets)))
        df.analysis = predict.(Ref(model), df.doc)

        df.positive = getindex.(df.analysis, "positive")
        df.negative = getindex.(df.analysis, "negative")
        df.neutral = getindex.(df.analysis, "neutral")

        select!(df, Not(:analysis))
        df
end

# ╔═╡ 6887b10b-0c44-4a1a-bbe0-e08032ac1dff
let
        tweets = [
                "whatever airline sucks!",
                "i love @american service :-)",
                "just ok",
                "hello world"]
        test_model(model, tweets)
end

# ╔═╡ 0c7ad5a2-e8b1-4189-82f5-d39cbc122d2d
md"""
#### Determining accuracy

OK, so how well does the Naive Bayes Classifier perform?

As the `predict` fucntion returns a `Dict` object with the probabilities assigned to each class, we need to choose the best one. So let us write a function for that:
"""

# ╔═╡ 2c853e55-843c-43c8-87b4-9ef6810dc03d
function best_pred(model::NaiveBayesClassifier, sd::StringDocument)
        predict(model, sd) |> argmax
end

# ╔═╡ 2484eca4-198c-4178-8b78-26ee246f786b
md"""
Now le us make predictions over all 14K tweets.
"""

# ╔═╡ 902b8634-7cde-4808-9e77-c13caac19c8f
ŷ = let x = remove_tokens.(df₂.text) .|> lowercase .|> create_string_doc
        best_pred.(Ref(model), x)
end;

# ╔═╡ 53c34fd9-f9c4-4321-94f3-2e4a6c3cd70a
hits = count(df₂.airline_sentiment .== ŷ)

# ╔═╡ e3ff7e20-c376-4bf7-b6da-0769551d5561
misses = length(ŷ) - hits

# ╔═╡ 92378e5b-c5e9-4a75-ae1e-216d67f4fd60
way_off = count(
        (df₂.airline_sentiment .≠ ŷ) .&
        (df₂.airline_sentiment .≠ "neutral") .&
        (ŷ .≠ "neutral")
)

## predicted positive and actually negative and conversely.

# ╔═╡ 240e86a4-4787-41ca-91ad-27893db438cc
begin
        accuracy_perc = hits / (hits + misses) * 100.
        round(accuracy_perc; digits=2)
end

# ╔═╡ f9e6c472-3dfb-4617-a0ef-99d1cbd34427
begin
        slightly_off_perc = (misses - way_off) / (hits + misses) * 100.
        round(slightly_off_perc; digits=2)
end

# ╔═╡ 05e7f1ba-ac19-4160-b158-0ef83af00e89
begin
        way_off_perc = way_off / (hits + misses) * 100.
        round(way_off_perc; digits=2)
end

# ╔═╡ fab2cd7c-cecc-41a8-ab28-b71ba00fec95
bar(["hits", "misses slightly", "misses way-off"],
        [accuracy_perc, slightly_off_perc , way_off_perc];
        legend = :none)

# ╔═╡ 52eef2d7-27b5-418f-b432-64f8561472b3
md"""
### Analyze some random tweets

Using the tweet API (ok, requires an account)...
"""

# ╔═╡ 8102896d-c25a-4210-81e5-94195b44f9e3
## using HTTP, JSON3
# token = readline("...<internal_dir>/twitter-bearer")

# ╔═╡ acbe6150-4732-48d5-a3cd-b695d3e0887c
# resp = HTTP.get("https://api.twitter.com/1.1/search/tweets.json?q=lang%3Aen%20flight", ["authorization" => "Bearer $token"]);

# ╔═╡ fdfabb92-3be3-4644-906a-eae308bdda0e
# begin
#       data = JSON3.read(response.body);
#       data[:statuses][1]
# end

# ╔═╡ 7e4bcd5e-0378-4c18-941d-feddba9ae872
# tweets = [x.text for x in data.statuses]

# ╔═╡ c63aa4f9-79b3-4651-85b9-50cb97b6c7c5
# result = test_model(model, tweets)

# ╔═╡ c5c2dd33-ad6e-451a-bbcc-12e84d0786b9
# table(result[9,:])

# ╔═╡ b10fe2c1-b451-48c4-8088-c03c85d31ed1
html"""
<style>
  main {
        max-width: calc(800px + 25px + 6px);
  }
  .plutoui-toc.aside {
    background: linen;
  }
  h3, h4 {
        background: wheat;
  }
</style>
"""

# ╔═╡ Cell order:
# ╟─cbad2e04-9d92-11eb-3d84-9da6f9a3c818
# ╠═3d4d751a-b972-4e88-b568-1f19f0f20564
# ╠═e95db99e-a9ec-437c-9557-4dec4f42926f
# ╟─26957ae3-1a74-4be7-b96e-d3292991a82a
# ╟─225ebbac-2232-47ff-b7dc-e2c59814f196
# ╠═3ab74396-3e42-4545-af0b-f5746345324d
# ╟─13a43945-1a9c-4526-9f63-03a306b8d459
# ╠═7e812f27-4129-48ba-b4f5-a49ddc4169ca
# ╟─3a0b11b9-a51e-47f1-833c-8c9a2e4d73ce
# ╠═5f3e9cc0-fb07-4f2d-be7c-590f13bbd03d
# ╟─1c0d74d4-aac6-4fa4-8957-84457c73107e
# ╠═668b9aac-454a-43a6-8c40-44a0c023129a
# ╠═23c79d73-3431-44c3-a4ef-4dd8337f7931
# ╟─ca585d7b-d7f1-48f6-ac88-10aa582b6dbe
# ╠═1289f7cf-6c2a-4b67-a817-3de3926d46ec
# ╟─dbc871c5-9ca9-432c-98f8-af386ebdb22e
# ╠═e4c7dc20-f703-4d56-9835-af4fdcb32668
# ╟─6d7d638a-93a5-4c40-8d60-899ccafb0cdc
# ╠═4a649215-b35b-4e5c-96ab-ee9808d2de8e
# ╟─9e89132b-ae35-4d85-ae98-15b1ea326991
# ╟─de978888-c378-46e9-8158-2cdbc1a6fe2f
# ╠═e31a7663-6705-450e-9100-346b8fe51e15
# ╟─8db4042d-fba1-4bb7-ba43-0acc718e1389
# ╟─5fc69267-810a-479c-acdf-6026ca901f64
# ╠═50e09727-5fb9-4f02-9a71-f2fa65eb19b9
# ╠═9ea51080-e3f8-4d70-a139-aa29ddf6d13b
# ╠═d55d2b3c-82cf-4328-9aee-279e839d0a92
# ╠═69c18f2f-7e22-4188-9464-9705f4aed7e3
# ╠═e4186b6a-2ee3-4fd7-b1a3-06a499aeaf07
# ╟─7f5d2d98-e170-46ff-a470-e7708cbe3fb3
# ╠═10a4ddbc-66c4-472d-999e-99838da6652d
# ╠═a65e9da9-0e8b-4356-820f-266eaba857c8
# ╟─09441471-d246-4511-8d8e-e941b1166159
# ╟─5855ee27-4d34-41e4-9881-70ad4b5f064e
# ╟─819af8d7-c242-4f7b-a61f-121263bdb54c
# ╠═35b8ad6d-7c5e-43bf-b014-ce24010a959a
# ╠═41a18e5c-7e01-4828-9df0-53d446da9eb1
# ╠═3ac25d84-b396-4341-956b-c550054038c0
# ╠═cd495081-805b-4e71-814a-10add9a65d03
# ╠═bcae0e95-22fc-4526-9c71-a186e20d5d8d
# ╠═032ddbf5-5995-4ff9-be43-3cfa16eaac91
# ╠═6887b10b-0c44-4a1a-bbe0-e08032ac1dff
# ╟─0c7ad5a2-e8b1-4189-82f5-d39cbc122d2d
# ╠═2c853e55-843c-43c8-87b4-9ef6810dc03d
# ╟─2484eca4-198c-4178-8b78-26ee246f786b
# ╠═902b8634-7cde-4808-9e77-c13caac19c8f
# ╠═53c34fd9-f9c4-4321-94f3-2e4a6c3cd70a
# ╠═e3ff7e20-c376-4bf7-b6da-0769551d5561
# ╠═92378e5b-c5e9-4a75-ae1e-216d67f4fd60
# ╠═240e86a4-4787-41ca-91ad-27893db438cc
# ╠═f9e6c472-3dfb-4617-a0ef-99d1cbd34427
# ╠═05e7f1ba-ac19-4160-b158-0ef83af00e89
# ╠═fab2cd7c-cecc-41a8-ab28-b71ba00fec95
# ╟─52eef2d7-27b5-418f-b432-64f8561472b3
# ╠═8102896d-c25a-4210-81e5-94195b44f9e3
# ╠═acbe6150-4732-48d5-a3cd-b695d3e0887c
# ╠═fdfabb92-3be3-4644-906a-eae308bdda0e
# ╠═7e4bcd5e-0378-4c18-941d-feddba9ae872
# ╠═c63aa4f9-79b3-4651-85b9-50cb97b6c7c5
# ╠═c5c2dd33-ad6e-451a-bbcc-12e84d0786b9
# ╟─b10fe2c1-b451-48c4-8088-c03c85d31ed1
