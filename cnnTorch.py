import torch
import torch.nn as nn
import torch.nn.functional as fn
import numpy as np
filter_vals = np.array([[-1, -1, 1, 2], [-1, -1, 1, 0], [-1, -1, 1, 1], [-1, -1, 1, 1]])
print(‘Filter shape: ‘, filter_vals.shape)
# Neural network with one convolutional layer and four filters
class Net(nn.Module):
 
 def __init__(self, weight): #Declaring a constructor to initialize the class variables
 super(Net, self).__init__()
 # Initializes the weights of the convolutional layer to be the weights of the 4 defined filters
 k_height, k_width = weight.shape[2:]
 # Assumes there are 4 grayscale filters; We declare the CNN layer here. Size of the kernel equals size of the filter
 # Usually the Kernels are smaller in size
 self.conv = nn.Conv2d(1, 4, kernel_size=(k_height, k_width), bias=False)
 self.conv.weight = torch.nn.Parameter(weight)
 
 def forward(self, x):
 # Calculates the output of a convolutional layer pre- and post-activation
 conv_x = self.conv(x)
 activated_x = fn.relu(conv_x)
# Returns both layers
 return conv_x, activated_x
# Instantiate the model and set the weights
weight = torch.from_numpy(filters).unsqueeze(1).type(torch.FloatTensor)
model = Net(weight)
# Print out the layer in the network
print(model)
def visualization_layer(layer, n_filters= 4):
    
    fig = plt.figure(figsize=(20, 20))
    
    for i in range(n_filters):
        ax = fig.add_subplot(1, n_filters, i+1, xticks=[], yticks=[])
        # Grab layer outputs
        ax.imshow(np.squeeze(layer[0,i].data.numpy()), cmap='gray')
        ax.set_title('Output %s' % str(i+1))

plt.imshow(gray, cmap='gray')

fig = plt.figure(figsize=(12, 6))
fig.subplots_adjust(left=0, right=1.5, bottom=0.8, top=1, hspace=0.05, wspace=0.05)
for i in range(4):
    ax = fig.add_subplot(1, 4, i+1, xticks=[], yticks=[])
    ax.imshow(filters[i], cmap='gray')
    ax.set_title('Filter %s' % str(i+1))
    
# Convert the image into an input tensor
gray_img_tensor = torch.from_numpy(gray).unsqueeze(0).unsqueeze(1)
# print(type(gray_img_tensor))
# print(gray_img_tensor)
# Get the convolutional layer (pre and post activation)
conv_layer, activated_layer = model.forward(gray_img_tensor.float())
# Visualize the output of a convolutional layer
visualization_layer(conv_layer)
visualization_layer(activated_layer)
