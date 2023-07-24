### A Pluto.jl notebook ###
# v0.19.42

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 709da6de-e873-4fa6-8065-9ac8c03be1b7
using PyCall, Conda, JolinPluto, PlutoUI, HypertextLiteral

# ╔═╡ 9b3e674f-d7e0-41f2-94fe-b884e3220f37
using DataFrames  # always place imports on their own line

# ╔═╡ 312dfe5a-0ff0-4a3f-907a-2d2c115e2754
begin
	Base.getindex(o::PyObject, s) = py"$o[$s]"
	Base.setindex!(o::PyObject, v, s) = py"$o[$s] = $v"
end

# ╔═╡ 60a06207-dc69-4694-9a62-d1eaabb0d9c8
md"""
hi
"""

# ╔═╡ 3fa2cf9e-eaa3-11ed-29ac-6de296b44861
md"""
# Python Dashboard

We  are going to look at CO2 data.

> 👉 3, 1, 2.  If you build your own dashboard later, remember that you can completely reorder the cells. For a dashboard this often makes sense in that the final plots and input elements could be moved to the top of the notebook.

Here we keep normal ordering so that it is easier to understand what goes on.
"""

# ╔═╡ 4f6fa5f9-0849-411a-8eee-ee9e636cb8b7
md"""
Enable indexing syntax for Python object.
"""

# ╔═╡ e11fa66a-7ec5-47de-b05e-e45227f36a46
@output_below

# ╔═╡ 976409d5-3ba3-4e85-ae1a-1308ff678303
TableOfContents()

# ╔═╡ b504e1e3-a358-4ba7-a72a-ef5d0cddc5ea
md"""
## Installing Python dependencies
"""

# ╔═╡ b80fc25b-9fcb-482e-91c2-2d731e5dca4c
md"""
PyCall.jl python dependencies are handled via Conda. Conda is awesome, as it gives you access to precompiled python packages, even for Linux ARM64 🙂.
"""

# ╔═╡ 8587f3ab-9563-491d-bae7-790688eb4283
Conda.add(["numpy", "pandas", "matplotlib", "plotly"])

# ╔═╡ afa20ae0-e7e0-46c8-9b96-3811feb33a78
md"""
Accessing python modules from reactive notebooks is best done via `PyCall.pyimport`, which binds the python package to a julia variable.
"""

# ╔═╡ a201edd1-0529-4ec1-b609-f571bace3627
begin
pd = pyimport("pandas")
plotly = pyimport("plotly")
plt = pyimport("matplotlib.pyplot")
end

# ╔═╡ 84ad50dd-f98e-41b2-a4d7-7e27d90d7931
md"""
## Calling Python from Pluto

Calling Python from Julia is like like using normal Julia. Or if you like, using Julia feels like using Python.

First a mere julia call to download the data.
"""

# ╔═╡ 0bc98db0-91a4-4c42-93ab-807d8c657ff6
datafile = download("https://nyc3.digitaloceanspaces.com/owid-public/data/co2/owid-co2-data.csv")

# ╔═╡ ceeec493-05b4-481a-bc2f-0788a39ab3cb
md"""
Now we call Python.
"""

# ╔═╡ 0d668fc3-aa02-462c-806b-5122c7f76f49
df = pd.read_csv(datafile)

# ╔═╡ 7b8dec72-c934-420a-9105-bcf137c68e67
df[df["country"] == "Germany"]

# ╔═╡ ebaddfcf-2ee3-4144-8ee7-a5fdb656f92a
md"""
Key python objects are autoconverted to and from julia. Others get wrapped into a `PyObject`.
"""

# ╔═╡ 08ecc631-9cb0-49ee-a310-6916b6dfca36
typeof(df)

# ╔═╡ 717650a9-a3e0-47e2-bb8a-105ad5c37125
df.columns

# ╔═╡ 2182213e-6159-4745-96db-79f612da2b66
md"""
Most julia functions work out of the box on these python objects
"""

# ╔═╡ fe706ad3-f39c-4c90-9fce-ef31879f0032
columns = collect(df.columns)

# ╔═╡ dbbf3043-94bc-490e-b48a-667e91b1a75b
countries = unique(df["country"])

# ╔═╡ 1bc2f0e4-42db-42c0-ab98-3b333fe46181
md"""
## Interactive visualizations

The reactivity comes from Pluto. The interactive widgets come from PlutoUI. The plotting happens on python side. Also plotly works awesomely. 
"""

# ╔═╡ 554db612-df7a-49d1-8b03-455ffea12881
md"""
### Input Widgets

Interactive input widgets use the `@bind` macro.
```julia
@bind country PlutoUI.Select(countries; default="World")
```
This lets the variable `country` listen for updates on the select input.

All these widgets can also be combined into markdown/html code using interpolation.
"""

# ╔═╡ 56d600b9-b02a-4982-bef8-7ae07632816d
choose = md"""
| Parameter | Choose |
| --------- | :----- |
| region 1 | $(@bind country1 PlutoUI.Select(countries; default="World")) |
| region 2 | $(@bind country2 PlutoUI.Select(countries; default="Germany")) |
| compare   | $(@bind yaxis PlutoUI.Select(columns; default="co2_per_capita")) |
"""

# ╔═╡ 0e0c377c-1ec8-4136-bd36-040caa69631a
(;yaxis, country1, country2)

# ╔═╡ 7dfc8421-d881-429a-81b4-daf31adae9b1
xaxis = "year"  # we fix the xaxis to be year

# ╔═╡ 0d22e8cb-6dfc-4778-b274-f1187381846c
subdf1 = df[df["country"] == country1];

# ╔═╡ 5de9257a-790c-404c-a05a-3c4ae377614b
subdf2 = df[df["country"] == country2]

# ╔═╡ 162713e1-7411-464b-a674-426fad2713dc
md"""
### Plotting using Matplotlib

Works seamlessly.
"""

# ╔═╡ b2206650-e3f4-4e18-88ce-7614e5c80638
begin
	figure, ax = plt.subplots()
	ax.plot(subdf1[xaxis], subdf1[yaxis], label=country1)
	ax.plot(subdf2[xaxis], subdf2[yaxis], color="orange", label=country2)
	ax.legend(loc="upper left")
	ax.set_xlabel(xaxis)
	ax.set_ylabel(yaxis)
end

# ╔═╡ a6268d19-45db-419d-8168-516cbc205190
choose

# ╔═╡ 1e66d44c-f750-4c3c-8d9d-709ebb45a979
figure.savefig("py_figure.png"); LocalResource("py_figure.png")

# ╔═╡ 7a9108c9-fb68-4680-a56c-de5cd770974c
md"""
### Plotly works too

We can make every matplotlib plot into a lovely interactive plotly plot.
"""

# ╔═╡ 92a4c56c-1072-4772-9fa2-de38f6cf3fdf
choose

# ╔═╡ 68ba199a-e41e-4738-9dc9-4557a0003452
plotly.tools.mpl_to_plotly(figure).update_layout(
	# enable responsive layout
	autosize=true, width=nothing, height=nothing,
	# reduce margins
	margin=py"{'l': 2, 'r':2, 't':24, 'b': 2}",
)

# ╔═╡ 97347c11-8200-4bf7-9329-8675d02e7a30
md"""
## Defining python functions and classes

For python things which are not easily mapped to julia syntax, there are string macros
- `py"..."` will eval the string as python code and return the result.
- `py\"\"\"... multiple lines ...\"\"\"` will exec the code (without returning anything).

> 😎 Using the dollar sign `$` we can bring julia variables or code to python. This is called interpolation.
"""

# ╔═╡ a15906a6-413e-459a-b10d-ca504f3df0eb
dict = py"{'number': int('3'), 'bool': $(isodd(3))}"

# ╔═╡ 0ae0a5c8-a2c8-4162-a4c7-61f9a263284b
md"""
When using multiline py strings, prefer not to use interpolation `$`, but make the python code as self-contained as possible.
"""

# ╔═╡ 4f5ba7e8-a147-46f2-8114-474db75e7ff5
begin
	py"""
	import numpy as np
	class PyTools:
		@staticmethod
		def sin(n):
			return np.sin(n)
	"""
	pytools = py"PyTools"
end

# ╔═╡ 6cb12ea6-ca09-42b8-850e-2fcdbdb745ba
pytools.sin(1)

# ╔═╡ 9f34091f-2f8d-41bd-82b2-0f0075613f71
md"""
> ⚠️ When using multiline py strings be careful:
> - variables defined in python, won't be available in other Pluto cells. You need to get them back to Pluto right away using single line py strings.
> - variables interpolated with `$` will be invalid when accessed in a new cell. For instance in the above example, we shall not define numpy on julia via `np = pyimport("numpy")` and then use `np` inside `PyTools` as `$np.sin(n)`, because when we call the `pytools.sin` function in another cell, the numpy reference won't work.
"""

# ╔═╡ 97d534c9-e0d5-4a65-9eda-531adb4afc36
md"""
## Final Tip
If you want to transfer a julia DataFrame to Python, you need to use `pairs(eachcol(df))`
"""

# ╔═╡ cc66dbda-f4fc-4da6-9239-55da358b94c6
begin
	julia_df = DataFrame(x=[1,2,3], y=["a", "b", "c"])
	python_df = pd.DataFrame(pairs(eachcol(julia_df)))
end

# ╔═╡ b27cd066-84e4-4e56-b9ae-864cb2fd50be
md"""
# Next
- [Our World in Data - CO2 Data](https://github.com/owid/co2-data) for more details on the data source
- [`PyCall.jl`](https://github.com/JuliaPy/PyCall.jl) for more details on the Python interface.
- [`Pandas.jl`](https://github.com/JuliaPy/Pandas.jl) for a julia wrapper for Python pandas, which builds on top of PyCall.jl, hence interacts well with this setup.
- [`PlutoUI.jl`](https://github.com/JuliaPluto/PlutoUI.jl) for more prebuilt input widgets.

Happy dashboarding 📈 📊!
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Conda = "8f4d0f93-b110-5947-807f-2305c1781a2d"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
JolinPluto = "5b0b4ef8-f4e6-4363-b674-3f031f7b9530"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
PyCall = "438e738f-606a-5dbb-bf0a-cddfbfd45ab0"

[compat]
Conda = "~1.9.0"
DataFrames = "~1.5.0"
HypertextLiteral = "~0.9.4"
JolinPluto = "~0.1.41"
PlutoUI = "~0.7.51"
PyCall = "~1.96.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.2"
manifest_format = "2.0"
project_hash = "df68946e46fa7dffaca75b00976be8386db3dba0"

[[deps.AWS]]
deps = ["Base64", "Compat", "Dates", "Downloads", "GitHub", "HTTP", "IniFile", "JSON", "MbedTLS", "Mocking", "OrderedCollections", "Random", "SHA", "Sockets", "URIs", "UUIDs", "XMLDict"]
git-tree-sha1 = "f3386c719e0096a61c7da0cb64a6b7f03cc3549f"
uuid = "fbe9abb3-538b-5e4e-ba9e-bc94f4f92ebc"
version = "1.90.0"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "43b1a4a8f797c1cddadf60499a8a077d4af2cd2d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.7"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "9c209fb7536406834aa938fb149964b985de6c83"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.1"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "4e88377ae7ebeaf29a047aa1ee40826e0b708a5d"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.7.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+0"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "96d823b94ba8d187a6d8f0826e731195a74b90e9"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.2.0"

[[deps.Conda]]
deps = ["Downloads", "JSON", "VersionParsing"]
git-tree-sha1 = "915ebe6f0e7302693bdd8eac985797dba1d25662"
uuid = "8f4d0f93-b110-5947-807f-2305c1781a2d"
version = "1.9.0"

[[deps.Continuables]]
deps = ["DataTypesBasic", "ExprParsers", "OrderedCollections", "SimpleMatch"]
git-tree-sha1 = "96107b5ecb77d0397395cec4a95a28873e124204"
uuid = "79afa230-ca09-11e8-120b-5decf7bf5e25"
version = "1.0.3"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "8da84edb865b0b5b0100c0666a9bc9a0b71c553c"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.15.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SentinelArrays", "SnoopPrecompile", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "aa51303df86f8626a962fccb878430cdb0a97eee"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.5.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "cf25ccb972fec4e4817764d01c82386ae94f77b4"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.14"

[[deps.DataTypesBasic]]
git-tree-sha1 = "0ebf9d9def6135849a9da8d2a1f144d0c467b81c"
uuid = "83eed652-29e8-11e9-12da-a7c29d64ffc9"
version = "2.0.3"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "e90caa41f5a86296e014e148ee061bd6c3edec96"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.9"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "4558ab818dcceaab612d1bb8c19cee87eda2b83c"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.5.0+0"

[[deps.ExprParsers]]
deps = ["ProxyInterfaces", "SimpleMatch", "StructEquality"]
git-tree-sha1 = "e9e5381d2fcc8726dab57002871c6cdfd221b40f"
uuid = "c5caad1f-83bd-4ce8-ac8e-4b29921e994e"
version = "1.2.1"

[[deps.ExprTools]]
git-tree-sha1 = "c1d06d129da9f55715c6c212866f5b1bddc5fa00"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.9"

[[deps.EzXML]]
deps = ["Printf", "XML2_jll"]
git-tree-sha1 = "0fa3b52a04a4e210aeb1626def9c90df3ae65268"
uuid = "8f5d6c58-4d21-5cfd-889c-e3ad7ee6a615"
version = "1.1.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.Git]]
deps = ["Git_jll"]
git-tree-sha1 = "51764e6c2e84c37055e846c516e9015b4a291c7d"
uuid = "d7ba0133-e1db-5d97-8f8c-041e4b3a1eb2"
version = "1.3.0"

[[deps.GitHub]]
deps = ["Base64", "Dates", "HTTP", "JSON", "MbedTLS", "Sockets", "SodiumSeal", "URIs"]
git-tree-sha1 = "5688002de970b9eee14b7af7bbbd1fdac10c9bbe"
uuid = "bc5e4493-9b4d-5f90-b8aa-2b2bcaad7a26"
version = "5.8.2"

[[deps.Git_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "LibCURL_jll", "Libdl", "Libiconv_jll", "OpenSSL_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "d8be4aab0f4e043cc40984e9097417307cce4c03"
uuid = "f8c6e375-362e-5223-8a59-34ff63f689eb"
version = "2.36.1+2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "7f5ef966a02a8fdf3df2ca03108a88447cb3c6f0"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.9.8"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "d75853a0bdbfb1ac815478bacd89cd27b550ace6"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.3"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "9cc2baf75c6d09f9da536ddf58eb2f29dedaf461"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InvertedIndices]]
git-tree-sha1 = "0dc7b50b8d436461be01300fd8cd45aa0274b038"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.0"

[[deps.IterTools]]
git-tree-sha1 = "4ced6667f9974fc5c5943fa5e2ef1ca43ea9e450"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.8.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JSON3]]
deps = ["Dates", "Mmap", "Parsers", "PrecompileTools", "StructTypes", "UUIDs"]
git-tree-sha1 = "5b62d93f2582b09e469b3099d839c2d2ebf5066d"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.13.1"

[[deps.JWTs]]
deps = ["Base64", "Downloads", "JSON", "MbedTLS", "Random"]
git-tree-sha1 = "a1f3ded6307ef85cc18dec93d9b993814eb4c1a0"
uuid = "d850fbd6-035d-5a70-a269-1ca2e636ac6c"
version = "0.2.2"

[[deps.JolinPluto]]
deps = ["AWS", "Base64", "Continuables", "Dates", "Git", "HTTP", "HypertextLiteral", "JSON3", "JWTs"]
git-tree-sha1 = "34a5124646ef22914488ffcf9a1f5accf73de262"
uuid = "5b0b4ef8-f4e6-4363-b674-3f031f7b9530"
version = "0.1.41"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c7cb1f5d892775ba13767a87c7ada0b980ea0a71"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+2"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "cedb76b37bc5a6c702ade66be44f831fa23c681e"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.0.0"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "f66bdc5de519e8f8ae43bdc598782d35a25b1272"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.1.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.Mocking]]
deps = ["Compat", "ExprTools"]
git-tree-sha1 = "4cc0c5a83933648b615c36c2b956d94fda70641e"
uuid = "78c3b35d-d492-501b-9361-3d52fe80e533"
version = "0.7.7"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "51901a49222b09e3743c65b8847687ae5fc78eb2"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.4.1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1aa4b74f80b01c6bc2b89992b861b5f210e665b5"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.21+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "d321bf2de576bf25ec4d3e4360faca399afca282"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.0"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.42.0+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "4b2e829ee66d4218e0cef22c0a64ee37cf258c29"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.7.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.2"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "b478a748be27bd2f2c73a7690da219d0844db305"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.51"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "9673d39decc5feece56ef3940e5dafba15ba0f81"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.1.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "7eb1686b4f04b82f96ed7a4ea5890a4f0c7a09f1"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.0"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "LaTeXStrings", "Markdown", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "213579618ec1f42dea7dd637a42785a608b1ea9c"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.4"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.ProxyInterfaces]]
git-tree-sha1 = "855c7edf5ea975fa546e3acc30084bcc8e9e1927"
uuid = "9b3bf0c4-f070-48bc-ae01-f2584e9c23bc"
version = "1.0.1"

[[deps.PyCall]]
deps = ["Conda", "Dates", "Libdl", "LinearAlgebra", "MacroTools", "Serialization", "VersionParsing"]
git-tree-sha1 = "43d304ac6f0354755f1d60730ece8c499980f7ba"
uuid = "438e738f-606a-5dbb-bf0a-cddfbfd45ab0"
version = "1.96.1"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "04bdff0b09c65ff3e06a05e3eb7b120223da3d39"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.SimpleMatch]]
git-tree-sha1 = "78750b67a6cb3b6140be99f2fb56ae26ad28104b"
uuid = "a3ae8450-d22f-11e9-3fe0-77240e25996f"
version = "1.1.0"

[[deps.SnoopPrecompile]]
deps = ["Preferences"]
git-tree-sha1 = "e760a70afdcd461cf01a575947738d359234665c"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SodiumSeal]]
deps = ["Base64", "Libdl", "libsodium_jll"]
git-tree-sha1 = "80cef67d2953e33935b41c6ab0a178b9987b1c99"
uuid = "2133526b-2bfb-4018-ac12-889fb3908a75"
version = "0.1.1"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "c60ec5c62180f27efea3ba2908480f8055e17cee"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.1.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.9.0"

[[deps.StringManipulation]]
git-tree-sha1 = "46da2434b41f41ac3594ee9816ce5541c6096123"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.0"

[[deps.StructEquality]]
deps = ["Compat"]
git-tree-sha1 = "192a9f1de3cfef80ab1a4ba7b150bb0e11ceedcf"
uuid = "6ec83bb0-ed9f-11e9-3b4c-2b04cb4e219c"
version = "2.1.0"

[[deps.StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "ca4bccb03acf9faaf4137a9abc1881ed1841aa70"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.10.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

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
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "1544b926975372da01227b382066ab70e574a3ec"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "9a6ae7ed916312b41236fcef7e0af564ef934769"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.13"

[[deps.Tricks]]
git-tree-sha1 = "aadb748be58b492045b4f56166b5188aa63ce549"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.7"

[[deps.URIs]]
git-tree-sha1 = "074f993b0ca030848b897beff716d93aca60f06a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.2"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.VersionParsing]]
git-tree-sha1 = "58d6e80b4ee071f5efd07fda82cb9fbe17200868"
uuid = "81def892-9a0e-5fdd-b105-ffc91e053289"
version = "1.3.0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "93c41695bc1c08c46c5899f4fe06d6ead504bb73"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.10.3+0"

[[deps.XMLDict]]
deps = ["EzXML", "IterTools", "OrderedCollections"]
git-tree-sha1 = "d9a3faf078210e477b291c79117676fca54da9dd"
uuid = "228000da-037f-5747-90a9-8195ccbf91a5"
version = "0.4.1"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+0"

[[deps.libsodium_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "848ab3d00fe39d6fbc2a8641048f8f272af1c51e"
uuid = "a9144af2-ca23-56d9-984f-0d03f7b5ccf8"
version = "1.0.20+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╠═60a06207-dc69-4694-9a62-d1eaabb0d9c8
# ╟─3fa2cf9e-eaa3-11ed-29ac-6de296b44861
# ╠═709da6de-e873-4fa6-8065-9ac8c03be1b7
# ╟─4f6fa5f9-0849-411a-8eee-ee9e636cb8b7
# ╠═312dfe5a-0ff0-4a3f-907a-2d2c115e2754
# ╠═e11fa66a-7ec5-47de-b05e-e45227f36a46
# ╠═976409d5-3ba3-4e85-ae1a-1308ff678303
# ╟─b504e1e3-a358-4ba7-a72a-ef5d0cddc5ea
# ╟─b80fc25b-9fcb-482e-91c2-2d731e5dca4c
# ╠═8587f3ab-9563-491d-bae7-790688eb4283
# ╟─afa20ae0-e7e0-46c8-9b96-3811feb33a78
# ╠═a201edd1-0529-4ec1-b609-f571bace3627
# ╟─84ad50dd-f98e-41b2-a4d7-7e27d90d7931
# ╠═0bc98db0-91a4-4c42-93ab-807d8c657ff6
# ╟─ceeec493-05b4-481a-bc2f-0788a39ab3cb
# ╠═0d668fc3-aa02-462c-806b-5122c7f76f49
# ╠═7b8dec72-c934-420a-9105-bcf137c68e67
# ╟─ebaddfcf-2ee3-4144-8ee7-a5fdb656f92a
# ╠═08ecc631-9cb0-49ee-a310-6916b6dfca36
# ╠═717650a9-a3e0-47e2-bb8a-105ad5c37125
# ╟─2182213e-6159-4745-96db-79f612da2b66
# ╠═fe706ad3-f39c-4c90-9fce-ef31879f0032
# ╠═dbbf3043-94bc-490e-b48a-667e91b1a75b
# ╟─1bc2f0e4-42db-42c0-ab98-3b333fe46181
# ╟─554db612-df7a-49d1-8b03-455ffea12881
# ╠═56d600b9-b02a-4982-bef8-7ae07632816d
# ╠═0e0c377c-1ec8-4136-bd36-040caa69631a
# ╠═7dfc8421-d881-429a-81b4-daf31adae9b1
# ╠═0d22e8cb-6dfc-4778-b274-f1187381846c
# ╠═5de9257a-790c-404c-a05a-3c4ae377614b
# ╟─162713e1-7411-464b-a674-426fad2713dc
# ╠═b2206650-e3f4-4e18-88ce-7614e5c80638
# ╠═a6268d19-45db-419d-8168-516cbc205190
# ╠═1e66d44c-f750-4c3c-8d9d-709ebb45a979
# ╟─7a9108c9-fb68-4680-a56c-de5cd770974c
# ╠═92a4c56c-1072-4772-9fa2-de38f6cf3fdf
# ╠═68ba199a-e41e-4738-9dc9-4557a0003452
# ╟─97347c11-8200-4bf7-9329-8675d02e7a30
# ╠═a15906a6-413e-459a-b10d-ca504f3df0eb
# ╟─0ae0a5c8-a2c8-4162-a4c7-61f9a263284b
# ╠═4f5ba7e8-a147-46f2-8114-474db75e7ff5
# ╠═6cb12ea6-ca09-42b8-850e-2fcdbdb745ba
# ╟─9f34091f-2f8d-41bd-82b2-0f0075613f71
# ╟─97d534c9-e0d5-4a65-9eda-531adb4afc36
# ╠═9b3e674f-d7e0-41f2-94fe-b884e3220f37
# ╠═cc66dbda-f4fc-4da6-9239-55da358b94c6
# ╟─b27cd066-84e4-4e56-b9ae-864cb2fd50be
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
