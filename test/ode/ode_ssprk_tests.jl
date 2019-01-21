using OrdinaryDiffEq, DiffEqDevTools, Test, Random
using DiffEqProblemLibrary.ODEProblemLibrary: importodeproblems; importodeproblems()
import DiffEqProblemLibrary.ODEProblemLibrary: prob_ode_linear, prob_ode_2Dlinear, prob_ode_bigfloat2Dlinear

Random.seed!(100)

dts = 1 .//2 .^(8:-1:4)
testTol = 0.25

f = (u,p,t)->cos(t)
(::typeof(f))(::Type{Val{:analytic}},u0,p,t) = sin(t)
prob_ode_sin = ODEProblem(f, 0.,(0.0,1.0))

f = (du,u,p,t)->du[1]=cos(t)
(::typeof(f))(::Type{Val{:analytic}},u0,p,t) = [sin(t)]
prob_ode_sin_inplace = ODEProblem(f, [0.], (0.0,1.0))

f = (u,p,t)->sin(u)
(::typeof(f))(::Type{Val{:analytic}},u0,p,t) = 2*acot(exp(-t)*cot(0.5))
prob_ode_nonlinear = ODEProblem(f, 1.,(0.,0.5))

f = (du,u,p,t)->du[1]=sin(u[1])
(::typeof(f))(::Type{Val{:analytic}},u0,p,t) = [2*acot(exp(-t)*cot(0.5))]
prob_ode_nonlinear_inplace = ODEProblem(f,[1.],(0.,0.5))

test_problems_only_time = [prob_ode_sin, prob_ode_sin_inplace]
test_problems_linear = [prob_ode_linear, prob_ode_2Dlinear, prob_ode_bigfloat2Dlinear]
test_problems_nonlinear = [prob_ode_nonlinear, prob_ode_nonlinear_inplace]

f_ssp = (u,p,t) -> begin
  sin(10t) * u * (1-u)
end
test_problem_ssp = ODEProblem(f_ssp, 0.1, (0., 8.))
test_problem_ssp_long = ODEProblem(f_ssp, 0.1, (0., 1.e3))

f_ssp_inplace = (du,u,p,t) -> begin
  @. du = sin(10t) * u * (1-u)
end
test_problem_ssp_inplace = ODEProblem(f_ssp_inplace, rand(3,3), (0., 8.))


# test SSP coefficient for explicit Euler
alg = Euler()
sol = solve(test_problem_ssp_long, alg, dt=OrdinaryDiffEq.ssp_coefficient(alg), dense=false)
@test all(sol.u .>= 0)
sol = solve(test_problem_ssp_long, alg, dt=OrdinaryDiffEq.ssp_coefficient(alg)+1.e-3, dense=false)
@test any(sol.u .< 0)


alg = SSPRK22()
for prob in test_problems_only_time
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
for prob in test_problems_linear
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
for prob in test_problems_nonlinear
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
# test SSP coefficient
sol = solve(test_problem_ssp_long, alg, dt=OrdinaryDiffEq.ssp_coefficient(alg), dense=false)
@test all(sol.u .>= 0)
# test SSP property of dense output
sol = solve(test_problem_ssp, alg, dt=1.)
@test mapreduce(t->all(0 .<= sol(t) .<= 1), (u,v)->u&&v, range(0, stop=8, length=50), init=true)
sol = solve(test_problem_ssp_inplace, alg, dt=1.)
@test mapreduce(t->all(0 .<= sol(t) .<= 1), (u,v)->u&&v, range(0, stop=8, length=50), init=true)


alg = SSPRK33()
for prob in test_problems_only_time
  sim = test_convergence(dts, prob, alg)
  # This corresponds to Simpson's rule; due to symmetric quadrature nodes,
  # it is of degree 4 instead of 3, as would be expected.
  @test abs(sim.𝒪est[:final]-1-OrdinaryDiffEq.alg_order(alg)) < testTol
end
for prob in test_problems_linear
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
for prob in test_problems_nonlinear
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
# test SSP coefficient
sol = solve(test_problem_ssp_long, alg, dt=OrdinaryDiffEq.ssp_coefficient(alg), dense=false)
@test all(sol.u .>= 0)
# test SSP property of dense output
sol = solve(test_problem_ssp, alg, dt=1.)
@test mapreduce(t->all(0 .<= sol(t) .<= 1), (u,v)->u&&v, range(0, stop=8, length=50), init=true)
sol = solve(test_problem_ssp_inplace, alg, dt=1.)
@test mapreduce(t->all(0 .<= sol(t) .<= 1), (u,v)->u&&v, range(0, stop=8, length=50), init=true)


alg = SSPRK53()
for prob in test_problems_only_time
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
for prob in test_problems_linear
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
for prob in test_problems_nonlinear
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
# test SSP coefficient
sol = solve(test_problem_ssp_long, alg, dt=OrdinaryDiffEq.ssp_coefficient(alg), dense=false)
@test all(sol.u .>= 0)


alg = SSPRK53_2N1()
for prob in test_problems_only_time
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
for prob in test_problems_linear
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
for prob in test_problems_nonlinear
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
# test SSP coefficient
sol = solve(test_problem_ssp_long, alg, dt=OrdinaryDiffEq.ssp_coefficient(alg), dense=false)
@test all(sol.u .>= 0)

# for SSPRK53_2N2 to be in asymptotic range
dts = 1 .//2 .^(9:-1:5)
alg = SSPRK53_2N2()
for prob in test_problems_only_time
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
for prob in test_problems_linear
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
for prob in test_problems_nonlinear
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
# test SSP coefficient
sol = solve(test_problem_ssp_long, alg, dt=OrdinaryDiffEq.ssp_coefficient(alg), dense=false)
@test all(sol.u .>= 0)

#reverting back to original dts
dts = 1 .//2 .^(8:-1:4)
alg = SSPRK63()
for prob in test_problems_only_time
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
for prob in test_problems_linear
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
for prob in test_problems_nonlinear
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
# test SSP coefficient
sol = solve(test_problem_ssp_long, alg, dt=OrdinaryDiffEq.ssp_coefficient(alg), dense=false)
@test all(sol.u .>= 0)


alg = SSPRK73()
for prob in test_problems_only_time
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
for prob in test_problems_linear
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
for prob in test_problems_nonlinear
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
# test SSP coefficient
sol = solve(test_problem_ssp_long, alg, dt=OrdinaryDiffEq.ssp_coefficient(alg), dense=false)
@test all(sol.u .>= 0)


alg = SSPRK83()
for prob in test_problems_only_time
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
for prob in test_problems_linear
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
for prob in test_problems_nonlinear
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
# test SSP coefficient
sol = solve(test_problem_ssp_long, alg, dt=OrdinaryDiffEq.ssp_coefficient(alg), dense=false)
@test all(sol.u .>= 0)


alg = SSPRK432()
for prob in test_problems_only_time
  sim = test_convergence(dts, prob, alg)
  # higher order as pure quadrature
  @test abs(sim.𝒪est[:final]-1-OrdinaryDiffEq.alg_order(alg)) < testTol
end
for prob in test_problems_linear
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
for prob in test_problems_nonlinear
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
# test SSP coefficient
sol = solve(test_problem_ssp_long, alg, dt=OrdinaryDiffEq.ssp_coefficient(alg), dense=false)
@test all(sol.u .>= 0)
# test SSP property of dense output
sol = solve(test_problem_ssp, alg, dt=8/5, adaptive=false)
@test mapreduce(t->all(0 .<= sol(t) .<= 1), (u,v)->u&&v, range(0, stop=8, length=50), init=true)
sol = solve(test_problem_ssp_inplace, alg, dt=8/5, adaptive=false)
@test mapreduce(t->all(0 .<= sol(t) .<= 1), (u,v)->u&&v, range(0, stop=8, length=50), init=true)


alg = SSPRK932()
for prob in test_problems_only_time
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
for prob in test_problems_linear
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
for prob in test_problems_nonlinear
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
# test SSP coefficient
sol = solve(test_problem_ssp_long, alg, dt=OrdinaryDiffEq.ssp_coefficient(alg), dense=false,maxiters=1e7)
@test all(sol.u .>= 0)


alg = SSPRK54()
for prob in test_problems_only_time
  sim = test_convergence(dts, prob, alg)
  # convergence order seems to be worse for this problem
  @test abs(sim.𝒪est[:final]+0.25-OrdinaryDiffEq.alg_order(alg)) < testTol
end
for prob in test_problems_linear
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
for prob in test_problems_nonlinear
  sim = test_convergence(dts, prob, alg)
  # convergence order seems to be better for this problem
  @test abs(sim.𝒪est[:final]-0.5-OrdinaryDiffEq.alg_order(alg)) < testTol
end
# test SSP coefficient
sol = solve(test_problem_ssp_long, alg, dt=OrdinaryDiffEq.ssp_coefficient(alg), dense=false)
@test all(sol.u .>= 0)


alg = SSPRK104()
for prob in test_problems_only_time
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
for prob in test_problems_linear
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
for prob in test_problems_nonlinear
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
# test SSP coefficient
sol = solve(test_problem_ssp_long, alg, dt=OrdinaryDiffEq.ssp_coefficient(alg), dense=false)
@test all(sol.u .>= 0)

alg = ORK256()
for prob in test_problems_only_time
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
for prob in test_problems_linear
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
for prob in test_problems_nonlinear
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end

alg = LDDRK64()
for prob in test_problems_only_time
  sim = test_convergence(dts, prob, alg)
  @test_broken sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
for prob in test_problems_linear
  sim = test_convergence(dts, prob, alg)
  @test_broken sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
for prob in test_problems_nonlinear
  sim = test_convergence(dts, prob, alg)
  @test_broken sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
# for CFRLDDRK64 to be in asymptotic range
dts = 1 .//2 .^(7:-1:4)
alg = CFRLDDRK64()
for prob in test_problems_only_time
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
for prob in test_problems_linear
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
for prob in test_problems_nonlinear
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end

# for NDBLSRK124 to be in asymptotic range
dts = 1 .//2 .^(7:-1:3)
alg = NDBLSRK124()
for prob in test_problems_only_time
	sim = test_convergence(dts, prob, alg)
	@test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
for prob in test_problems_linear
	sim = test_convergence(dts, prob, alg)
	@test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
for prob in test_problems_nonlinear
	sim = test_convergence(dts, prob, alg)
	@test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end

#reverting back to original dts
dts = 1 .//2 .^(8:-1:4)

alg = NDBLSRK144()
for prob in test_problems_only_time
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
for prob in test_problems_linear
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
for prob in test_problems_nonlinear
  sim = test_convergence(dts, prob, alg)
  @test sim.𝒪est[:final] ≈ OrdinaryDiffEq.alg_order(alg) atol=testTol
end
