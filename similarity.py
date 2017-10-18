import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
weights = np.genfromtxt('cfpb_weights.csv', delimiter=',')
print("weights gained")
similarity = cosine_similarity(weights)
print("similarity calculated")
np.savetxt("cfpb_similarity.csv", similarity, delimiter=",")
print("similarity stored")
