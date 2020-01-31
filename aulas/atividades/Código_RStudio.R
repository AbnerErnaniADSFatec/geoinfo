library(wtss)

?WTSS

w <- WTSS("http://brazildatacube.dpi.inpe.br/esensing/wtss")

?list_coverages

list_coverages(w)

?describe_coverage

describe_coverage(w, "MOD13Q1")

?time_series

# Gráfico Gerado (https://github.com/AbnerErnaniADSFatec/geoinfo/tree/master/aulas/atividades/plot_all_bands_from_wtss.png)
time_series(w, "MOD13Q1", longitude = -50, latitude = -10) %>% plot()

time_series(w, "MOD13Q1", attributes = 'ndvi', longitude = -50, latitude = -10) %>% plot()
