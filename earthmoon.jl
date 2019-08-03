# Simple animation of earth rotating and moon orbiting earth with stars in background
using Makie
using AbstractPlotting
using AbstractPlotting: textslider
using FileIO
using StaticArrays
using GeometryTypes
using LinearAlgebra

include("util.jl")

rearth_km = 6371.1f0
mearth_kg = 5.972e24
rmoon_km = 1738.1f0
mmoon_kg = 7.34e22
rship_km = 500f0
mship_kg = 1000.0
dbetween_km = 378_000.0f0
radius_mult = 1.0f0
vship_mps = [0.0, 0.0, 0.0]
timestep = 1.0f0

const Vec3f = SVector{3,Float32}

mutable struct Ship
	mass_kg::Float32
	position_m::Vec3f
	velocity_mps::Vec3f
	color::Symbol
	mesh::AbstractPlotting.Mesh
end

function Base.show(io::IO, s::Ship)
   println(io, "Ship with mass: $(s.mass_kg), position: $(s.position_m), velocity: $(s.velocity_mps)")
end

function moveto!(ship::Ship, (x, y, z))
	ship.position_m = Vec3f(x, y, z)
	translate!(ship.mesh, (x, y, z))
	ship.position_m, ship.velocity_mps
end

ships = Vector{Ship}()

function orbit(r; steps=80)
	return [Point3f0(r*cos(x), r*sin(x), 0) for x in range(0, stop=2pi, length=steps)]
end

function loadordownload(localfname, url)
	return isfile(localfname) ? load(localfname) : load(download(url, localfname))
end

# http://corysimon.github.io/articles/uniformdistn-on-sphere/
function makestars(n)
	stars = Array{Point{3,Float64},1}()
	for i = 1:n
		global v = [0, 0, 0]  # initialize so we go into the while loop
		while norm(v) < .0001
			global v
			x = randn()  # random standard normal
			y = randn()
			z = randn()
			v = Point(x, y, z)
		end
		v = v / norm(v)  # normalize to unit norm
		push!(stars, v)
	end
	return stars
end

function makecontrols()
	orbit_slider, orbit_speed = textslider(0f0:10f0, "Speed", start=1.0)
	scale_slider, scale = textslider(1f0:20f0, "Scale", start=10.0)
	#btn = button!(s, "Foo", show_axis=false)[end]
	return orbit_slider, orbit_speed, scale_slider, scale
end

function makescene()
	s = Scene(backgroundcolor=:black, show_axis=false)
	AbstractPlotting.__init__()
	display(s)
	return s
end

function makeships(N)
	ships = Vector{Ship}()
	for i = 1:N
		sm = mesh!(scene, Sphere(Point3f0(0), rship_km*radius_mult), color=:green, show_axis=false)[end]
		ship = Ship(mship_kg, [0, 0, 0], [0, 0, 0], :green, sm)
		moveto!(ship, (100000f0 * randn(Float32), dbetween_km/2 + randn(Float32) * 50000f0, 50000f0*randn(Float32)))
		ship.velocity_mps = [40000*randn(Float32), -1000*randn(Float32), 1000*randn(Float32)]
		push!(ships, ship)
	end
	return ships
end

function makeobjects()
	earthfname = "bluemarble-2048.png"
	earthurl = "https://svs.gsfc.nasa.gov/vis/a000000/a002900/a002915/" * earthfname
	earthbitmap = loadordownload(earthfname, earthurl)
	earth = mesh!(scene, Sphere(Point3f0(0), rearth_km*radius_mult), color=earthbitmap, show_axis=false)[end]

	moonfname = "phases.0001_print.jpg"
	moonurl = "https://svs.gsfc.nasa.gov/vis/a000000/a004600/a004675/" * moonfname
	moonbitmap = loadordownload(moonfname, moonurl)
	moon = mesh!(scene, Sphere(Point3f0(0), rmoon_km*radius_mult), color=moonbitmap, show_axis=false)[end]
	moon.transformation.translation[] = [0, dbetween_km, 0]

	orb = lines!(scene, orbit(dbetween_km), color=:gray, show_axis=false)

	#stars = meshscatter!(1000000*makestars(1000), color=:white, show_axis=false, markersize=1000)

	return earth, moon #, stars#, ships
end

function spin(scene, orbit_speed, scale)
	try
		update_cam!(scene, [1.3032e5, 7.12119e5, 3.60022e5], [0, 0, 0])
		global θ = 0.0
		while true
			global θ
			scale!(moon, (scale[], scale[], scale[]))
			scale!(earth, (scale[], scale[], scale[]))
			for ship in ships
				scale!(ship.mesh, (scale[], scale[], scale[]))
			end
			#moon.transformation.translation[] = dbetween_km*[-sin(θ/28), cos(θ/28), 0]
			translate!(moon, SVector(-dbetween_km*sin(θ/28), dbetween_km*cos(θ/28), 0))
			earth.transformation.rotation[] = qrotation(SVector(0, 0, 1), θ)
			moon.transformation.rotation[] = qrotation(SVector(0, 0, 1), π/2 + θ/28)
			ep = scene.camera.eyeposition[]
			eyedistance = norm(ep[1:2])
			ednew = moon.transformation.translation[] * 2
			#ednew[3] = ep[3]
			# ednew = [eyedistance*sin(θ/50), eyedistance*cos(θ/50), ep[3]]
			#update_cam!(scene, [ednew[1:2]; ep[3]], moon.transformation.translation[])
			#update_cam!(scene, ep, translation(earth)[])
			sleep(0.01)
			yield()
			θ += 0.05 * orbit_speed[]
			global timestep = 10*orbit_speed[]
			gravity()
		end
	catch e
		println("Caught exception inside spin")
		rethrow()
		return
	end
end
function gravity()
	for ship in ships
		rship = ship.position_m #translation(ship)[]
		rearth = translation(earth)[]
		rmoon = translation(moon)[]
		rship_earth = (rearth - rship) * 1e3 # convert to m
		rship_moon = (rmoon - rship) * 1e3 # convert to m
		G = 6.67408e-11 # m^3⋅kg^-2⋅s^-1
		nrship_earth = max(0.1, norm(rship_earth))
		nrship_moon = max(0.1, norm(rship_moon))
		fearth = G * (mship_kg * mearth_kg)/(nrship_earth^2) * rship_earth/nrship_earth
		fmoon = G * (mship_kg * mmoon_kg)/(nrship_moon^2) * rship_earth/nrship_earth
		ftot = fearth + fmoon
		#@show fearth, fmoon, ftot
		ship.velocity_mps += timestep * ftot
		drship = timestep * ship.velocity_mps / 1e3
		#@show drship
		rship = rship + drship
		moveto!(ship, rship)
		#@show ship
	end
end

function layout()
	parent = vbox(hbox(controls...), scene)
	return parent
end

function main()
	global scene = init(backgroundcolor=:black, show_axis=false, resolution=(2048,1024))
	global ships = makeships(600)
	global earth, moon = makeobjects();
	orbit_slider, orbit_speed, scale_slider, scale = makecontrols();
	global controls = (orbit_slider, scale_slider);
	parent = layout()
	redisplay(parent)
	spin(scene, orbit_speed, scale)
end

main()
