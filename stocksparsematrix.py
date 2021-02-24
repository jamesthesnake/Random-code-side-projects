
import numpy as np
from scipy import linalg
#  Reset the random seed
np.random.seed(2)

#  Define the stock price initially, the number of days, the interest rate and volatility
N_days = 5

S0 = 100.0
r = 0.01 / 252
dt = 1.0
sigma = 0.3 / np.sqrt(252)

epsilon = np.random.normal( size = N_days )

#  For the diags command, we need to define the entries on the diagonals.
Lambda = r * dt + np.sqrt(dt) * sigma * epsilon
ones = -np.ones( N_days + 1); ones[0] = 1
L = Lambda + 1

#  Build the matrix
M = diags([L, ones], [-1, 0], format = 'csc')
Y = np.zeros( N_days + 1); Y[0] = S0

#  Solve the system
S = linalg.spsolve(M, Y)
plt.plot(S)
plt.grid(True)
plt.xlabel('Days')
plt.ylabel('Stock Price')
