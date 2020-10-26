#using AlgebraicPetri
#const OpenLabelledReactionNetOb, OpenLabelledReactionNet =
 # OpenACSetTypes(LabelledReactionNet, :S)
#include("AlgebraicPetri.jl")
using AlgebraicPetri

using Catlab
const EpiRxnNet = LabelledReactionNet{Number,Int}
const OpenEpiRxnNet = OpenLabelledReactionNet{Number,Int}
const OpenEpiRxnNetOb = OpenLabelledReactionNetOb{Number,Int}

ob(x::Symbol,xn::Int) = codom(Open([x], EpiRxnNet(x=>xn), [x]))
function spontaneous_petri(transition::Symbol, rate::Number,
                         s::Symbol, s₀::Int,
                         t::Symbol, t₀::Int)
Open([s], EpiRxnNet((s=>s₀,t=>t₀), (transition,rate)=>(s=>t)), [t])
end
function exposure_petri(transition::Symbol, rate::Number,
                      s::Symbol, s₀::Int,
                      e::Symbol, e₀::Int,
                      t::Symbol, t₀::Int)
Open([s, e], EpiRxnNet((s=>s₀,e=>e₀,t=>t₀), (transition,rate)=>((s,e)=>(t,e))), [t])
end
recover = spontaneous_petri(:rec, .25, :I, 1, :R, 0)
expose = exposure_petri(:exp, .1, :S, 100, :I, 1, :E, 1)
print(expose)

using Catlab
using Catlab.Theories
sir=EpiRxnNet((:S=>100, :I=>1, :R=>0), (:inf,.03)=>((:S,:I)=>(:I,:I)), (:rec,.25)=>(:I=>:R))

@present Epidemiology(FreeBiproductCategory) begin
  (S, E, A, I, I2, R, R2, D)::Ob

  exposure_e::Hom(S⊗E,E)
  exposure_a::Hom(S⊗A,E)
  exposure_i::Hom(S⊗I,E)
  exposure_i2::Hom(S⊗I2,E)
  illness::Hom(E,I)
  illness_progression::Hom(I,I2)
  asymptomatic_illness::Hom(E,A)
  asymptomatic_recovery::Hom(A,R)
  illness_recovery::Hom(I2,R)
  recovery_progression::Hom(R,R2)
  death::Hom(I2,D)
end
using Catlab.Programs

coexist = @program Epidemiology (s::S, e::E, i::I, i2::I2, a::A, r::R, r2::R2, d::D) begin
    e_2 = exposure_e(s, e)
    e_3 = exposure_a(s, a)
    e_4 = exposure_i(s, i)
    e_5 = exposure_i2(s, i2)
    e_all = [e, e_2, e_3, e_4, e_5]
    a_2 = asymptomatic_illness(e_all)
    a_all = [a, a_2]
    r_2 = asymptomatic_recovery(a_all)
    i_2 = illness(e_all)
    i_all = [i, i_2]
    i2_2 = illness_progression(i)
    i2_all = [i2, i2_2]
    d_2 = death(i2_all)
    r_3 = illness_recovery(i2_all)
    r_all = [r, r_2, r_3]
    r2_2 = recovery_progression(r_all)
    r2_all = [r2, r2_2]
    d_all = [d, d_2]
    return s, e_all, i_all, i2_all, a_all, r_all, r2_all, d_all
end
@present EpiCrossExposure(FreeBiproductCategory) begin
    (S, E, A, I, I2, R, R2, D)::Ob
    (S′, E′, A′, I′, I2′, R′, R2′, D′)::Ob

    exposure_i::Hom(S⊗I′,E)
    exposure_e::Hom(S⊗E′,E)
    exposure_a::Hom(S⊗A′,E)
    exposure_i2::Hom(S⊗I2′,E)
    exposure_i′::Hom(S′⊗I,E′)
    exposure_e′::Hom(S′⊗E,E′)
    exposure_a′::Hom(S′⊗A,E′)
    exposure_i2′::Hom(S′⊗I2,E′)
end;

crossexposure = @program EpiCrossExposure (s::S, e::E, i::I, i2::I2, a::A, r::R, r2::R2, d::D,
                                           s′::S′, e′::E′, i′::I′, i2′::I2′, a′::A′, r′::R′, r2′::R2′, d′::D′) begin
    e_2 = exposure_i(s, i′)
    e_3 = exposure_i2(s, i2′)
    e_4 = exposure_a(s, a′)
    e_5 = exposure_e(s, e′)
    e_all = [e, e_2, e_3, e_4, e_5]
    e′_2 = exposure_i′(s′, i)
    e′_3 = exposure_i2′(s′, i2)
    e′_4 = exposure_a′(s′, a)
    e′_5 = exposure_e′(s′, e_all)
    e′_all = [e′, e′_2, e′_3, e′_4, e′_5]
    return s, e_all, i, i2, a, r, r2, d,
           s′, e′_all, i′, i2′, a′, r′, r2′, d′
end
@present DualCoexist(FreeBiproductCategory) begin
    (Pop1,Pop2)::Ob

    crossexp::Hom(Pop1⊗Pop2,Pop1⊗Pop2)
    coex1::Hom(Pop1,Pop1)
    coex2::Hom(Pop2,Pop2)
end;

dualCoexist = @program DualCoexist (pop1::Pop1, pop2::Pop2) begin
    pop1′, pop2′ = crossexp(pop1, pop2)
    return coex1(pop1′), coex2(pop2′)
end
