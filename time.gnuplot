set datafile separator ","
set terminal png size 900,400
# set logscale y
set xlabel "Time"
set xdata time
set timefmt "%s"
set format x "%M:%S"
set key left top
set grid
plot "report/time.log" using 1:3 w l title "latency", "report/time.log" using 1:2 w l title "duration"
