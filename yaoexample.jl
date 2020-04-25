using Yao, YaoExtensions
# number of qubits and circuit depth
n, d = 16, 100
circuit = dispatch!(variational_circuit(n, d),:random)

h = heisenberg(n)

for i in 1:100
 _, grad = expect'(h, zero_state(n) => circuit)
 dispatch!(-, circuit, 1e-1 * grad)
 println("Step $i, energy = $(real.(expect(h, zero_state(n)=>circuit)))")
end
