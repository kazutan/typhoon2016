# カラーパレット作成
colpal <- colorNumeric(palette = grDevices::heat.colors(n=80), domain = c(880,1000))
# ポップアップ作成
res <- dplyr::mutate(df_t1, popup = paste(timing,paste("中心気圧",hpa, "hPa"),paste("最大風速",c_wspeed),paste("瞬間最大風速",m_wspeed),sep = "<br/>"))
# 説明用テキスト
att <- paste(paste(format(Sys.time(), '%y年%m年%d %H時%M分', tz='Japan'),"時点の情報です"),"点をクリックすると情報が出ます","詳細は<a href='http://www.jma.go.jp/jp/typh/'>気象庁の台風情報</a>を確認ください。",sep = "<br/>")

m <- leaflet(res) %>% 
  addTiles() %>% 
  setView(lng = 139.0000, lat = 35.0000, zoom = 4) %>% 
  addCircles(~lon, ~lat, radius = ~a_boufu*1000, weight = 2, fillColor = ~colpal(hpa), color = ~colpal(hpa), stroke = TRUE, popup = ~popup, group = "boufu") %>%
  addCircles(~lon, ~lat, radius = ~a_yosou*1000, weight = 2, fillOpacity = 0.2, color = "#999", stroke = TRUE, group = "yohou") %>% 
  addPolylines(~lon, ~lat, weight = 3, color = "#eee") %>% 
  addPopups(lng = 125.0000, lat = 42.0000, att,
            option = popupOptions(closeButton = FALSE)) %>% 
  addLegend(position = "topright", pal = colpal, values = ~hpa,
            title = "中心気圧", labFormat=labelFormat(suffix = " hpa"))