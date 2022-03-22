from rogues import lesp
from matplotlib import pyplot
import seaborn as sns 
from scipy.linalg import eigvals
from mpmath import *
# Set precision to 32-digit
mp.dps = 32

sns.set()
palette = sns.color_palette("bright")

# Dimension of matrix
dim = 100
# Lesp matrix
A = lesp(dim)
# Transpose matrix A
AT = A.T
# Calculate eigenvalues of A
Aev, Eeg = mp.eig(mp.matrix(A))
# Calculate eigenvalues of A^T
ATev, ETeg = mp.eig(mp.matrix(AT))
# Extract real and imaginary parts of A
A_X = [x.real for x in Aev]
A_Y = [x.imag for x in Aev]
# Extract real and imaginary parts of A^T
AT_X = [x.real for x in ATev]
AT_Y = [x.imag for x in ATev]

# Plot
ax = sns.scatterplot(x=A_X, y=A_Y, color = 'gray', marker='o', label=r'$\mathbf{A}$')
ax = sns.scatterplot(x=AT_X, y=AT_Y, color = 'blue', marker='x', label=r'$\mathbf{A}^T$')
# Give axis labels
ax.set(xlabel=r'real', ylabel=r'imag')
# Draw legend
ax.legend()

pyplot.show()
