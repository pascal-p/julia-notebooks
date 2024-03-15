"""
Web extraction primitives given a root from which to start and some selectors.
"""
# using Cascadia  # Called in Pluto
# using AbstractTrees

function traverse_article_structure(root; selector="p.pw-post-body-paragraph")
  for (ix, element) ∈ enumerate(eachmatch(Selector(selector), root))
    print("ix: $(ix)")

    :text ∉ propertynames(element) && println(" current element [$(tag(element))] has $(length(element.children)) child(ren)")
    if hasproperty(element, :children)
      for child ∈ element.children
        :text ∉ propertynames(child) && print("\t", tag(child), " | ", propertynames(child))
      end
      println()
    end

  end
end

# PreOrderDFS from AbstractTrees
# for elem ∈ PreOrderDFS(_root.children[1])  # main
#   try
#     if tag(elem) == :p
#       # println(elem.children[1])
#       println(AbstractTrees.children(elem)[1])
#       println("\t", AbstractTrees.children(elem)[2])
#     end
#   catch
#     # Nothing needed here
#   end
# end

"""
Principle:
 1. (crude) take a (relative) root element and extract the text from all children
 2. take a (relative) root element and extract the text from selected  children of interest (which sub tag then?)
"""
function extract_content(
  root;
  selectors=["p.nx-mt-6"],
  detect_code=false,
  verbose=true,
  only_tags=[:p, :h1, :h2, :h3, :li, :ul, :ol, :span]
)::String

  fulltext = String[]
  sel_vec = _get_selectors(root, selectors)

  iscode = false
  pattern = split(selectors[1], ".")[end]

  for (ix, element) ∈ enumerate(sel_vec)
    verbose &&  println("$(ix) - [$(element)] /// [$(element.attributes["class"])]")

    iscode = detect_code && hasproperty(element, :attributes) &&
      !occursin(pattern, element.attributes["class"])

    if hasproperty(element, :children)
      println("Proc. elem tag: $(tag(element)) | attr: $(element.attributes)")

      text = dft(element.children, only_tags)
      text = iscode ? string("```code\n", text, "\n```") : text

      push!(fulltext, text)
    end

    iscode = false
  end

  join(
    filter(
      l -> length(strip(l)) > 0,
      fulltext
    ),
    "\n"
  )
end

"""
Extract links fro ma given web page starting at root element
"""
function extract_links(
  root;
  selectors=["a"], verbose=true,
  restrict_to=["github", "LinkedIn"],
  excluding_regex=r"signin\?|policy\.medium\.com|followers\?|help\.medium|medium.com/(?:\?source|search\?|@)|work\-at\-medium|com/about"i,
  only_tags=[:a]
)::Vector{Tuple{String, String}}

  links = Tuple{String, String}[]
  sel_vec = _get_selectors(root, selectors)
  for element ∈ sel_vec
    if hasproperty(element, :attributes)
      if match(join(restrict_to, "|") |> p -> Regex(p, "i"), element.attributes["href"]) !== nothing
        push!(
          links,
          (element.attributes["href"], dft(element.children, only_tags))
        )
      end
    end
  end

  # remove if link contains "signin?" or "policy..."
  filter(
    tupl -> match(excluding_regex, tupl[1]) === nothing,
    links
  )
end

_get_selectors(root, selectors::Vector) = vcat((eachmatch(Selector(selector), root) for selector ∈ selectors)...)

"""
  depth first traversal
"""
function dft(v_elt::Vector{<: Any}, only_tags::Vector{Symbol})::String
  vtext = String[]

  function _dft(v_elt::Vector{<: Any})
    for elt ∈ v_elt
      # :text ∉ propertynames(elt) && println("\tProc elem tag: $(tag(elt))")  # text element are not callable with tag()
      :text ∉ propertynames(elt) && tag(elt) ∉ only_tags && continue

      hasproperty(elt, :children) && _dft(elt.children)

      if hasproperty(elt, :text)
        txt = strip(elt.text)
        push!(vtext, txt)
      end

    end
    vtext
  end

  _dft(v_elt) |> v -> join(v, "\n")
end
