# test the functions in src/bootstrap.jl

exdir = joinpath(@__DIR__,"..","examples")

@testset "testing hybridBootstrapSupport" begin
bestnet = readTopology(joinpath(exdir,"fish2hyb.net"));
bootnet = readMultiTopology(joinpath(exdir,"fish3hyb_20boostrap.net"));
# issues with bootstrap networks 12, 21, 42, 96
# plot(bootnet[20], showEdgeNumber=true)
# include(string(home, "bootstrap.jl"))
resn, rese, resc, gam, edgenum = hybridBootstrapSupport(bootnet,bestnet);
#@show resn; @show rese; showall(gam); @show edgenum; resc
# plot(bestnet, showIntNodeNumber=true)

@test resn[:clade][1:2] == ["H26","H25"]
@test resn[:BS_hybrid_samesisters][1:2] == [25.0,100.0]
@test resn[:BS_hybrid] == [100.0,100,0,0,0,75,0,0,0,0,0,0,5,5,5,5,5,0,0,0]
@test resn[:BS_minor_sister] == [0.0,0,100,0,0,5,10,70,75,25,5,5,0,0,0,0,0,0,0,5]
@test resn[:BS_major_sister] == [0.0,0,0,100,100,0,70,10,0,0,5,5,0,0,0,0,0,5,5,0]
@test rese[:BS_minor][2] == 25.0  # BS of introgression for H26
@test rese[:BS_minor][4] == 100.0 # BS of introgression for H25
@test resc[:taxa]==["Xgordoni","Xmeyeri","Xcouchianus","Xvariatus","Xevelynae","Xxiphidium",
 "Xmilleri","Xandersi","Xmaculatus","Xhellerii","Xalvarezi","Xmayae","Xsignum","Xclemenciae_F2",
 "Xmonticolus","Xmontezumae","Xnezahuacoyotl","Xbirchmanni_GARC","Xmalinche_CHIC2","Xcortezi",
 "Xcontinens","Xpygmaeus","Xnigrensis","Xmultilineatus"]
@test resc[:taxa][resc[:H26]] == ["Xnezahuacoyotl"]
@test resc[:taxa][resc[:H25]] == ["Xmontezumae","Xnezahuacoyotl","Xbirchmanni_GARC","Xmalinche_CHIC2","Xcortezi","Xcontinens","Xpygmaeus","Xnigrensis","Xmultilineatus"]
@test resc[:taxa][resc[:c_minus27]] == ["Xnigrensis","Xmultilineatus"] # minor sis of H26
@test resc[:taxa][resc[:Xxiphidium]] == ["Xxiphidium"] # minor sis of H25
@test resc[:taxa][resc[:Xsignum]] == ["Xsignum"] # donor8 previously
@test resc[:taxa][resc[:c_minus24]] == ["Xcontinens","Xpygmaeus","Xnigrensis","Xmultilineatus"] # donor7
@test resc[:taxa][resc[:Xmontezumae]] == ["Xmontezumae"] # major sis of H26. Below: major sis of H25
@test resc[:taxa][resc[:c_minus12]] == ["Xhellerii","Xalvarezi","Xmayae","Xsignum","Xclemenciae_F2","Xmonticolus"]
@test gam[:,2] == [.0,.0,.192,.0,.0,.0,.0,.0,.193,.0,.184,.193,.0,.0,.0,.0,.0,.193,.0,.0]
@test gam[:,4] == [.165,.166,.165,.166,.165,.165,.166,.165,.165,.166,.164,.166,.166,.165,.165,.165,.166,.165,.166,.166]
@test edgenum ==[25,39,43,7]
end # of testset, hybridBootstrapSupport

# exdir = ""
info("testing bootsnaq from quartet CF intervals")
T=readTopology(joinpath(exdir,"startTree.txt"))
df=CSV.read(joinpath(exdir,"tableCFCI.csv"))
net1 = readTopology("(5,(((2,(1)#H7:::0.7143969494428192):1.5121337017411736,4):0.4894187322508883,3):0.519160762355313,(6,#H7:::0.2856030505571808):10.0);")
originalSTDOUT = STDOUT
redirect_stdout(open("/dev/null", "w")) # not portable to Windows
bootnet = bootsnaq(T,df,nrep=2,runs=1,seed=1234,filename="",Nfail=2,ftolAbs=1e-3,ftolRel=1e-3,
                   xtolAbs=1e-4,xtolRel=1e-3,liktolAbs=0.01)
redirect_stdout(originalSTDOUT)
@test size(bootnet)==(2,)
@test writeTopology(bootnet[1], round=true)=="(4,(((6,#H7:0.0::0.222):10.0,2):0.0,((5,1):0.0)#H7:0.0::0.778):0.0,3);"
@test writeTopology(bootnet[2], round=true)=="(2,3,((4,5):0.0,(1,6):0.011):0.0);"
# "(2,((5,#H9:0.0::0.298):3.927,3):1.331,(((1,6):0.019,4):0.0)#H9:0.0::0.702);"
# above: bad diamond 2, and both edges above the hybrid have estimated length of 0.0...

@testset "bootsnaq from bootstrap gene trees, multiple procs" begin
treefile = joinpath(exdir,"treefile.txt") # pretending these are bootstrap trees, for all genes
boottrees = Vector{HybridNetwork}[]
for i=1:13 push!(boottrees, readMultiTopology(treefile)) end
for i=1:13 @test size(boottrees[i])==(10,) end # 10 bootstrap trees for each of 13 "genes"
addprocs(1)
@everywhere using PhyloNetworks
redirect_stdout(open("/dev/null", "w"))
bootnet = bootsnaq(T,boottrees,nrep=2,runs=2,otherNet=net1,seed=1234,prcnet=0.5,filename="",Nfail=2,ftolAbs=1e-3,ftolRel=1e-3)
redirect_stdout(originalSTDOUT)
rmprocs(workers())
@test size(bootnet)==(2,)
@test writeTopology(bootnet[1], round=true)=="((((2,(1)#H7:::0.597):10.0,4):0.407,(6,#H7:::0.403):0.307):0.0,3,5);"
# "((5,((2,(1)#H7:::0.629):2.374,4):0.487):0.0,(6,#H7:::0.371):1.409,3);"
# "((((2,(1)#H7:::0.678):1.774,4):0.235,3):0.899,5,(6,#H7:::0.322):10.0);"
@test writeTopology(bootnet[2], round=true)=="(5,(((2,(1)#H7:::0.691):2.881,4):1.444,3):0.0,(6,#H7:::0.309):0.198);"
# "(5,(((2,(1)#H7:::0.751):1.559,4):0.373,3):0.688,(6,#H7:::0.249):10.0);"
# "(((5,(6,#H7:::0.249):10.0):0.688,3):0.373,(2,(1)#H7:::0.751):1.559,4);"
end
