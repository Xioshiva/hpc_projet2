***Alexey Paulot*** 

# Introduction

Dans ce TP notre but était d'accélérer l'équation de la chaleur en utilisant une carte graphique avec CUDA.

# Implémentation

Avec CUDA on utilise un GPU pour pouvoir faire plein de petits calculs et la mémoire est partagée entre chaque thread.

Au début, il faut créer une matrice lecture et écriture avec cudaMalloc() et les envoyer sur le GPU avec cudaMemcpy(), j’utilise que un kernel et ne découpe pas les matrices.

J’ai donc fait une implémentation avec un kernel  ou y a un thread pour chaque case de notre matrice. Il y a donc simplement besoin pour chaque thread de connaître sa position dans notre matrice avec *block_Idx*, *threadIdx*, et *blockDim* et ensuite lire les quatre cases à côté utile pour la formule de Laplace, faire le calcul et donner le résultat.

On va donc répéter cette opération pour chaque itération demandée et par la nature de CUDA on à besoin d’une matrice lecture ou on va lire les valeurs et une matrice écriture ou on va écrire les résultats. Après chaque itération il faut synchroniser les threads CUDA et inverser les tableaux lecture et écriture, pour cela on va simplement inverser les pointeurs vers ces deux matrices.

Pour mesurer le temps j’ai utiliser les fonctions de CUDA avec cudaEventCreate(), cudaEventSynchronize(), cudaEventElapsedTime() et j’ai mesurer seulement la boucle d'itération et donc pas les malloc et memcpy.

# Résultats

Pour faire mes mesures j’ai utilisé la 007 de baobab avec le GPU P100 avec 12GB de mémoire et toujours utilisé 10000 itérations.

Pour les 3 tailles de mesures demandées j’ai utilisé nvidia-smi qui montre la mémoire utilisée par mon programme.

Petit : 3307MB / 12198MB = 27.1% avec matrice 20000*20000.

Moyen : 7123MB/ 12198MB = 58.4% avec matrice 30000*30000.

Grand : 11275MB/ 12198MB = 92.4% avec matrice 38000*38000.





| Petit| Moyen| Grand |
|---|---|---|
|114.962s|257.790s |411.794s|
|114.991s| 257.714s| 411.765s|
|114.997s| 257.806s| 411.647s|
|114.968s| 257.788s| 411.800s|
|115.002s| 257.719s| 411.766s|

Ce qui nous donne 

| Taille| Temps Moyen(s) | Écart-Type(s) |
|---|---|---|
|Petit|114,984  |0.01601|
|Moyen| 257.763 |  0.03883|
|Grand| 411.754 | 0.05555|

On voit donc que pour le temps d'exécution avec l'implémentation en CUDA augmente de façon plutôt linéaire et que l'écart type est très petit ce qui signifie une stabilité et peu de variation sur le temps d'exécution.

## Comparaison MPI - CUDA

C’est compliqué de comparer la parallélisation sur CPU et l'accélération sur GPU mais je pense pour ce genre de code ou un thread doit simplement faire une addition le GPU est gagnant car avoir accès à un GPU est bien plus simple que des centaines de coeur de CPU pour faire des calcules.Le fait que un GPU a accès à des milliers de thread contre quelque centaines pour les CPU rends une carte graphique supérieur dans ce type de problème. Sans parler que la librairie CUDA est plus agréable à utiliser et marche sur n’importe quel PC avec une carte graphique nvidia.

# Conclusion

Dans ce TP on a donc mis en pratique nos cour sur CUDA pour implémenter l'accélération de l'équation de la chaleur de Laplace sur GPU, on à vu l'efficacité d’une telle implémentation et avons rapidement comparé le multithreading sur GPU et CPU.








