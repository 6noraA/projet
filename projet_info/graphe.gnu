set terminal png size 800,600
set output 'graphe/histogram.png'

set datafile separator ":"
set style data histogram
set style histogram cluster gap 1
set style fill solid border -1
set boxwidth 0.9

set xtics rotate by -45
set grid ytics
set ylabel "Values"
set xlabel "Variables"
set key top right

plot "result/lv_all_minmax.csv" using 2:xtic(1) title "Capacité" linecolor rgb "blue", \
     "" using 3 title "Consomation" linecolor rgb "red"

