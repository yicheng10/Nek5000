#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Feb 22 11:11:12 2023

@author: anton
"""

from pymech.neksuite import readre2
import numpy as np
import matplotlib.pyplot as plt

# Read in file, create object and print
fn = "airfoil1.re2"
d = readre2(fn)
print(d)

# define zlevel
zlevel = 0.0

# Extract data from object
nel = d.nel
ndim = d.ndim
lims = d.lims.pos
pos = np.array([i.pos for i in d.elem]) # x,y,z
#print(pos[0])

# Extract boundary conditions
bc = []
sides = 4
for j in range(nel): # Iterate through each element
    bb = d.elem[j].bcs
    for side in range(sides): # Iterate through each side
        a = bb[0][side][7]
        b = repr(a)
        c = str(b)
        c = c.lstrip("'"); c = c.rstrip("'");                       
        bc.append(c)    

# Find boundaries
pointsX = []; pointsY = [];
X = []; Y = []; faceX = []; faceY = []; ele = [];
for k in range(nel): # iterate through each element
    
    #print(pos[k, :])
    # Only look at certain z
    if pos[k, 2, 0, 0, 0] == zlevel:

        pointsX.append(pos[k, 0, 0, 0, 0]) 
        pointsX.append(pos[k, 0, 0, 0, 1])
        pointsX.append(pos[k, 0, 0, 1, 1]) 
        pointsX.append(pos[k, 0, 0, 1, 0])
        
        pointsY.append(pos[k, 1, 0, 0, 0]) 
        pointsY.append(pos[k, 1, 0, 0, 1])
        pointsY.append(pos[k, 1, 0, 1, 1]) 
        pointsY.append(pos[k, 1, 0, 1, 0])
    
        # Find coordinates of letters for boundary conditions
        xc1 = d.elem[k].face_center(0)[0]
        xc2 = d.elem[k].face_center(1)[0]
        xc3 = d.elem[k].face_center(2)[0]
        xc4 = d.elem[k].face_center(3)[0]
        
        yc1 = d.elem[k].face_center(0)[1]
        yc2 = d.elem[k].face_center(1)[1]
        yc3 = d.elem[k].face_center(2)[1]
        yc4 = d.elem[k].face_center(3)[1]
    
        X.append(xc1); X.append(xc2); X.append(xc3); X.append(xc4);
        Y.append(yc1); Y.append(yc2); Y.append(yc3); Y.append(yc4);   

        # Find coordinates for element numbers
        faceX.append(d.elem[k].face_center(5)[0])
        faceY.append(d.elem[k].face_center(5)[1])
        ele.append(k+1)

# Plot

font = {'family': 'serif',
        'color':  'darkred',
        'weight': 'normal',
        'size': 6,
        }

pointsnpX = np.asarray(pointsX)
pointsnpY = np.asarray(pointsY)
fig, ax = plt.subplots(figsize=(8,12), dpi=200)
#plt.xticks(np.arange(-35, 45.1, step=5))
#plt.yticks(np.arange(-70, 70.1, step=5))
plt.grid(color='gray', linestyle='--', linewidth=0.2)
plt.title('New BC\'s Outer Mesh')
for xp, yp, m in zip(X, Y, bc):
    plt.text(xp,yp,m, fontdict=(font))
plt.plot(pointsnpX, pointsnpY, linestyle='None', marker = '.', color = 'k', markersize=2) 
for xf, yf, mf in zip(faceX, faceY, ele):
    plt.text(xf, yf, mf, fontdict=(font), color = 'b')
plt.show()

image_format = 'svg' # e.g .png, .svg, etc.
image_name = 'mesh.svg'

fig.savefig(image_name, format=image_format, dpi=1200)
#print(d.elem[0].face_center(0))
#print(d.elem[0].face_center(1))
#print(d.elem[0].face_center(2))
#print(d.elem[0].face_center(3))
#print(d.elem[0].face_center(4))
#print(d.elem[0].face_center(5))
