
tranches = pd.read_csv('https://gist.githubusercontent.com/whitead/f47887e45bbd2f38332182d2d422da6b/raw/a3948beac9b9034dab432b697c5ec238503ac5d0/tranches.txt')
def get_mol_batch(batch_size = 32):
  for t in tranches.values:
    d = pd.read_csv(t[0], sep=' ')    
    for i in range(len(d) // batch_size):
      yield d.iloc[i * batch_size:(i + 1) * batch_size, 0].values
