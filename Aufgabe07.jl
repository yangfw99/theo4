#using Pkg
#Pkg.add("StaticArrays")
#Pkg.add("Plots")
using Plots
using StaticArrays
using BenchmarkTools
Plots.gr()
Plots.GRBackend()

#Ändert bei der Positionsliste einen Eintrag nachdem t-mal die Positionsänderung mit der Wahrscheinlichkeit p bestimmt wurde
function randomWalk(t, positionList, p, pWhenMiss=p, pWhenHit=p)
    if length(positionList) != 2t+1
        println("Die Liste mit den möglichen Positionen muss 2*t+1 lang sein!")
        return nothing
    end
    positionList[changePosition(t, p, pWhenMiss, pWhenHit)] += 1
    return nothing
end

#Gibt die Position nach t Positionsänderungen mit der Wahrscheinlichkeit p wieder
function changePosition(t, p, pWhenMiss, pWhenHit)
    currentPosition = t+1
    probability = p
    for time in 1:t
        if rand(Float64) < probability
            currentPosition += 1
            probability = pWhenHit
        else
            currentPosition -= 1
            probability = pWhenMiss
        end
    end
    return currentPosition
end

#Normiert die die Positionsliste, d.h. es wird nicht angegeben wie oft die Position erreicht wurde (absolute Zahl), sondern der Anteil
function normalizeArray(array)
    sum = 0
    for element in array
        sum += element
    end
    if sum != 0
        return array/sum
    else
        return array
    end
end

function shannonInformation(probabilityArray)
    shannonInfo = 0
    for probability in probabilityArray
        if probability > 0.0
            shannonInfo += probability*log2(probability)
        end
    end
    return shannonInfo
end
#allgemeine Parameter
tList = [10, 100, 1000] #alle zu betrachtenen Zeiten
totalRuns = 1e6

#Array aus Arrays mit allen möglichen Positionen für verschiedene Zeitpunkte, z.B. t=10, t=100, ...
positions = [[x for x in -t:t] for t in tList]

##Aufgabe 7a


#Array aus Arrays, die angeben wie oft eine Position getroffen wurde: die einzelnen Arrays sind 2t+1 groß
positionList7a = [zeros(MVector{2*t+1,Int128}) for t in tList]

#Wahrscheinlichkeit aus der Aufgabenstellung nach links zu gehen
p7a = 0.3

#Für alle t Fälle werden die Positionsverteilungen berechnet
for i in 1:length(tList)
    for currentRun in 1:totalRuns
        randomWalk(tList[i], positionList7a[i], p7a)
    end
end


#Für alle t Fälle werden die Positionsverteilungen in Wahrscheinlichkeitsverteilungen umgerechnet
normalizeList7a = Array{Float64}[]
for list in positionList7a
    push!(normalizeList7a, normalizeArray(list))
end

#Shannon Information
shannonInformation7a = zeros(MVector{length(tList),Float64})

for i in 1:length(normalizeList7a)
        shannonInformation7a[i] = shannonInformation(normalizeList7a[i])
end
println("Für die Zeiten t = ", tList, " ergeben sich die Shannon Informationen: I = ", shannonInformation7a)

#Plots
plots7a = []
for i in 1:length(normalizeList7a)
    push!(plots7a, bar(positions[i],normalizeList7a[i], title = "Shannon Information I = $(shannonInformation7a[i])", label = "P[x(t=$(tList[i]))]", fillcolor = :blue, line = :black))
    savefig(plots7a[i], "plotAufgabe7at$(tList[i]).pdf")
end



##Aufgabe7b

#Wahrscheinlichkeiten nach links zu gehen (p7b), nach einem Schritt nach links nochmal nach links zu gehen (p7bWhenHit) und nach einem Schritt nach rechts nach links zu gehen (p7bWhenMiss)
p7b = 0.3
p7bWhenHit = 0.8
p7bWhenMiss = 0.6

#Array aus Arrays, die angeben wie oft eine Position getroffen wurde: die einzelnen Arrays sind 2t+1 groß
positionList7b = [zeros(MVector{2*t+1,Int128}) for t in tList]

#Für alle t Fälle werden die Positionsverteilungen berechnet
for i in 1:length(tList)
    for currentRun in 1:totalRuns
        randomWalk(tList[i], positionList7b[i], p7b, p7bWhenMiss, p7bWhenHit)
    end
end

#Für alle t Fälle werden die Positionsverteilungen in Wahrscheinlichkeitsverteilungen umgerechnet
normalizeList7b = Array{Float64}[]
for list in positionList7b
    push!(normalizeList7b, normalizeArray(list))
end

#Shannon Information
shannonInformation7b = zeros(MVector{length(tList),Float64})

for i in 1:length(normalizeList7b)
        shannonInformation7b[i] = shannonInformation(normalizeList7b[i])
end
println("Für die Zeiten t = ", tList, " ergeben sich die Shannon Informationen: I = ", shannonInformation7b)

#Plots
plots7b = []
for i in 1:length(normalizeList7b)
    push!(plots7b, bar(positions[i],normalizeList7b[i], title = "Shannon Information I = $(shannonInformation7b[i])", label = "P[x(t=$(tList[i]))]",legend = :topleft, fillcolor = :blue, line = :black))
    savefig(plots7b[i], "plotAufgabe7bt$(tList[i]).pdf")
end
