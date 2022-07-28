Using Linear Algebra to Convert a Large Code Model
Background
The SalesForce CodeGen models are a family of large language models trained on a large amount of natural language data and then fine-tuned on specialized datasets of code. Models of size 350M, 2B, 6B, and 16B parameters are provided in three flavors:

nl, the base model trained on The Pile, a large natural language dataset compiled by EleutherAI
multi, which is fine-tuned from the nl model on a dataset of code in multiple languages, scraped from GitHub, and
mono, which is fine-tuned from the multi model on Python code only.
You can read more about them in the SalesForce paper, A Conversational Paradigm for Program Synthesis. The largest Python model, codegen-16B-mono, slightly outperforms Codex on the HumanEval code generation benchmark. Overall these are very nice, high-quality code models!

In terms of architecture, the CodeGen models are almost identical to GPT-J, an architecture developed by EleutherAI (the only difference is the subject of the rest of this article). GPT-J itself is very similar to GPT-2, but with a few enhancements like using rotary positional embeddings and computing the attention and feed-forward portions of the basic Transformer block in parallel rather than sequentially.

The really cool thing about the CodeGen models is that SalesForce has released ther weights, meaning anyone can download and run them locally, and fine-tune them for new languages and other situations. The largest model, at 16B parameters, requires around 32GB of GPU memory at 16-bit (FP16) precision, so you need a fairly high-end GPU like an A6000, but it's still within reach of an individual or hobbyist.

Motivation
I would love to be able to run CodeGen models locally and fast, ideally fast enough that they can be used for interactive tasks like code completion. In other words, I want to be able to run them quickly enough to have my own local version of GitHub Copilot on my trusty pair of A6000 GPUs.

I also want to explore fine-tuning of the CodeGen models, perhaps to make them better at writing secure code (in our paper last year, we found that GitHub Copilot often generates insecure code -- around 40% of the time, in security-sensitive scenarios), or to support new langauges or even new tasks like code summarization or reverse engineering.

The Problem
GPT-J is a very popular model and a lot of work has been put into making fast implementations, like the one in FasterTransformers. There are also lots of excellent frameworks and guides for fine-tuning GPT-J.

Unfortunately, these don't work with CodeGen. Even though the two are 99.9% identical, they're just different enough that you can't naively transfer over the CodeGen weights and run them in a GPT-J implementation.

Conversion
GPT-J uses separate q_proj, v_proj, k_proj matrices for the initial projection (after LayerNorm), whereas CodeGen combines these into a single qkv_proj. But this isn't itself a problem because given the Q, K, and V projections, we have:

Q(x) || V(x) || K(x) == QKV(x)
However, CodeGen slices up the QKV output slightly differently. It does:

qkv = self.qkv_proj(hidden_states)
# TODO(enijkamp): factor out number of logical TPU-v4 cores or make forward pass agnostic
mp_num = 4
qkv_split = qkv.reshape(qkv.shape[:-1] + (mp_num, -1))

local_dim = self.embed_dim // mp_num
query, value, key = torch.split(qkv_split, local_dim, dim=-1)
This is a little hard to understand so let's visualize it on a tiny example. Let's set the embedding dimension D to 4 (it has to be a multiple of 4 because mp_num, the number of logical TPU-v4 cores, is 4). The vector that comes out of the QKV projection is of length 3*D, so let's visualize it as:

[A1][A2][A3][B1][B2][B3][C1][C2][C3][D1][D2][D3]
Here, each [ ] is of size local_dim (D/4, or 1 in our example). Then qkv_split is:

[A1][A2][A3]
[B1][B2][B3]
[C1][C2][C3]
[D1][D2][D3]
The torch.split(qkv_split, local_dim, dim=-1) splits this column-wise into three pieces. And so Q, V, K are (for CodeGen):

Q: [A1][B1][C1][D1]
V: [A2][B2][C2][D2]
K: [A3][B3][C3][D3]
Meanwhile with GPT-J it forms Q, V, and K as:

Q: [A1][A2][A3][B1]
V: [B2][B3][C1][C2]
K: [C3][D1][D2][D3]
So as you can see, this leads to different values of Q, K, and V between GPT-J and CodeGen. But importantly, the values are the same, just rearranged! Maybe we can find a way to rearrange the weights of qkv_proj so that when used with GPT-J, Q, K, and V come out to what they would have been with CodeGen? It turns out we can!

If you compare the two QKV matrices above, you can see that the output of the QKV projection needs to be rearranged like so:

Before:  [A1][A2][A3][B1][B2][B3][C1][C2][C3][D1][D2][D3]
Indices:  00  01  02  03  04  05  06  07  08  09  10  11
After:   [A1][B1][C1][D1][A2][B2][C2][D2][A3][B3][C3][D3]
The projection is computed as xA^T, where x is the hidden state vector and A^T is the transpose of the qkv_proj weight matrix. So if we think back to linear algebra, we might remember that vM, where v is a vector and M is a matrix, is equivalent to doing dot products [v . c_1, v . c_2, ..., v . c_N], where each c_i is a column of M. This means that we can rearrange our output vector by just rearranging the columns of A^T, or, equivalently, the rows of qkv_proj!

How should we rearrange it? We can read the permutation directly off the Before/After figure above. We just look at each element in "After", look up its index in "Before", and that's our permutation:

base_permutation = [0, 3, 6, 9, 1, 4, 7, 10, 2, 5, 8, 11]
That's fine for D=4, but of course the real models are much bigger; the CodeGen 16B model has D=6144! But luckily we just need to scale up our basic permutation here, remembering that each element is of size local_dim:

permutation = torch.cat([torch.arange(i*local_dim, (i+1)*local_dim) for i in base_permutation])
And then we just apply that permutation to the rows of the qkv_proj weight matrix:

new_qkv_proj = qkv_proj[permutation,:]
This new QKV projection, when used with GPT-J, will give the exact results as the old QKV projection did under CodeGen!

Conclusion
So with a little bit of linear algebra I was able to convert the CodeGen models to work in GPT-J! The most immediate benefit is that I was then able to load the converted weights into FasterTransformers! The speedup is pretty nice: whereas the original HuggingFace-based CodeGen implementation takes 12 seconds to generate 128 tokens, FasterTransformers can do it in 5.7 seconds on a single A6000 GPU (and further speedups may be possible with multi-GPU). This is not quite as fast as Codex, the model that powers Copilot (1.3 seconds), but it's getting near enough to be useful for code completion!

You can see the final conversion script here: https://gist.github.com/moyix/0f37da9c21c4ddfa0ab39ddad1639db4
