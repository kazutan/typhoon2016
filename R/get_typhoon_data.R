# 台風情報取得

library("dplyr")
library("rvest")
library("stringr")
library("leaflet")

trg <- read_html("http://www.jma.go.jp/jp/typh/") %>% html_table
tbl1 <- trg[[4]]

timing = tbl1$X1 %>% 
  str_subset("[0-9][0-9]日[0-9][0-9]時")
lat = tbl1$X2 %>% 
  str_subset("北緯") %>%
  str_extract("[0-9][0-9]\\.[0-9]度") %>%
  str_replace("度","") %>%
  as.numeric
lon = tbl1$X2 %>%
  str_subset("東経") %>%
  str_extract("[0-9][0-9][0-9]\\.[0-9]度") %>%
  str_replace("度","") %>%
  as.numeric
hpa = tbl1$X2 %>% 
  str_subset("hPa") %>% 
  str_replace("hPa","") %>% 
  as.numeric
c_wspeed = tbl1 %>% 
  dplyr::filter(X1 == "中心付近の最大風速"| X1 == "最大風速") %>% 
  dplyr::select(X2) %>% 
  dplyr::rename(c_wspeed=X2)
m_wspeed = tbl1 %>% 
  dplyr::filter(X1 == "最大瞬間風速") %>% 
  dplyr::select(X2) %>% 
  dplyr::rename(m_wspeed=X2)
a_yosou = tbl1 %>% 
  dplyr::filter(stringr::str_detect(.$X1, "予報")) %>% 
  dplyr::select(X2) %>% 
  str_extract_all("[0-9]+km") %>% 
  unlist %>% 
  str_replace("km", "") %>% 
  as.numeric
a_boufu = tbl1 %>% 
  dplyr::filter(stringr::str_detect(.$X1, "暴風")) %>% 
  dplyr::select(X2) %>% 
  str_extract_all("[0-9]+km") %>% 
  unlist %>% 
  str_replace("km", "") %>% 
  as.numeric

# 予報円は現時点の分にはないので、頭にNAを手動で追加
a_yosou <- c(NA, a_yosou)
# 暴風警戒域、なぜか最後は表示されてない(なくなるから?)ので最後にNAを手動で追加
a_boufu <- c(a_boufu, NA)

# データフレームとして結合
df_t1 <- data.frame(timing, lat, lon, hpa, c_wspeed, m_wspeed, a_yosou, a_boufu)
