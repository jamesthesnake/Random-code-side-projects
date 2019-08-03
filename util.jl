using Makie: Scene, linesegments!
import AbstractPlotting
using GeometryTypes:Point3

function init(;kwargs...)
	s = Scene(;kwargs...)
	display(AbstractPlotting.PlotDisplay(), s);
	return s
end

function redisplay(s)
	display(AbstractPlotting.PlotDisplay(), s);
end

function triad!(scene, len; translation=(0f0,0f0,0f0), show_axis=false)
	ret = linesegments!(scene, [
			Point3(0,0,0) => Point3(len,0,0),
			Point3(0,0,0) => Point3(0,len,0),
			Point3(0,0,0) => Point3(0,0,len)], color=[:red, :green, :blue],
			linewidth=3, show_axis=show_axis)[end]
	translate!(ret, translation)
	return ret
end
