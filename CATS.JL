using AbstractPlotting
 using FileIO, GLMakie
#make a cat
 scene = Scene(resolution = (500, 500))
 catmesh = FileIO.load(GLMakie.assetpath("cat.obj"), GLNormalUVMesh)
 mesh(catmesh, color = GLMakie.loadasset("diffusemap.tga"))
