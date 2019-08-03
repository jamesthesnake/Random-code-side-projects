using Combinatorics, Polyhedra,CDDLib
using MeshCat
using Makie
v = vrep(collect(permutations([0, 1, 2, 3])))
p4 = polyhedron(v, CDDLib.Library())
v1 = [1, -1,  0,  0]
v2 = [1,  1, -2,  0]
v3 = [1,  1,  1, -3]
p3 = project(p4, [v1 v2 v3])
m = Polyhedra.Mesh(p3);
vis = Visualizer()
setobject!(vis, m)
IJuliaCell(vis)
mesh(m, color=:blue)
#wireframe(m)
