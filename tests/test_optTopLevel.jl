# test for whole optimization on the space of topologies
# with the same number of hybridizations
# Claudia February 2015

# -------------------5taxon tree------------------

include("../types.jl")
include("../functions.jl")

df = readtable("Tree_output.csv")
d = readDataCF(df)

# starting tree:
tree = "((6,4),(7,8),10);"
f = open("prueba_tree.txt","w")
write(f,tree)
close(f)
currT = readTopologyUpdate("prueba_tree.txt");
printEdges(currT)

epsilon = eps()
N = 100

@time newT = optTopLevel!(currT,epsilon,N,d)
#got 5.34957 at [0.2,0.1] after 28 iterations (returned FTOL_reached)
#loglik_1 = 5.34957
#found minimizer topology at step 1 with -loglik=5.34957 and ht_min=[0.2,0.1]
#elapsed time: 8.910952599 seconds (91065584 bytes allocated, 0.59% gc time)
printEdges(newT)
# forgot to copy, but true tree!



# ------------------5taxon network 1 hybridization-----------------
# starting topology: Case G
include("../case_g_example.jl");
currT = deepcopy(net);
printEdges(currT)

# real network: Case H
df = readtable("CaseH_output.csv")
d = readDataCF(df)


epsilon = eps()
N = 100

@time newT = optTopLevel!(currT,epsilon,N,d)
printEdges(newT)


